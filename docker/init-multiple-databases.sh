#!/bin/bash
# =============================================================================
# init-multiple-databases.sh
# Auto-creates multiple PostgreSQL databases from POSTGRES_MULTIPLE_DATABASES
# env var (comma-separated list).
#
# This script is run once when the Postgres container first starts
# (via /docker-entrypoint-initdb.d/).
#
# Environment variable format:
#   POSTGRES_MULTIPLE_DATABASES="auth_db,user_db,product_db,..."
# =============================================================================

set -e
set -u

function create_user_and_database() {
    local database=$1
    echo "  Creating database '$database'"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
        SELECT 'CREATE DATABASE $database'
        WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$database')\gexec
        GRANT ALL PRIVILEGES ON DATABASE $database TO $POSTGRES_USER;
EOSQL
}

if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
    echo "=== Creating multiple databases: $POSTGRES_MULTIPLE_DATABASES ==="
    for db in $(echo "$POSTGRES_MULTIPLE_DATABASES" | tr ',' ' '); do
        create_user_and_database "$db"
    done
    echo "=== All databases created successfully ==="
fi
