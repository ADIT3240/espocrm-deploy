# Base image
FROM php:8.2-apache

# Install system libraries and PHP extensions
RUN apt-get update && apt-get install -y \
        libzip-dev \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libonig-dev \
        libxml2-dev \
        unzip \
        libicu-dev \
        libpq-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_pgsql pdo_mysql zip gd intl bcmath exif \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Set PHP recommended values
RUN echo "max_execution_time=180" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "max_input_time=180" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "memory_limit=256M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "post_max_size=20M" >> /usr/local/etc/php/conf.d/custom.ini \
    && echo "upload_max_filesize=20M" >> /usr/local/etc/php/conf.d/custom.ini

    # Enable PHP error display and logging for debugging
RUN echo "display_errors=On" >> /usr/local/etc/php/conf.d/debug.ini \
    && echo "display_startup_errors=On" >> /usr/local/etc/php/conf.d/debug.ini \
    && echo "error_reporting=E_ALL" >> /usr/local/etc/php/conf.d/debug.ini \
    && echo "log_errors=On" >> /usr/local/etc/php/conf.d/debug.ini \
    && echo "error_log=/var/www/html/data/logs/php_error.log" >> /usr/local/etc/php/conf.d/debug.ini

# Create logs directory
RUN mkdir -p /var/www/html/data/logs \
    && chown -R www-data:www-data /var/www/html/data/logs \
    && chmod -R 775 /var/www/html/data/logs


# Allow .htaccess in EspoCRM public directory
RUN echo "<Directory /var/www/html/public>\n    AllowOverride All\n</Directory>" >> /etc/apache2/apache2.conf


# Set DocumentRoot to the 'public' folder
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Create an alias for the 'client' directory
RUN echo "Alias /client/ /var/www/html/client/" >> /etc/apache2/sites-available/000-default.conf

# Copy all project files to Apache root
COPY . /var/www/html/

# Set working directory
WORKDIR /var/www/html/

# Fix permissions for required directories
RUN chown -R www-data:www-data /var/www/html/data \
    && chown -R www-data:www-data /var/www/html/client/custom \
    && chown -R www-data:www-data /var/www/html/custom/Espo/Custom \
    && chown -R www-data:www-data /var/www/html/custom/Espo/Modules \
    && find /var/www/html/data -type d -exec chmod 775 {} + \
    && find /var/www/html/client/custom -type d -exec chmod 775 {} + \
    && find /var/www/html/custom/Espo/Custom -type d -exec chmod 775 {} + \
    && find /var/www/html/custom/Espo/Modules -type d -exec chmod 775 {} + \
    && find /var/www/html/data -type f -exec chmod 664 {} + \
    && find /var/www/html/client/custom -type f -exec chmod 664 {} + \
    && find /var/www/html/custom/Espo/Custom -type f -exec chmod 664 {} + \
    && find /var/www/html/custom/Espo/Modules -type f -exec chmod 664 {} +

# Expose port 80
EXPOSE 80
