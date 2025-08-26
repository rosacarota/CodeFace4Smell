#!/usr/bin/env bash
set -euo pipefail

echo "[DB] Provisioning Codeface database (MySQL)"

# 1. Avvia il servizio MySQL (se già attivo non fa nulla)
sudo systemctl start mysql || true

# 2. Attendi che il server sia pronto (max 30 secondi)
echo "[DB] Waiting for MySQL to become available..."
for i in {1..30}; do
  if mysqladmin -uroot -proot ping --silent; then
    echo "[DB] ✅ MySQL is ready."
    break
  fi
  sleep 1
done

# 3. Crea i database e l'utente (se non esistono già)
mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS codeface DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS codeface_testing DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -uroot -proot -e "CREATE USER IF NOT EXISTS 'codeface'@'localhost' IDENTIFIED WITH mysql_native_password BY 'codeface';"
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON codeface.* TO 'codeface'@'localhost';"
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON codeface_testing.* TO 'codeface'@'localhost';"
mysql -uroot -proot -e "FLUSH PRIVILEGES;"

# 4. Individua il file dello schema SQL
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

# 5. Importa lo schema in codeface
echo "[DB] Import schema in 'codeface'..."
mysql -ucodeface -pcodeface codeface <<EOF
SET FOREIGN_KEY_CHECKS=0;
SOURCE $DATAMODEL;
SET FOREIGN_KEY_CHECKS=1;
EOF

# 6. Importa lo stesso schema in codeface_testing (fedeltà all’originale, ma senza DEFINER)
echo "[DB] Import schema in 'codeface_testing'..."
sed 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/; s/`codeface`/`codeface_testing`/g' "$DATAMODEL" | \
mysql -ucodeface -pcodeface codeface_testing <<EOF
SET FOREIGN_KEY_CHECKS=0;
SOURCE /dev/stdin;
SET FOREIGN_KEY_CHECKS=1;
EOF

echo "[DB] ✅ Database provisioning completed."
