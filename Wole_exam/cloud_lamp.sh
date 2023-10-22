#!/bin/bash

# Check if Apache, MySQL, and PHP are already installed
if ! [ -x "$(command -v apache2)" ] || ! [ -x "$(command -v mysql)" ] || ! [ -x "$(command -v php)" ]; then
  # Update package repository
  sudo apt update -y

  # Install Apache, MySQL, and PHP
  sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql

  # Enable URL rewriting
  sudo a2enmod rewrite

  # Restart Apache
  sudo systemctl restart apache2
fi

# Install Git
if ! [ -x "$(command -v git)" ]; then
  sudo apt install -y git
fi

# Install Composer
if ! [ -x "$(command -v composer)" ]; then
  cd /usr/bin
  sudo apt install -y composer
fi

# Clone Laravel repository
LARAVEL_DIR="/var/www/laravel"
if [ ! -d "$LARAVEL_DIR" ]; then
  sudo git clone https://github.com/laravel/laravel.git "$LARAVEL_DIR"
fi

# Move into the Laravel directory
cd "$LARAVEL_DIR"

# Update Composer dependencies
echo "yes" | sudo composer update

# Create .env file
cp .env.example .env

# Edit the .env file
sed -i 's/APP_NAME=Laravel/APP_NAME=laravel/' .env
sed -i 's/APP_ENV=local/APP_ENV=production/' .env
sed -i 's/APP_DEBUG=true/APP_DEBUG=false/' .env
sed -i 's/APP_URL=http://localhost/APP_URL=http://your_domain_or_ip/' .env

# Generate the APP_KEY value
sudo php artisan key:generate

# Set permissions
sudo chown -R www-data storage bootstrap/cache

# Create Apache virtual host configuration
sudo touch /etc/apache2/sites-available/laravel.conf
sudo cat > /etc/apache2/sites-available/laravel.conf <<EOF
<VirtualHost *:80>
   ServerName laravel.example.com
   DocumentRoot $LARAVEL_DIR/public

   <Directory $LARAVEL_DIR/public>
      Options Indexes FollowSymLinks
      AllowOverride All
      Require all granted
   </Directory>

   ErrorLog \${APACHE_LOG_DIR}/laravel-error.log
   CustomLog \${APACHE_LOG_DIR}/laravel-access.log combined
</VirtualHost>
EOF

# Enable the site configuration
sudo a2ensite laravel.conf

# Disable the default Apache web page
sudo a2dissite 000-default.conf

# Restart Apache
sudo systemctl restart apache2

echo "Laravel application has been deployed."