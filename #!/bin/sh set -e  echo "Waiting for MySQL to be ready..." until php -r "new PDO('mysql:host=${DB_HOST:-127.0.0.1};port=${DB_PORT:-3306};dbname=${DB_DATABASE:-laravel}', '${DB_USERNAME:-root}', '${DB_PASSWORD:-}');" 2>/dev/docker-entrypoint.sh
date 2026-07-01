#!/bin/sh
set -e

echo "Waiting for MySQL to be ready..."
until php -r "new PDO('mysql:host=${DB_HOST:-127.0.0.1};port=${DB_PORT:-3306};dbname=${DB_DATABASE:-laravel}', '${DB_USERNAME:-root}', '${DB_PASSWORD:-}');" 2>/dev/null; do
  echo "MySQL not ready yet, retrying in 2s..."
  sleep 2
done

echo "Running migrations..."
php artisan migrate --force

echo "Starting server..."
exec php artisan serve --host=0.0.0.0 --port=8000
