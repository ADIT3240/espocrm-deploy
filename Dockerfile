FROM php:8.2-apache

# Install required system libraries and PHP extensions
RUN apt-get update && apt-get install -y \
        libzip-dev \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libonig-dev \
        libxml2-dev \
        default-mysql-client \
        unzip \
        libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install mysqli pdo_mysql zip gd intl bcmath \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*


# Allow .htaccess usage globally
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Set DocumentRoot to the 'public' folder
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Create an alias for the 'client' directory
RUN echo "Alias /client/ /var/www/html/client/" >> /etc/apache2/sites-available/000-default.conf

# Copy all project files to Apache root
COPY . /var/www/html/

# Set working directory
WORKDIR /var/www/html/

# Fix permissions for 'data' folder
RUN chown -R www-data:www-data /var/www/html/data \
    && find /var/www/html/data -type d -exec chmod 775 {} + \
    && find /var/www/html/data -type f -exec chmod 664 {} +

# Expose port 80
EXPOSE 80


