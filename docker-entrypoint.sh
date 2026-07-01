#!/bin/sh
set -e

echo "Removing .env to force reading from environment..."
rm -f /app/.env

echo "Clearing config cache..."
php artisan config:clear
php artisan cache:clear

echo "Waiting for MySQL..."
until php -r "new PDO('mysql:host=${DB_HOST};port=${DB_PORT:-3306};dbname=${DB_DATABASE}', '${DB_USERNAME}', '${DB_PASSWORD}');" 2>/dev/null; do
  echo "Retrying in 2s..."
  sleep 2
done

echo "Running migrations..."
php artisan migrate --force

echo "Starting server..."
exec php artisan serve --host=0.0.0.0 --port=8000
