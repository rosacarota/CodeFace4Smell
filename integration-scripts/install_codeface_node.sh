#!/usr/bin/env bash
set -euo pipefail

echo "[Node] Installazione id_service"

# Installa Node.js + npm se non già presenti
if ! command -v node >/dev/null 2>&1; then
  echo "[Node] Installo Node.js + npm..."
  sudo apt-get update -y
  sudo apt-get install -y nodejs npm
fi

# Verifica versioni
echo "[Node] Versione Node:"
node -v || true
echo "[Node] Versione NPM:"
npm -v || true

# Vai nella cartella id_service
cd /vagrant/id_service

# Installa le dipendenze da package.json
echo "[Node] Installo dipendenze da package.json..."
npm install --no-bin-links

# Ritorna nella root progetto
cd /vagrant

echo "[Node] ✅ id_service pronto."
