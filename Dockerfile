FROM php:8.1-apache

# Install required PHP extensions for EspoCRM
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache mod_rewrite (EspoCRM needs this)
RUN a2enmod rewrite

# Copy all project files to Apache root
COPY . /var/www/html/

# Set permissions for storage folders
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Set working directory
WORKDIR /var/www/html
