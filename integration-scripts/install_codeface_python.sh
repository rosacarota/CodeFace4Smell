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

# Python3 + toolchain base
sudo apt-get update -qq
sudo apt-get install -y python3 python3-pip python3-dev build-essential

# Aggiorna pip + setuptools + wheel + importlib-metadata (fix EntryPoints bug)
sudo -H python3 -m pip install --upgrade pip setuptools wheel importlib-metadata

# Fix: installa testresources richiesto da launchpadlib
sudo -H pip3 install testresources

# Fix: forza l'uso di PyMySQL invece di MySQL-python (non compatibile con Py3)
sudo -H pip3 install pymysql

# Installa requirements dal file del progetto (assicurati che NON contenga MySQL-python)
sudo -H pip3 install -r /vagrant/python_requirements.txt

# Installa il progetto in modalità "editable" (globale)
cd /vagrant
sudo -H pip3 install -e .

echo "[PY] ✅ Codeface Python package installed"
