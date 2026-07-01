#!/bin/sh
set -e

# Override .env với giá trị thực từ Railway environment
echo "Injecting environment variables..."
sed -i "s|DB_HOST=.*|DB_HOST=${DB_HOST}|" /app/.env
sed -i "s|DB_PORT=.*|DB_PORT=${DB_PORT}|" /app/.env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=${DB_DATABASE}|" /app/.env
sed -i "s|DB_USERNAME=.*|DB_USERNAME=${DB_USERNAME}|" /app/.env
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASSWORD}|" /app/.env

echo "Clearing config cache..."
php artisan config:clear

echo "Waiting for MySQL..."
until php -r "new PDO('mysql:host=${DB_HOST};port=${DB_PORT:-3306};dbname=${DB_DATABASE}', '${DB_USERNAME}', '${DB_PASSWORD}');" 2>/dev/null; do
  echo "Retrying in 2s..."
  sleep 2
done

echo "Running migrations..."
php artisan migrate --force

echo "Starting server..."
exec php artisan serve --host=0.0.0.0 --port=8000
