FROM php:8.5-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy composer files
COPY composer.json composer.lock* ./

# Install PHP dependencies (skip dev dependencies)
RUN composer install --optimize-autoloader --no-scripts --no-interaction --no-dev

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package.json package-lock.json* ./

# Install npm dependencies
RUN npm install

# Copy application code
COPY . .

# Build frontend assets
RUN npm run build

# Generate Laravel key
RUN php artisan key:generate --force || true

# Expose port
EXPOSE 8000

# Start command
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
