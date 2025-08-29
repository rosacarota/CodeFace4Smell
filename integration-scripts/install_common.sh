#!/usr/bin/env bash
set -euo pipefail

echo "[COMMON] Installing common binaries and libraries"

# Preseed MySQL root password per evitare prompt
echo "mysql-community-server mysql-community-server/root-pass password root" | sudo debconf-set-selections
echo "mysql-community-server mysql-community-server/re-root-pass password root" | sudo debconf-set-selections

# Aggiorna pacchetti di base
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq update
sudo DEBIAN_FRONTEND=noninteractive \
  NEEDRESTART_MODE=a \
  apt-get -o Dpkg::Options::="--force-confdef" \
          -o Dpkg::Options::="--force-confold" \
          -o Dpkg::Options::="--force-unsafe-io" \
          -qqy install \
  wget gnupg lsb-release software-properties-common curl \
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
  libmagick++-dev libprotobuf-dev protobuf-compiler \
  libssl-dev zlib1g-dev

# ---- Installa MySQL (Oracle) ----
echo "[COMMON] Adding official MySQL APT repository..."
wget -q https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb -O /tmp/mysql-apt-config.deb
sudo DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/mysql-apt-config.deb
sudo apt-get -qq update

echo "[COMMON] Installing MySQL server & client (no autostart)..."
sudo DEBIAN_FRONTEND=noninteractive \
  NEEDRESTART_MODE=a \
  apt-get -qqy install --no-install-recommends mysql-server mysql-client

# Disabilita avvio automatico al provisioning
sudo systemctl disable mysql || true
sudo systemctl stop mysql || true

# ---- Upgrade cmake se serve (>= 3.18) ----
if ! command -v cmake >/dev/null || [ "$(cmake --version | awk 'NR==1{print $3}')" \< "3.18.0" ]; then
  echo "[COMMON] Upgrading cmake via Kitware repo"
  sudo apt-get -qqy remove cmake || true
  sudo apt-get -qqy install software-properties-common lsb-release wget gnupg

  wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc | \
    gpg --dearmor | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null

  echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null

  sudo apt-get -qq update
  sudo apt-get -qqy install cmake
fi

# ---- Compila Abseil ----
if ! ldconfig -p | grep -q absl; then
  echo "[COMMON] Installing abseil-cpp (absl)"
  cd /tmp
  rm -rf abseil-cpp
  git clone --depth=1 https://github.com/abseil/abseil-cpp.git
  cd abseil-cpp && mkdir build && cd build
  cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_CXX_STANDARD=17 ..
  make -j$(nproc)
  sudo make install
  sudo ldconfig
else
  echo "[COMMON] abseil-cpp già presente, skip."
fi

# ---- Compila s2geometry ----
if ! ldconfig -p | grep -q libs2; then
  echo "[COMMON] Installing Google s2geometry (libs2)"
  cd /tmp
  rm -rf s2geometry
  git clone --depth=1 https://github.com/google/s2geometry.git
  cd s2geometry && mkdir build && cd build
  cmake .. -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_CXX_STANDARD=17 -DBUILD_TESTS=OFF
  make -j$(nproc)
  sudo make install
  sudo ldconfig
else
  echo "[COMMON] libs2 già presente, skip."
fi

echo "[COMMON] ✅ Done."
