#!/usr/bin/env bash
set -euo pipefail

echo "[DB] Provisioning Codeface database (MySQL/MariaDB)"

# 0. Cleanup eventuali mysqld rimasti attivi
if pgrep mysqld >/dev/null; then
  echo "[DB] ⚠️ Found leftover mysqld process, killing..."
  sudo pkill -9 mysqld || true
  sudo rm -f /var/run/mysqld/mysqld.pid /var/run/mysqld/mysqld.sock || true
fi

# 1. Avvia il servizio MySQL/MariaDB
echo "[DB] Starting MySQL/MariaDB..."
if systemctl list-unit-files | grep -q mariadb.service; then
  sudo systemctl start mariadb || true
else
  sudo systemctl start mysql || true
fi

# 2. Attendi che il server sia pronto (max 30 secondi)
echo "[DB] Waiting for MySQL/MariaDB to become available..."
READY=false
for i in {1..30}; do
  if sudo mysqladmin ping --silent 2>/dev/null; then
    READY=true
    echo "[DB] ✅ MySQL/MariaDB is ready."
    break
  fi
  sleep 1
done

# 3. Se non parte, reset datadir e reinizializza
if [ "$READY" = false ]; then
  echo "[DB] ❌ MySQL/MariaDB not responding, resetting datadir..."
  if systemctl list-unit-files | grep -q mariadb.service; then
    sudo systemctl stop mariadb || true
  else
    sudo systemctl stop mysql || true
  fi
  sudo rm -rf /var/lib/mysql/*

  if command -v mysqld >/dev/null 2>&1; then
    sudo mysqld --initialize-insecure --user=mysql
  fi

  if systemctl list-unit-files | grep -q mariadb.service; then
    sudo systemctl start mariadb
  else
    sudo systemctl start mysql
  fi

  for i in {1..20}; do
    if sudo mysqladmin ping --silent 2>/dev/null; then
      echo "[DB] ✅ MySQL/MariaDB reset and ready."
      break
    fi
    sleep 1
  done
fi

# 4. Fix autenticazione root (necessario su Ubuntu/MariaDB moderni)
echo "[DB] Fixing root authentication..."
if mysql --version | grep -qi "MariaDB"; then
  # MariaDB → usa SET PASSWORD
  sudo mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('root');"
else
  # MySQL → usa ALTER USER con plugin mysql_native_password
  sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';"
fi
sudo mysql -e "FLUSH PRIVILEGES;"

# 5. Imposta password per root e crea DB/utente
echo "[DB] Setting root password and creating databases/users..."
mysql -uroot -proot <<EOF
CREATE DATABASE IF NOT EXISTS codeface DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS codeface_testing DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'codeface'@'localhost' IDENTIFIED BY 'codeface';
GRANT ALL PRIVILEGES ON codeface.* TO 'codeface'@'localhost';
GRANT ALL PRIVILEGES ON codeface_testing.* TO 'codeface'@'localhost';
FLUSH PRIVILEGES;
EOF

# 6. Imposta max_allowed_packet persistente
echo "[DB] Configuring max_allowed_packet=256M..."
sudo bash -c 'echo -e "[mysqld]\nmax_allowed_packet = 256M" > /etc/mysql/conf.d/99-codeface.cnf'

# 7. Individua schema
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

# 8. Import schema in codeface
echo "[DB] Import schema in 'codeface'..."
mysql -ucodeface -pcodeface codeface < "$DATAMODEL"

# 9. Import schema in codeface_testing
echo "[DB] Import schema in 'codeface_testing'..."
mysql -uroot -proot codeface_testing <<EOF
DROP TABLE IF EXISTS author_commit_stats_view;
DROP TABLE IF EXISTS revisions_view;
DROP TABLE IF EXISTS per_person_cluster_statistics_view;
DROP TABLE IF EXISTS cluster_user_pagerank_view;
DROP TABLE IF EXISTS per_cluster_statistics_view;
DROP TABLE IF EXISTS pagerank_view;
EOF

TMPFILE=$(mktemp /tmp/codeface_testing.XXXXXX.sql)
sed 's/`codeface`/`codeface_testing`/g' "$DATAMODEL" > "$TMPFILE"
mysql -ucodeface -pcodeface codeface_testing < "$TMPFILE"
rm -f "$TMPFILE"

# 10. Riavvia con la nuova config
echo "[DB] Ensuring MySQL/MariaDB is running with new config..."
if systemctl list-unit-files | grep -q mariadb.service; then
  sudo systemctl enable mariadb || true
  sudo systemctl restart mariadb || true
else
  sudo systemctl enable mysql || true
  sudo systemctl restart mysql || true
fi

echo "[DB] ✅ Database provisioning completed."
