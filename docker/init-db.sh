#!/bin/bash
set -e

echo "[DB Init] Creating codeface_testing database..."

# Create testing database
mysql -uroot -p"$MYSQL_ROOT_PASSWORD" <<EOF
CREATE DATABASE IF NOT EXISTS codeface_testing DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON codeface_testing.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

echo "[DB Init] Importing schema into codeface database..."

# Import schema into main database
if [ -f /datamodel/codeface_schema.sql ]; then
    mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < /datamodel/codeface_schema.sql
    echo "[DB Init] Schema imported into codeface"
else
    echo "[DB Init] Schema file not found at /datamodel/codeface_schema.sql"
fi

echo "[DB Init] Importing schema into codeface_testing database..."

# Import schema into testing database (with database name replacement)
if [ -f /datamodel/codeface_schema.sql ]; then
    # Drop views first (they reference the database name)
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" codeface_testing <<EOF
DROP TABLE IF EXISTS author_commit_stats_view;
DROP TABLE IF EXISTS revisions_view;
DROP TABLE IF EXISTS per_person_cluster_statistics_view;
DROP TABLE IF EXISTS cluster_user_pagerank_view;
DROP TABLE IF EXISTS per_cluster_statistics_view;
DROP TABLE IF EXISTS pagerank_view;
EOF
    
    # Import schema with database name replacement
    sed 's/`codeface`/`codeface_testing`/g' /datamodel/codeface_schema.sql | \
        mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" codeface_testing
    
    echo "[DB Init] chema imported into codeface_testing"
else
    echo "[DB Init]  Schema file not found"
fi

echo "[DB Init] Database initialization completed!"
