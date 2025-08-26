#!/usr/bin/env bash
set -euo pipefail

echo "[COMMON] Installing common binaries and libraries"

# Preseed MySQL root password to prevent prompt (anche se non usato, garantisce automazione)
echo "mysql-server mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password root" | sudo debconf-set-selections

# pacchetti aggiornati
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq update
sudo DEBIAN_FRONTEND=noninteractive \
  NEEDRESTART_MODE=a \
  apt-get -o Dpkg::Options::="--force-confdef" \
          -o Dpkg::Options::="--force-confold" \
          -o Dpkg::Options::="--force-unsafe-io" \
          -qqy install \
  texlive default-jdk \
  git subversion nodejs exuberant-ctags \
  sloccount graphviz doxygen \
  build-essential gcc gfortran pkg-config \
  libxml2 libxml2-dev libcurl4-openssl-dev \
  libcairo2-dev libxt-dev \
  libmysqlclient-dev \
  xorg-dev libx11-dev libgles2-mesa-dev libglu1-mesa-dev \
  libpoppler-dev libpoppler-glib-dev \
  libarchive13 astyle xsltproc screen \
  python3 python3-dev python3-pip python3-setuptools \
  python3-pkg-resources python3-numpy python3-matplotlib python3-lxml \
  libmagick++-dev libprotobuf-dev protobuf-compiler snapd

# ---- Installa MySQL senza autostart durante il provisioning ----
echo "[COMMON] Installing MySQL server & client (manual start)..."
sudo DEBIAN_FRONTEND=noninteractive \
  apt-get -o Dpkg::Options::="--force-confdef" \
          -o Dpkg::Options::="--force-confold" \
          -o Dpkg::Options::="--force-unsafe-io" \
          -qqy install --no-install-recommends \
  default-mysql-server default-mysql-client

# ---- Upgrade cmake (s2geometry richiede >= 3.18) ----
if ! command -v cmake >/dev/null || [ "$(cmake --version | awk 'NR==1{print $3}')" \< "3.18.0" ]; then
  echo "[COMMON] Upgrading cmake via snap"
  sudo snap install cmake --classic
  sudo ln -sf /snap/bin/cmake /usr/local/bin/cmake
fi

# ---- Installazione di Abseil (necessario per s2geometry) ----
if ! ldconfig -p | grep -q absl; then
  echo "[COMMON] Installing abseil-cpp (absl)"
  cd /tmp
  rm -rf abseil-cpp
  git clone --depth=1 https://github.com/abseil/abseil-cpp.git
  cd abseil-cpp
  mkdir build && cd build
  cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_CXX_STANDARD=17 ..
  make -j$(nproc)
  sudo make install
  sudo ldconfig
else
  echo "[COMMON] abseil-cpp già presente, skip."
fi

# ---- Installazione manuale di libs2 (Google s2geometry) ----
if ! ldconfig -p | grep -q libs2; then
  echo "[COMMON] Installing Google s2geometry (libs2)"
  cd /tmp
  rm -rf s2geometry
  git clone --depth=1 https://github.com/google/s2geometry.git
  cd s2geometry
  mkdir build && cd build
  cmake .. -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_CXX_STANDARD=17 -DBUILD_TESTS=OFF
  make -j$(nproc)
  sudo make install
  sudo ldconfig
else
  echo "[COMMON] libs2 già presente, skip."
fi

# ---- Avvia MySQL manualmente per evitare blocchi in fase di build ----
echo "[COMMON] Ensuring MySQL is enabled and running..."
sudo systemctl daemon-reload
sudo systemctl enable mysql || true
sudo systemctl restart mysql || true

echo "[COMMON] ✅ Done."
