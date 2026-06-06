#!/bin/bash
set -e
export PYTHONPATH=/app

# Extract host and port from DATABASE_URL
DB_HOST=$(echo "$DATABASE_URL" | sed -n 's/.*@\([^:]*\):.*/\1/p')
DB_PORT=$(echo "$DATABASE_URL" | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')

echo "Waiting for PostgreSQL at ${DB_HOST}:${DB_PORT}..."

# Wait for PostgreSQL using Python (single line)
RETRIES=30
until python -c "import socket; s=socket.socket(); s.settimeout(2); s.connect(('${DB_HOST}', int('${DB_PORT:-5432}'))); s.close()" 2>/dev/null; do
  RETRIES=$((RETRIES - 1))
  if [ $RETRIES -le 0 ]; then
    echo "ERROR: Could not connect to PostgreSQL at ${DB_HOST}:${DB_PORT}"
    exit 1
  fi
  sleep 2
done
echo "PostgreSQL is ready!"

# Run migrations
echo "Running database migrations..."
alembic upgrade head

# Run seed (safe to re-run)
echo "Seeding initial data..."
python -m scripts.seed_customers || true

# Start server
echo "Starting backend server..."
exec uvicorn app.main:app --host 0.0.0.0 --port 8000
