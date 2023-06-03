#!/bin/bash

# Update the system
sudo apt update
sudo apt upgrade -y

# Install Apache
sudo apt install apache2 -y

# Install MySQL
sudo apt install mysql-server -y

# Install PHP and required modules
sudo apt install php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y

# Restart Apache service
sudo systemctl restart apache2

# Download and configure WordPress
sudo apt install curl -y
sudo curl -O https://wordpress.org/latest.tar.gz
sudo tar -zxvf latest.tar.gz
sudo cp -R wordpress/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# Prompt for MySQL details
read -s -p "Enter MySQL root password: " MYSQL_ROOT_PASSWORD
echo ""
read -p "Enter WordPress database name: " MYSQL_DB_NAME
read -p "Enter WordPress database user: " MYSQL_USER
read -s -p "Enter password for WordPress database user: " MYSQL_USER_PASSWORD
echo ""

# Create MySQL database and user for WordPress
sudo mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE DATABASE $MYSQL_DB_NAME;
CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_USER_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DB_NAME.* TO '$MYSQL_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

# Configure wp-config.php file
sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo sed -i "s/database_name_here/$MYSQL_DB_NAME/g" /var/www/html/wp-config.php
sudo sed -i "s/username_here/$MYSQL_USER/g" /var/www/html/wp-config.php
sudo sed -i "s/password_here/$MYSQL_USER_PASSWORD/g" /var/www/html/wp-config.php

# Set appropriate file permissions
sudo chown www-data:www-data /var/www/html/wp-config.php
sudo chmod 640 /var/www/html/wp-config.php

# Install the All-in-One WP Migration plugin
sudo wget -O /var/www/html/wp-content/plugins/all-in-one-wp-migration.zip https://downloads.wordpress.org/plugin/all-in-one-wp-migration.7.75.zip
sudo unzip /var/www/html/wp-content/plugins/all-in-one-wp-migration.zip -d /var/www/html/wp-content/plugins/
sudo rm /var/www/html/wp-content/plugins/all-in-one-wp-migration.zip
sudo chown -R www-data:www-data /var/www/html/wp-content/plugins/all-in-one-wp-migration

# Install the All-in-One WP Migration Unlimited Extension plugin
sudo wget -O /var/www/html/wp-content/plugins/all-in-one-wp-migration-unlimited-extension.zip https://drive.google.com/uc?export=download&id=1ZDpiXeA5IxGoNrxAn1I3aq_8-j2B8eio
sudo unzip /var/www/html/wp-content/plugins/all-in-one-wp-migration-unlimited-extension.zip -d /var/www/html/wp-content/plugins/
sudo rm /var/www/html/wp-content/plugins/all-in-one-wp-migration-unlimited-extension.zip
sudo chown -R www-data:www-data /var/www/html/wp-content/plugins/all-in-one-wp-migration-unlimited-extension

# Clean up
sudo rm latest.tar.gz
sudo rm -rf wordpress/

echo "LAMP stack, WordPress, and All-in-One WP Migration plugins installation completed!"
