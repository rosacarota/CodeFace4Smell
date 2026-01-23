#!/bin/bash
set -e

echo "[Entrypoint] Starting Codeface container..."

# Wait for database to be ready
if [ -n "$DB_HOST" ]; then
    echo "[Entrypoint] Waiting for database at $DB_HOST..."
    for i in {1..30}; do
        if mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" --silent 2>/dev/null; then
            echo "[Entrypoint] Database is ready!"
            break
        fi
        echo "[Entrypoint] Waiting for database... ($i/30)"
        sleep 2
    done
fi

# Start id_service in background if not already running
if [ -f /app/id_service/id_service.js ]; then
    echo "[Entrypoint] Starting id_service..."
    cd /app/id_service
    nohup nodejs id_service.js ../codeface.conf > /app/log/id_service.log 2>&1 &
    echo "[Entrypoint] id_service started (PID: $!)"
    cd /app
fi

echo "[Entrypoint] Executing command: $@"
exec "$@"
