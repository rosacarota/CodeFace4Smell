#!/usr/bin/env bash
set -euo pipefail

CPPSTATS_VERSION="${CPPSTATS_VERSION:-0.8.4}"

echo "[CPP] Providing cppstats ${CPPSTATS_VERSION}"

mkdir -p vendor
cd vendor

# 1) Scarica ed estrai cppstats solo se non già presente
if [ ! -d "cppstats-${CPPSTATS_VERSION}" ]; then
  echo "[CPP] Downloading cppstats ${CPPSTATS_VERSION}..."
  wget --quiet "https://codeload.github.com/clhunsen/cppstats/tar.gz/v${CPPSTATS_VERSION}" -O /tmp/cppstats.tar.gz
  tar -xzf /tmp/cppstats.tar.gz
fi

CPPSTATS="$PWD/cppstats-${CPPSTATS_VERSION}"

# 2) Wrapper eseguibile per cppstats (lasciamo la shebang del progetto per scegliere py2/py3 da sé)
echo '#!/usr/bin/env bash' > "${CPPSTATS}/cppstats"
echo 'set -e' >> "${CPPSTATS}/cppstats"
echo 'DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"' >> "${CPPSTATS}/cppstats"
echo 'cd "$DIR"' >> "${CPPSTATS}/cppstats"
echo 'PYTHONPATH="${PYTHONPATH:-}:$DIR/lib" exec ./cppstats.py "$@"' >> "${CPPSTATS}/cppstats"
chmod +x "${CPPSTATS}/cppstats"

# 3) srcML (best-effort): non bloccare il build se l’archivio non è valido
echo "[CPP] Fetching srcML (best-effort)..."
mkdir -p "${CPPSTATS}/lib/srcml/linux"

# Prova a scaricare; se fallisce NON interrompere il provisioning
if wget --quiet "http://sdml.info/lmcrs/srcML-Ubuntu12.04-64.tar.gz" -O /tmp/srcML.tar.gz; then
  if file /tmp/srcML.tar.gz | grep -qi 'gzip compressed'; then
    # estrai; se fallisce NON bloccare
    tar -xzf /tmp/srcML.tar.gz || true
    # copia se è stata creata la cartella srcML
    if [ -d "$PWD/srcML" ]; then
      cp -rf "$PWD/srcML/"* "${CPPSTATS}/lib/srcml/linux/" || true
      echo "[CPP] srcML installed into ${CPPSTATS}/lib/srcml/linux/"
    else
      echo "[CPP] srcML extracted but 'srcML/' not found; skipping copy."
    fi
  else
    echo "[CPP] srcML archive is not gzip (probabile redirect/HTML). Skipping srcML install."
  fi
else
  echo "[CPP] srcML download failed. Skipping (cppstats resta utilizzabile, solo alcune feature potrebbero mancare)."
fi

# 4) Symlink del comando
sudo ln -sf "${CPPSTATS}/cppstats" /usr/local/bin/cppstats || true

cd ..
echo "[CPP] Done."
