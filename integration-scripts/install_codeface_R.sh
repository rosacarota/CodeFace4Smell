#!/usr/bin/env bash
set -euo pipefail

echo "[R] preparo cache condivisa /opt/Rlibs e configurazione globale"
sudo mkdir -p /etc/R /opt/Rlibs
sudo chown -R vagrant:vagrant /opt/Rlibs

# Rprofile.site: /opt/Rlibs deve essere PRIMA in .libPaths() per ogni chiamata R
sudo tee /etc/R/Rprofile.site >/dev/null <<'EOF'
.libPaths(unique(c("/opt/Rlibs", .libPaths())))
options(repos = c(CRAN = "https://cloud.r-project.org"))
EOF

# Variabili d'ambiente (persistenti)
echo 'export R_LIBS_USER=/opt/Rlibs' | sudo tee /etc/profile.d/rlibs.sh >/dev/null
echo 'export R_LIBS_SITE=/opt/Rlibs' | sudo tee -a /etc/profile.d/rlibs.sh >/dev/null
sudo bash -lc 'grep -q "^R_INSTALL_STAGED" /etc/environment || echo "R_INSTALL_STAGED=false" >> /etc/environment'

echo "[R] install dipendenze di sistema specifiche per pacchetti R"
sudo apt-get update -y
sudo apt-get install -y \
  r-base r-base-dev \
  libxml2-dev libssl-dev libcurl4-openssl-dev libmysqlclient-dev \
  libpng-dev libgraphviz-dev libcairo2-dev libxt-dev libz-dev \
  libprotobuf-dev protobuf-compiler libjq-dev libssh2-1-dev libx11-dev \
  libharfbuzz-dev libfribidi-dev libfreetype6-dev libfontconfig1-dev \
  libjpeg-dev libtiff5-dev \
  libgit2-dev \
  default-jre default-jdk \
  wordnet \
  git graphviz

# WordNet: variabili d'ambiente per il pacchetto R 'wordnet'
echo 'export WNHOME=/usr/share/wordnet'           | sudo tee /etc/profile.d/wordnet.sh >/dev/null
echo 'export WNSEARCHDIR=/usr/share/wordnet/dict' | sudo tee -a /etc/profile.d/wordnet.sh >/dev/null
sudo chmod +x /etc/profile.d/wordnet.sh

# Configura Java per rJava
sudo R CMD javareconf

# Compilazioni più rapide in parallelo
echo "MAKEFLAGS = -j$(nproc)" | sudo tee /etc/R/Makevars.site >/dev/null

echo "[R] installo i pacchetti da packages.R usando la cache"
# pulizia preventiva di eventuali lock temporanei
rm -rf /opt/Rlibs/00LOCK* /opt/Rlibs/*/00LOCK* || true

# eseguo come utente vagrant, con la cache configurata esplicitamente
sudo -u vagrant env R_LIBS_USER=/opt/Rlibs R_LIBS_SITE=/opt/Rlibs \
  R --vanilla --no-save --no-restore -q -f /vagrant/packages.R
