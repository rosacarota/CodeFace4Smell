#!/bin/sh

# echo "Providing codeface python"

# sudo pip install --upgrade -q setuptools
# sudo pip install --upgrade -q mock

# # Only development mode works
# # install fails due to R scripts accessing unbundled resources!
# # TODO Fix the R scripts
# sudo python2.7 setup.py -q develop

#echo "Providing codeface python"

# ✅ Installa Python 2.7 e pip (Ubuntu 20.04 non lo include di default)
#sudo apt-get update -qq
#sudo apt-get install -y python2 python2-dev curl

# ✅ Installa pip per Python 2.7
#curl -sS https://bootstrap.pypa.io/pip/2.7/get-pip.py | sudo python2

# ✅ Installa le librerie richieste da setup.py e python_requirements.txt
#sudo pip2 install --upgrade setuptools
#sudo pip2 install progressbar PyYAML python-ctags MySQL-python

# ✅ Installazione di codeface in modalità sviluppo (globale)
#cd /vagrant
#sudo python2 setup.py develop

#echo "✅ Python 2.7 environment for Codeface is ready"
#!/usr/bin/env bash
set -euo pipefail

echo "[PY] Provisioning Codeface (Python3)"

# 1. Installa Python3 + toolchain base
sudo apt-get update -qq
sudo apt-get install -y python3 python3-pip python3-dev build-essential

# 2. Aggiorna pip + setuptools + wheel + importlib-metadata (fix bug EntryPoints)
sudo -H python3 -m pip install --upgrade pip setuptools wheel importlib-metadata

# 3. Dipendenze aggiuntive richieste da alcuni pacchetti
sudo -H pip3 install --upgrade testresources

# 4. Driver MySQL compatibile con Python3
#    (MySQL-python non esiste più → usiamo PyMySQL)
sudo -H pip3 install --upgrade pymysql

# 5. Installa tutte le dipendenze del progetto
if [ -f /vagrant/python_requirements.txt ]; then
  echo "[PY] Installing project requirements..."
  sudo -H pip3 install -r /vagrant/python_requirements.txt
else
  echo "[PY] ⚠️ WARNING: requirements file not found!"
fi

# 6. Installa Codeface in modalità "editable" (così i cambiamenti locali sono visibili)
cd /vagrant
sudo -H pip3 install -e .

echo "[PY] ✅ Codeface Python environment ready"
