# Build stage
FROM php:8.3-fpm-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    postgresql-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_pgsql zip gd

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files and install dependencies, do that ensures that the dependency installation layer is cached unless those files change
COPY composer.json composer.lock artisan ./
RUN composer install --no-dev --optimize-autoloader --no-interaction

COPY . .

# Set permissions for Laravel
RUN chown -R www-data:www-data storage bootstrap/cache

# Runtime stage
FROM php:8.3-fpm-alpine

# Install runtime dependencies
RUN apk add --no-cache libzip libpng libjpeg-turbo freetype postgresql-libs

# Copy PHP extensions and configs from builder
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# Copy application from builder
WORKDIR /var/www/html
COPY --from=builder /var/www/html ./

# Expose port for PHP-FPM
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]