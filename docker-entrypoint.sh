#!/bin/sh
set -e

echo "Creating .env from Railway environment..."
cat > /app/.env << EOF
APP_NAME=Laravel
APP_ENV=${APP_ENV:-production}
APP_KEY=${APP_KEY}
APP_DEBUG=${APP_DEBUG:-false}
APP_URL=${APP_URL:-http://localhost}

DB_CONNECTION=mysql
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT:-3306}
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}

SESSION_DRIVER=database
CACHE_STORE=database
EOF

php artisan config:clear

echo "Waiting for MySQL..."
until php -r "new PDO('mysql:host=${DB_HOST};port=${DB_PORT:-3306};dbname=${DB_DATABASE}', '${DB_USERNAME}', '${DB_PASSWORD}');" 2>/dev/null; do
  echo "Retrying in 2s..."
  sleep 2
done

php artisan migrate --force

# Chạy SSR Node server ở background (port 13714 là default của Inertia SSR)
echo "Starting SSR server..."
node /app/bootstrap/ssr/ssr.js &

echo "Starting Laravel..."
exec php artisan serve --host=0.0.0.0 --port=8000
