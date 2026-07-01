FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
    git curl zip unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo pdo_mysql

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

COPY composer.json composer.lock* ./
RUN composer install --optimize-autoloader --no-scripts --no-interaction --no-dev

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

COPY package.json package-lock.json* ./
RUN npm install

COPY . .

RUN npm run build

# Tạo .env đơn giản nhất có thể
RUN cp .env.example .env && \
    php artisan key:generate --force

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8000
CMD ["/usr/local/bin/docker-entrypoint.sh"]
