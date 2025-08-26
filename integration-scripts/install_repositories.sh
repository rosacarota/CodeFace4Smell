#!/bin/sh
set -euo pipefail

echo "[REPO] Updating package lists"
sudo apt-get update -qq

# Install essentials: solo software-properties-common (python-software-properties è obsoleto su Ubuntu 20.04)
sudo DEBIAN_FRONTEND=noninteractive apt-get -qqy install \
  software-properties-common \
  ca-certificates \
  curl \
  gpg

# Aggiunta del repository ufficiale CRAN per Ubuntu 20.04 (focal)
echo "[REPO] Adding official CRAN repository for R"
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9
echo "deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/" \
  | sudo tee /etc/apt/sources.list.d/cran.list

# Installazione di R
echo "[REPO] Installing R base"
sudo apt-get update -qq
sudo apt-get install -y r-base r-base-dev

# Aggiunta del repository Node.js (18 LTS stabile)
echo "[REPO] Adding Node.js repository (18 LTS)"
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# Installazione di Node.js
sudo apt-get install -y nodejs

# Update finale
sudo apt-get update -qq

echo "[REPO] ✅ Repositories setup completed."
