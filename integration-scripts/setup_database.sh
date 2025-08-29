#!/usr/bin/env bash
set -euo pipefail

echo "[DB] Provisioning Codeface database (MySQL)"

# 1. Avvia il servizio MySQL
echo "[DB] Starting MySQL..."
sudo systemctl start mysql || true

# 2. Attendi che il server sia pronto (max 30 secondi)
echo "[DB] Waiting for MySQL to become available..."
READY=false
for i in {1..30}; do
  if mysqladmin -uroot -proot ping --silent 2>/dev/null; then
    READY=true
    echo "[DB] ✅ MySQL is ready."
    break
  fi
  sleep 1
done

# 3. Se non parte, reset datadir e reinizializza
if [ "$READY" = false ]; then
  echo "[DB] ❌ MySQL not responding, resetting datadir..."
  sudo systemctl stop mysql || true
  sudo rm -rf /var/lib/mysql/*
  sudo mysqld --initialize-insecure --user=mysql
  sudo systemctl start mysql

  for i in {1..20}; do
    if mysqladmin -uroot ping --silent 2>/dev/null; then
      echo "[DB] ✅ MySQL reset and ready."
      break
    fi
    sleep 1
  done
fi

# 4. Crea DB e utente
mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS codeface DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS codeface_testing DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -uroot -proot -e "CREATE USER IF NOT EXISTS 'codeface'@'localhost' IDENTIFIED WITH mysql_native_password BY 'codeface';"
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON codeface.* TO 'codeface'@'localhost';"
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON codeface_testing.* TO 'codeface'@'localhost';"
mysql -uroot -proot -e "FLUSH PRIVILEGES;"

# 5. Individua schema
if [ -f /vagrant/datamodel/codeface_schema.sql ]; then
  DATAMODEL="/vagrant/datamodel/codeface_schema.sql"
elif [ -f /vagrant/integration-scripts/codeface_schema.sql ]; then
  DATAMODEL="/vagrant/integration-scripts/codeface_schema.sql"
elif [ -f /vagrant/codeface_schema.sql ]; then
  DATAMODEL="/vagrant/codeface_schema.sql"
else
  echo "[DB] ❌ ERRORE: non trovo codeface_schema.sql"
  exit 1
fi

# 6. Import schema in codeface
echo "[DB] Import schema in 'codeface'..."
mysql -ucodeface -pcodeface codeface < "$DATAMODEL"

# 7. Import schema in codeface_testing (senza DEFINER e rinominato)
echo "[DB] Import schema in 'codeface_testing'..."
TMPFILE=$(mktemp /tmp/codeface_testing.XXXXXX.sql)
sed 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/; s/`codeface`/`codeface_testing`/g' "$DATAMODEL" > "$TMPFILE"
mysql -ucodeface -pcodeface codeface_testing < "$TMPFILE"
rm -f "$TMPFILE"

# 8. Mantieni MySQL attivo
echo "[DB] Ensuring MySQL is running..."
sudo systemctl enable mysql || true
sudo systemctl restart mysql || true

echo "[DB] ✅ Database provisioning completed."
