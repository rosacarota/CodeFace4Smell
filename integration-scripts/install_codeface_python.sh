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
sudo apt-get install -y python3 python3-pip python3-dev build-essential git

# 2. Aggiorna pip + setuptools + wheel + importlib-metadata
sudo -H python3 -m pip install --upgrade pip setuptools wheel importlib-metadata

# 3. Dipendenze aggiuntive
sudo -H pip3 install --upgrade testresources pymysql

# 4. Installa tutte le dipendenze del progetto
if [ -f /vagrant/python_requirements.txt ]; then
  echo "[PY] Installing project requirements..."
  sudo -H pip3 install -r /vagrant/python_requirements.txt
else
  echo "[PY] ⚠️ WARNING: requirements file not found!"
fi

# 5. Installa Codeface in modalità editable moderna (PEP517)
cd /vagrant
echo "[PY] Installing Codeface with PEP517 (editable mode)..."
sudo -H pip3 install --use-pep517 -e .

# 6. Scarica e installa codeBlock (se non esiste già)
if [ ! -d /vagrant/codeBlock ]; then
  echo "[PY] Cloning codeBlock repository..."
  cd /vagrant
  git clone https://github.com/siemens/codeBlock.git
fi

echo "[PY] Installing codeBlock..."
cd /vagrant/codeBlock
sudo -H pip3 install --use-pep517 -e .
cd /vagrant

# 7. Verifica installazione di Codeface
echo "[PY] ✅ Checking Codeface installation..."
sudo -H pip3 show codeface || echo "[PY] ❌ Codeface non risulta installato!"

# 8. Verifica installazione di codeBlock
sudo -H pip3 show codeBlock || echo "[PY] ⚠️ codeBlock non risulta installato!"

# 9. Verifica comando codeface
if command -v codeface >/dev/null 2>&1; then
  echo "[PY] ✅ Codeface command available: $(command -v codeface)"
else
  echo "[PY] ❌ Codeface command NOT found in PATH!"
  exit 1
fi

# 10. Verifica metadata
python3 -c "import importlib.metadata; print('[PY] ✅ Codeface metadata version:', importlib.metadata.version('codeface'))" || \
  echo "[PY] ❌ importlib.metadata non trova Codeface!"

echo "[PY] ✅ Codeface Python environment ready"
