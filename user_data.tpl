#!/bin/bash

# Editing /etc/needrestart/needrestart.conf to restart services that needs to be restarted after apt upgrade without waiting for user approval.
sed -i 's/#\$nrconf{restart} = '\''i'\'';/\$nrconf{restart} = '\''a'\'';/g' /etc/needrestart/needrestart.conf

# varaible will be populated by terraform template
export db_username=${db_username}
export db_user_password=${db_user_password}
export db_name=${db_name}
export db_rds_endpoint=${db_rds_endpoint}
export db_host=$(echo $db_rds_endpoint | cut -d ':' -f 1)
export admin_email='admin@abcd.com'
export instance_cnt=${instance_count}
export title="Sample Wordpress Site from Instance-$instance_cnt"
export wordpress_path="/var/www/html/wordpress$instance_cnt"

# update packages to latest
apt update -y
apt upgrade -y

# install LAMP server
apt install -y apache2
apt install -y php php-{pear,cgi,common,curl,mbstring,gd,mysql,bcmath,json,xml,intl,zip,imap,imagick}
apt install -y mysql-server

mysql -u $db_username -h $db_host --password=$db_user_password -e "create database $db_name"

# start apache server and enable it to run on startup
systemctl enable --now apache2

mkdir $wordpress_path

# install wordpress cli and setting up wordpress
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
wp core download --path=$wordpress_path --allow-root
wp config create --dbname=$db_name --dbuser=$db_username --dbpass=$db_user_password --dbhost=$db_rds_endpoint --path=$wordpress_path --allow-root --extra-php <<PHP
define( 'FS_METHOD', 'direct' );
define('WP_MEMORY_LIMIT', '128M');
PHP
wp core install --url=url --title=$title --admin_name=$db_username --admin_email=$admin_email --admin_password=$db_user_password --path=$wordpress_path --skip-email --allow-root


# enable .htaccess files in apache config using sed command
sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
a2enmod rewrite

# restart apache
systemctl restart apache2
