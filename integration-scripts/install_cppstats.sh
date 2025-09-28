#!/usr/bin/env bash
set -euo pipefail

CPPSTATS_VERSION="${CPPSTATS_VERSION:-0.8.4}"
CPPSTATS_DIR="/vagrant/vendor/cppstats-${CPPSTATS_VERSION}"

echo "[CPP] Installing cppstats ${CPPSTATS_VERSION}"

mkdir -p /vagrant/vendor
cd /vagrant/vendor

# 1) Clona il fork patchato se non già presente
if [ ! -d "cppstats-${CPPSTATS_VERSION}" ]; then
  echo "[CPP] Cloning forked cppstats..."
  git clone https://github.com/rosacarota/cppstats.git cppstats-${CPPSTATS_VERSION}
fi

# 2) Wrapper eseguibile per cppstats
cat > "${CPPSTATS_DIR}/cppstats.sh" <<'EOF'
#!/usr/bin/env bash
set -e
CPP_DIR="/vagrant/vendor/cppstats-0.8.4"
PYTHONPATH="$CPP_DIR" exec python3 -m cppstats.cppstats "$@"
EOF
chmod +x "${CPPSTATS_DIR}/cppstats.sh"

# 3) srcML (best-effort, opzionale)
echo "[CPP] Fetching srcML (best-effort)..."
mkdir -p "${CPPSTATS_DIR}/lib/srcml/linux"

if wget --quiet "http://sdml.info/lmcrs/srcML-Ubuntu12.04-64.tar.gz" -O /tmp/srcML.tar.gz; then
  if file /tmp/srcML.tar.gz | grep -qi 'gzip compressed'; then
    tar -xzf /tmp/srcML.tar.gz -C /tmp || true
    if [ -d "/tmp/srcML" ]; then
      cp -rf "/tmp/srcML/"* "${CPPSTATS_DIR}/lib/srcml/linux/" || true
      echo "[CPP] srcML installed into ${CPPSTATS_DIR}/lib/srcml/linux/"
    else
      echo "[CPP] srcML extracted but 'srcML/' not found; skipping copy."
    fi
  else
    echo "[CPP] srcML archive is not gzip. Skipping srcML install."
  fi
else
  echo "[CPP] srcML download failed. Skipping."
fi

# 4) Symlink del comando (sempre verso cppstats.sh)
sudo rm -f /usr/local/bin/cppstats
sudo ln -s "${CPPSTATS_DIR}/cppstats.sh" /usr/local/bin/cppstats

echo "[CPP] Done."
