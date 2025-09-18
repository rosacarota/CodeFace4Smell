## This file is part of Codeface. Codeface is free software: you can
## redistribute it and/or modify it under the terms of the GNU General Public
## License as published by the Free Software Foundation, version 2.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
## FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##
## Copyright 2013 by Siemens AG, Wolfgang Mauerer <wolfgang.mauerer@siemens.com>
## All Rights Reserved.

"""
Utility functions for running external commands
"""

import logging; log = logging.getLogger(__name__)
import os
import re
import shutil
import signal
import sys
import traceback
from collections import OrderedDict, namedtuple
from glob import glob
from math import sqrt
from multiprocessing import Process, JoinableQueue, Lock
from pickle import dumps, PicklingError
from pkg_resources import resource_filename
from subprocess import Popen, PIPE
from tempfile import NamedTemporaryFile, mkdtemp
from time import sleep
from threading import enumerate as threading_enumerate
from datetime import timedelta, datetime

# compatibilità Python 2/3: Empty viene da queue (Py3) o Queue (Py2)
try:
    from Queue import Empty     # Python 2
except ImportError:
    from queue import Empty     # Python 3


# Represents a job submitted to the batch pool.
BatchJobTuple = namedtuple('BatchJobTuple', [
    'id', 'func', 'args', 'kwargs', 'deps', 'startmsg', 'endmsg'
])

class BatchJob(BatchJobTuple):
    def __new__(cls, id, func, args, kwargs, deps, startmsg=None, endmsg=None):
        # crea la namedtuple
        obj = super(BatchJob, cls).__new__(cls, id, func, args, kwargs, deps, startmsg, endmsg)
        # aggiungi attributi extra
        obj.done = False
        obj.submitted = False
        return obj



class BatchJobPool(object):
    """
    Implementation of a dependency-respecting batch pool
    """

    def __init__(self, n_cores):
        self.n_cores = n_cores
        self.next_id = 1
        self.jobs = OrderedDict()

        # Initialize workers and their work and done queues
        self.work_queue, self.done_queues, self.workers = JoinableQueue(), [], []
        if n_cores > 1:
            for i in range(n_cores):
                dq = JoinableQueue()
                w = Process(target=batchjob_worker_function, args=(self.work_queue, dq))
                self.done_queues.append(dq)
                self.workers.append(w)
                w.start()

    def _is_ready(self, job):
        if job.done or job.submitted:
            return False
        return all(self.jobs[j].done for j in job.deps if j is not None)

    def _submit(self, job):
        if self._is_ready(job):
            self.work_queue.put(job)
            job.submitted = True

    def add(self, func, args, kwargs={}, deps=(), startmsg=None, endmsg=None):
        if self.n_cores == 1:
            log.info(startmsg)
            func(*args, **kwargs)
            log.info(endmsg)
            return None
        job_id = self.next_id
        self.next_id += 1
        j = BatchJob(job_id, func, args, kwargs, deps, startmsg, endmsg)
        self.jobs[job_id] = j
        return job_id

    def join(self):
        try:
            while not all(j.done for j in self.jobs.values()):
                for j in self.jobs.values():
                    self._submit(j)
                for dq in self.done_queues:
                    try:
                        res = dq.get(block=False)
                    except Empty:
                        continue
                    if res is None:
                        log.fatal("Uncaught exception in worker thread!")
                        raise Exception("Failure in Batch Pool")
                    if isinstance(res, Exception):
                        log.fatal("Uncaught exception in worker thread:")
                        raise res
                    log.debug("Job {} has finished!".format(res))
                    self.jobs[res].done = True
                for w in self.workers:
                    if not w.is_alive():
                        w.join()
                        raise Exception("A Worker died unexpectedly!")
                sleep(0.01)
        finally:
            sleep(0.1)
            log.debug("Terminating workers...")
            for w in self.workers:
                w.terminate()
            log.debug("Workers terminated.")


def batchjob_worker_function(work_queue, done_queue):
    signal.signal(signal.SIGINT, handle_sigint_silent)
    while True:
        try:
            job = work_queue.get(block=True)
        except ValueError:
            return
        log.debug("Starting job id {}".format(job.id))
        try:
            if job.startmsg:
                log.info(job.startmsg)
            job.func(*job.args, **job.kwargs)
            if job.endmsg:
                log.info(job.endmsg)
            log.debug("Finished work id {}".format(job.id))
            done_queue.put(job.id)
        except Exception as e:
            log.debug("Failed work id {}".format(job.id))
            done_queue.put(Exception(
                "{}: {}\n{}".format(e.__class__.__name__, str(e), traceback.format_exc())
            ))


def get_stack_dump():
    id2name = dict([(th.ident, th.name) for th in threading_enumerate()])
    code = ["Stack dump:"]
    for threadId, stack in sys._current_frames().items():
        code.append("")
        code.append("# Thread: %s(%d)" % (id2name.get(threadId, ""), threadId))
        for filename, lineno, name, line in traceback.extract_stack(stack):
            code.append('File: "%s", line %d, in %s' % (filename, lineno, name))
            if line:
                code.append("  %s" % (line.strip()))
    return code


l = Lock()
def handle_sigint(signal, frame):
    with l:
        log.fatal("CTRL-C pressed!")
        for c in get_stack_dump():
            log.debug(c)
    sys.exit(-1)

def handle_sigint_silent(signal, frame):
    with l:
        for c in get_stack_dump():
            log.debug(c)
    logging.shutdown()
    os._exit(-1)

def handle_sigterm(signal, frame):
    logging.shutdown()
    os._exit(-1)

def handle_sigusr1(signal, frame):
    for c in get_stack_dump():
        log.info(c)


signal.signal(signal.SIGINT, handle_sigint)
signal.signal(signal.SIGTERM, handle_sigterm)
signal.signal(signal.SIGUSR1, handle_sigusr1)


def execute_command(cmd, ignore_errors=False, direct_io=False, cwd=None):
    jcmd = " ".join(cmd)
    log.debug("Running command: {}".format(jcmd))
    try:
        if direct_io:
            pipe = Popen(cmd, cwd=cwd)
        else:
            pipe = Popen(cmd, stdout=PIPE, stderr=PIPE, cwd=cwd)
        stdout, stderr = pipe.communicate()
    except OSError:
        log.error("Error executing command {}!".format(jcmd))
        raise

    if pipe.returncode != 0:
        if ignore_errors:
            log.warning("Command '{}' failed with exit code {}. Ignored.".
                        format(jcmd, pipe.returncode))
        else:
            if not direct_io:
                log.info("Command '{}' stdout:".format(jcmd))
                for line in stdout.decode().splitlines():
                    log.info(line)
                log.info("Command '{}' stderr:".format(jcmd))
                for line in stderr.decode().splitlines():
                    log.info(line)
            msg = "Command '{}' failed with exit code {}.\n(stdout: {}\nstderr: {})".format(
                jcmd, pipe.returncode, stdout.decode(), stderr.decode()
            )
            log.error(msg)
            raise Exception(msg)
    return stdout.decode()


def _convert_dot_file(dotfile):
    res = []
    edges = {}
    edge_spec = re.compile(r"\s+(\d+) -> (\d+);")

    with open(dotfile, "r") as file:
        lines = [line.strip("\n") for line in file]
    lines[0] = "digraph {"
    lines[1] = "node[fontsize=30, shape=\"box\"];"
    lines[-1] = ""

    for line in lines:
        m = re.match(edge_spec, line)
        if m:
            a, b = m.group(1), m.group(2)
            edges[(a, b)] = edges.get((a, b), 0) + 1
        else:
            res.append(line + "\n")

    for ((a, b), count) in sorted(edges.items()):
        res.append("{} -> {} [weight={} penwidth={}];\n".
                   format(a, b, count, sqrt(float(count))))

    res.append("overlap=prism;\n")
    res.append("splines=true;\n")
    res.append("}\n")
    return res


def layout_graph(filename):
    out = NamedTemporaryFile(mode="w", delete=False)
    out.writelines(_convert_dot_file(filename))
    out.close()
    cmd = ["dot", "-Kfdp", "-Tpdf", "-Gcharset=utf-8",
           "-o{}.pdf".format(os.path.splitext(filename)[0]), out.name]
    execute_command(cmd)
    os.unlink(out.name)


def generate_report(start_rev, end_rev, resdir):
    log.debug("  -> Generating report")
    report_base = "report-{0}_{1}".format(start_rev, end_rev)
    cmd = [resource_filename(__name__, "perl/create_report.pl"),
           resdir, "{}--{}".format(start_rev, end_rev)]
    with open(os.path.join(resdir, report_base + ".tex"), 'w') as f:
        f.write(execute_command(cmd))

    cmd = ["lualatex", "-interaction=nonstopmode",
           os.path.join(resdir, report_base + ".tex")]
    orig_wd = os.getcwd()
    tmpdir = mkdtemp()
    os.chdir(tmpdir)
    execute_command(cmd, ignore_errors=True)
    try:
        shutil.copy(report_base + ".pdf", resdir)
    except IOError:
        log.warning("Could not copy report PDF (missing input data?)")
    os.chdir(orig_wd)
    shutil.rmtree(tmpdir)


def generate_report_st(stdir):
    log.info("  -> Generating report")
    orig_wd = os.getcwd()
    tmpdir = mkdtemp()
    os.chdir(tmpdir)
    cmd = ["lualatex", "-interaction=nonstopmode",
           os.path.join(stdir, "report.tex")]
    execute_command(cmd, ignore_errors=True)
    try:
        shutil.copy("report.pdf", stdir)
    except IOError:
        log.warning("Could not copy report PDF (missing input data?)")
    os.chdir(orig_wd)
    shutil.rmtree(tmpdir)


def generate_reports(start_rev, end_rev, range_resdir):
    files = glob(os.path.join(range_resdir, "*.dot"))
    log.info("  -> Analysing revision range {0}..{1}: Generating Reports...".
             format(start_rev, end_rev))
    for file in files:
        layout_graph(file)
    generate_report(start_rev, end_rev, range_resdir)


def check4ctags():
    prog_name = 'Exuberant Ctags'
    prog_version = 'Exuberant Ctags 5.9~svn20110310'
    cmd = "ctags-exuberant --version".split()
    res = execute_command(cmd)
    if not res.startswith(prog_name):
        log.error("program '{}' does not exist".format(prog_name))
        raise Exception("ctags-exuberant not found")
    if not res.startswith(prog_version):
        log.error("Ctags version '{}' not found".format(prog_version))
        raise Exception("Incompatible ctags-exuberant version")


def check4cppstats():
    line = "cppstats v0.8.4"
    cmd = "/usr/bin/env cppstats --version".split()
    res = execute_command(cmd)
    if not res.startswith(line):
        error_message = "expected the first line to start with '{}' but got '{}'".format(line, res[0])
        log.error("program cppstats does not exist, or it is not working as expected ({})".format(error_message))
        raise Exception("no working cppstats found ({})".format(error_message))


def parse_iso_git_date(date_string):
    try:
        offset = int(date_string[-5:])
    except Exception:
        log.error("could not extract timezone info from \"{}\"".format(date_string))
        raise
    minutes = (offset if offset > 0 else -offset) % 100
    delta = timedelta(hours=offset // 100,
                      minutes=minutes if offset > 0 else -minutes)
    fmt = "%Y-%m-%d %H:%M:%S"
    parsed_date = datetime.strptime(date_string[:-6], fmt)
    parsed_date -= delta
    return parsed_date


def generate_analysis_windows(repo, window_size_months, num_windows=None):
    cmd_date = 'git --git-dir={0} show --format=%ad  --date=iso8601'.format(repo).split()
    latest_date_result = execute_command(cmd_date).splitlines()[0]
    latest_commit = parse_iso_git_date(latest_date_result)

    print_fmt = "%Y-%m-%dT%H:%M:%S+0000"
    month = timedelta(days=30)

    def get_before_arg(num_months):
        date = latest_commit - num_months * month
        return '--before=' + date.strftime(print_fmt)

    revs = []
    start = window_size_months
    end = 0
    cmd_base = 'git --git-dir={0} log --no-merges --format=%H,%ct'.format(repo).split()
    cmd_base_max1 = cmd_base + ['--max-count=1']
    cmd = cmd_base_max1 + [get_before_arg(end)]
    rev_end = execute_command(cmd).splitlines()
    revs.extend(rev_end)

    while start != end:
        if num_windows is not None:
            if num_windows == 0:
                break
            num_windows -= 1
        cmd = cmd_base_max1 + [get_before_arg(start)]
        rev_start = execute_command(cmd).splitlines()
        if len(rev_start) == 0:
            start = end
            cmd = cmd_base + ['--reverse']
            rev_start = [execute_command(cmd).splitlines()[0]]
        else:
            end = start
            start = end + window_size_months
        if rev_start[0] != revs[0]:
            revs = rev_start + revs
    revs = [rev.split(",") for rev in revs]
    if int(revs[0][1]) > int(revs[1][1]):
        del revs[0]
    revs = [rev[0] for rev in revs]
    rcs = [None for _ in range(len(revs))]
    return revs, rcs
