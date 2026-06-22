FROM php:8.2-apache

# Enable Apache mod_rewrite (required by Slim's .htaccess)
RUN a2enmod rewrite

# Install PDO MySQL extension and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    default-mysql-client \
    unzip \
    git \
    && docker-php-ext-install pdo pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files and install dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Copy application source
COPY public/ ./public/
COPY src/ ./src/
COPY sql/ ./sql/
COPY setup-db.php ./

# Configure Apache to use public/ as the document root
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf \
    && sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/apache2.conf

# Allow .htaccess overrides in the public directory
RUN printf '<Directory /var/www/html/public>\n    AllowOverride All\n    Require all granted\n</Directory>\n' \
    > /etc/apache2/conf-available/allow-override.conf \
    && a2enconf allow-override

# Copy and make entrypoint executable
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
