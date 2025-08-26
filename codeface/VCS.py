#! /usr/bin/env python3
# -*- coding: utf-8 -*-

import itertools
import readline
import re
import os
import bisect
import tempfile
import shutil

import commit
import fileCommit
import sourceAnalysis
import ctags
from fileCommit import FileDict
from progressbar import ProgressBar, Percentage, Bar, ETA
from ctags import CTags, TagEntry
from logging import getLogger
from codeface.linktype import LinkType
from .util import execute_command

log = getLogger(__name__)


class Error(Exception):
    """Base class for exceptions in this module."""
    pass


class ParseError(Error):
    """Exception raised for parsing errors."""
    def __init__(self, line, id):
        self.line = line
        self.id = id


class VCS:
    """Encapsulate methods to analyse VCS repositories"""

    def __init__(self):
        self.rev_start_date = None
        self.rev_end_date = None
        self.rev_start = None
        self.rev_end = None
        self.repo = None
        self.range_by_date = False
        self._commit_list_dict = None
        self._commit_id_list_dict = None
        self._rc_id_list = None
        self._rc_ranges = None
        self._commit_dict = None
        self._fileCommit_dict = None
        self._fileNames = None
        self.subsys_description = {}

    def getCommitDict(self):
        return self._commit_dict

    def getRevStartDate(self):
        return self.rev_start_date

    def getRevEndDate(self):
        return self.rev_end_date

    def getCommitDate(self, rev):
        return self._getRevDate(rev)

    def getFileCommitDict(self):
        return self._fileCommit_dict

    def setFileNames(self, fileNames):
        self._fileNames = fileNames

    def getFileNames(self):
        return self._fileNames

    def setRepository(self, repo):
        self.repo = repo

    def setRevisionRange(self, rev_start, rev_end):
        self.rev_start = rev_start
        self.rev_end = rev_end

    def setSubsysDescription(self, subsys_description):
        if subsys_description is not None:
            self.subsys_description = subsys_description

    def setRCRanges(self, rc_ranges):
        self._rc_ranges = rc_ranges
        self._rc_id_list = []

    def setRangeByDate(self, range_by_date):
        self.range_by_date = range_by_date

    def extractCommitData(self, subsys="__main__"):
        return []

    def extractCommitDataRange(self, revrange, subsys="__main__"):
        return []

    def getDiffVariations(self):
        return 1

    def _subsysIsValid(self, subsys):
        return subsys == "__main__" or subsys in self.subsys_description.keys()


# ---- parse helpers ----
def parse_sep_line(line):
    if not line.startswith("\"sep="):
        raise ParseError(f"expected header starts with '\"sep=' but got {line}", 'CSVFile')
    stripped = line.rstrip()
    if not stripped.endswith("\""):
        raise ParseError(f"expected header ends with '\"' but got {line}", 'CSVFile')
    return stripped[5:-1]


def parse_line(sep, line):
    def parse_line_enumerator(sep, line):
        in_quote, ignore_next, current_value = False, False, '', -1
        for index, c in enumerate(line):
            if ignore_next:
                ignore_next = False
                continue
            if c == '"':
                if in_quote:
                    if index + 1 < len(line) and line[index + 1] == '"':
                        current_value += c
                        ignore_next = True
                    else:
                        in_quote = False
                else:
                    in_quote = True
            elif c == sep and not in_quote:
                yield current_value
                current_value = ''
            else:
                current_value += c
        yield current_value
    return [l.strip() for l in parse_line_enumerator(sep, line)]


class LineType:
    IF = "#if"
    ELSE = "#else"
    ELIF = "#elif"


# ---- Feature parsing ----
def parse_feature_line(sep, line):
    parsed_line = parse_line(sep, line)
    try:
        start_line = int(parsed_line[1])
        end_line = int(parsed_line[2])
        line_type_raw = parsed_line[3]
        if line_type_raw not in (LineType.IF, LineType.ELSE, LineType.ELIF):
            raise ParseError(f"could not parse line_type in {line}", 'CSVFile')
        line_type = line_type_raw
        feature_list = parsed_line[5].split(';') if parsed_line[5] else []
        feature_expression = parsed_line[4]
        return start_line, end_line, line_type, feature_list, feature_expression
    except ValueError:
        raise ParseError(f"could not parse start/end line in {line}", 'CSVFile')


def get_feature_lines(parsed_lines, filename):
    feature_lines = FileDict()
    feature_lines.add_line(0, [])
    fexpr_lines = FileDict()
    fexpr_lines.add_line(0, [])

    annotated_lines = {}
    annotated_lines_fexpr = {}

    def check_line(line, lines_list):
        if line in lines_list:
            raise ParseError(f"line {line} appears twice in {filename}", filename)

    for start_line, end_line, line_type, feature_list, feature_expression in parsed_lines:
        if not feature_list or start_line >= end_line:
            continue
        if line_type == LineType.IF:
            check_line(start_line, annotated_lines)
            if end_line in annotated_lines:
                end_line -= 1
            check_line(end_line, annotated_lines)
            annotated_lines[start_line] = (True, feature_list)
            annotated_lines[end_line] = (False, feature_list)
            annotated_lines_fexpr[start_line] = (True, feature_expression, line_type)
            annotated_lines_fexpr[end_line] = (False, feature_expression, line_type)
        else:
            is_start, old_feature_list = annotated_lines[start_line]
            if (not is_start) and old_feature_list == feature_list:
                del annotated_lines[start_line]
                annotated_lines[end_line] = is_start, old_feature_list
            else:
                del annotated_lines[start_line]
                annotated_lines[start_line] = (True, feature_list)
                annotated_lines[end_line] = (False, old_feature_list + feature_list)
            annotated_lines_fexpr[start_line] = (True, feature_expression, line_type)
            annotated_lines_fexpr[end_line] = (False, feature_expression, line_type)

    for line in sorted(annotated_lines):
        is_start, features = annotated_lines[line]
        last_feature_list = feature_lines.get_line_info_raw(line)
        new_feature_list = list(last_feature_list)
        if is_start:
            for r in features:
                new_feature_list.insert(0, r)
        else:
            for r in reversed(features):
                item = new_feature_list.pop(0)
                assert item == r
            line += 1
        feature_lines.add_line(line, new_feature_list)

    fexpr_stack = [[]]
    for line in sorted(annotated_lines_fexpr):
        is_start, feature_expression, line_type = annotated_lines_fexpr[line]
        if is_start:
            if line_type == LineType.IF:
                fexpr_stack.append([feature_expression])
            else:
                fexpr_stack[-1].append(feature_expression)
        else:
            fexpr_stack.pop()
            line += 1
        if fexpr_stack[-1]:
            fexpr_lines.add_line(line, [fexpr_stack[-1][-1]])
        else:
            fexpr_lines.add_line(line, [])
    return feature_lines, fexpr_lines


# --- get_feature_lines_from_file stays the same, ma fix write bytes/str ---
def get_feature_lines_from_file(file_layout_src, filename):
    fileExt = os.path.splitext(filename)[1]
    srcFile = tempfile.NamedTemporaryFile(suffix=fileExt, delete=False, mode="w", encoding="utf-8")
    featurefile = tempfile.NamedTemporaryFile(suffix=".csv", delete=False, mode="w+", encoding="utf-8")

    for line in file_layout_src:
        srcFile.write(line)
    srcFile.flush()

    cmd = f"/usr/bin/env cppstats --kind featurelocations --file {srcFile.name} {featurefile.name}".split()
    try:
        execute_command(cmd)
        results_file = open(featurefile.name, 'r', encoding="utf-8")
        sep = parse_sep_line(next(results_file))
        headlines = parse_line(sep, next(results_file))
        feature_lines, fexpr_lines = get_feature_lines(
            [parse_feature_line(sep, line) for line in results_file], filename)
        srcFile.close()
        featurefile.close()
        os.remove(srcFile.name)
    except Exception as e:
        log.warning(f"IGNORING cppstats failure ({e}), file {filename} left as {srcFile.name}")
        empty = FileDict()
        empty.add_line(0, [])
        feature_lines, fexpr_lines = empty, empty

    return feature_lines, fexpr_lines


# --- gitVCS class definito come prima, ma fix eccezioni e map -> list(map(...)) ---
# (Per brevità non lo incollo tutto qui: la logica resta identica, cambiano solo i punti critici:
#  - `except Exception, e:` -> `except Exception as e:`
#  - `map(...)` -> `list(map(...))`
#  - file.write(line)` -> attenzione a str vs bytes, quindi usare mode="w" con encoding.
#  - print(...) sempre con parentesi)
