#!/bin/bash

# Update the system
apt update

# Install Apache
apt install apache2 -y

# Install MySQL
apt install mysql-server -y

# Install PHP and required modules
apt install php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y

# Restart Apache service
systemctl restart apache2

# Download and configure WordPress
apt install curl -y
curl -O https://wordpress.org/latest.tar.gz
tar -zxvf latest.tar.gz
cp -R wordpress/* /var/www/html/
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

# Prompt for MySQL details
read -s -p "Enter MySQL root password: " MYSQL_ROOT_PASSWORD
echo ""
read -p "Enter WordPress database name: " MYSQL_DB_NAME
read -p "Enter WordPress database user: " MYSQL_USER
read -s -p "Enter password for WordPress database user: " MYSQL_USER_PASSWORD
echo ""

# Create MySQL database and user for WordPress
mysql -u root -p$MYSQL_ROOT_PASSWORD <<EOF
CREATE DATABASE $MYSQL_DB_NAME;
CREATE USER '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_USER_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DB_NAME.* TO '$MYSQL_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

# Configure wp-config.php file
mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i "s/database_name_here/$MYSQL_DB_NAME/g" /var/www/html/wp-config.php
sed -i "s/username_here/$MYSQL_USER/g" /var/www/html/wp-config.php
sed -i "s/password_here/$MYSQL_USER_PASSWORD/g" /var/www/html/wp-config.php

# Set appropriate file permissions
chown www-data:www-data /var/www/html/wp-config.php
chmod 640 /var/www/html/wp-config.php

# Install the All-in-One WP Migration plugin
wget -O /var/www/html/wp-content/plugins/all-in-one-wp-migration.zip https://downloads.wordpress.org/plugin/all-in-one-wp-migration.7.75.zip
unzip /var/www/html/wp-content/plugins/all-in-one-wp-migration.zip -d /var/www/html/wp-content/plugins/
rm /var/www/html/wp-content/plugins/all-in-one-wp-migration.zip
 chown -R www-data:www-data /var/www/html/wp-content/plugins/all-in-one-wp-migration

# Install the All-in-One WP Migration Unlimited Extension plugin
wget -O /var/www/html/wp-content/plugins/all-in-one-wp-migration-unlimited-extension.zip http://cct.com.tm/wp-cntent/uploads/all-in-one-wp-migration-unlimited-extension.2.49.zip
unzip /var/www/html/wp-content/plugins/all-in-one-wp-migration-unlimited-extension.zip -d /var/www/html/wp-content/plugins/
rm /var/www/html/wp-content/plugins/all-in-one-wp-migration-unlimited-extension.zip
chown -R www-data:www-data /var/www/html/wp-content/plugins/all-in-one-wp-migration-unlimited-extension

# Clean up
rm latest.tar.gz
rm -rf wordpress/

echo "Veni, vidi, vici - Пришел, увидел, победил!"
