FROM php:8.2-apache

# Install required PHP extensions for EspoCRM
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache mod_rewrite
RUN a2enmod rewrite

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

# Expose port 80
EXPOSE 80
