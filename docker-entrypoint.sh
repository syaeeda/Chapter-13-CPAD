#!/bin/bash
set -e

echo "[entrypoint] Waiting for MySQL at ${DB_HOST}:${DB_PORT}..."

# Wait for MySQL to be ready (max 60 seconds)
for i in $(seq 1 60); do
    if mysqladmin ping -h "${DB_HOST}" -P "${DB_PORT}" \
        -u "${DB_USER}" -p"${DB_PASS}" --silent 2>/dev/null; then
        echo "[entrypoint] MySQL is ready!"
        break
    fi
    echo "[entrypoint] MySQL not ready yet (attempt $i/60)..."
    sleep 1
done

# Run database schema initialization
echo "[entrypoint] Running database schema setup..."
php setup-db.php || echo "[entrypoint] WARNING: Schema setup had issues (may already exist)."

# Start Apache
echo "[entrypoint] Starting Apache..."
exec "$@"
