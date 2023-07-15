#!/bin/bash

# Update the system
sudo apt update
sudo apt upgrade -y

# Install NGINX
sudo apt install nginx -y

# Install MySQL
sudo apt install mysql-server -y

# Secure MySQL installation
sudo mysql_secure_installation

# Install PHP and required modules
sudo apt install php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y

# Configure PHP-FPM
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/7.4/fpm/php.ini
sudo systemctl restart php7.4-fpm

# Configure NGINX
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
sudo sed -i '/http {/a client_max_body_size 100M;' /etc/nginx/nginx.conf
sudo systemctl restart nginx

# Create a new NGINX server block for WordPress
sudo tee /etc/nginx/sites-available/wordpress <<EOF
server {
    listen 80;
    server_name your_domain.com;

    root /var/www/html;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
sudo systemctl restart nginx

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

# Set unique keys and salts in wp-config.php file
sudo curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> /var/www/html/wp-config.php

# Set appropriate file permissions
sudo chown www-data:www-data /var/www/html/wp-config.php
sudo chmod 640 /var/www/html/wp-config.php

# Install the All-in-One WP Migration plugin
sudo wget -O /var/www/html/wp-content/plugins/all-in-one-wp-migration.zip https://github.com/ servmask/wordpress-plugin/archive/master.zip
sudo unzip /var/www/html/wp-content/plugins/all-in-one-wp-migration.zip -d /var/www/html/wp-content/plugins/
sudo rm /var/www/html/wp-content/plugins/all-in-one-wp-migration.zip
sudo chown -R www-data:www-data /var/www/html/wp-content/plugins/all-in-one-wp-migration

# Clean up
sudo rm latest.tar.gz
sudo rm -rf wordpress/

echo "LEMP stack, WordPress, and All-in-One WP Migration plugins installation completed!"
