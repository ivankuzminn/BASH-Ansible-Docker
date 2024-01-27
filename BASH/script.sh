#!/bin/bash
   
abort()
{
    echo >&2 '
***************
*** ABORTED ***
***************
'
    echo "An error occurred. Exiting..." >&2
    exit 1
    cd /root
    ./script.sh
}

trap 'abort' 0

set -e
   
# Обновление системы
sudo apt upgrade -y
touch /root/script.log

#git скачивание файлов

mkdir /root/bash
cd /root/bash
wget https://raw.githubusercontent.com/ivankuzminn/BASH-Ansible-Docker/main/BASH/ports.conf
wget https://raw.githubusercontent.com/ivankuzminn/BASH-Ansible-Docker/main/BASH/nginx-proxy.conf
wget https://raw.githubusercontent.com/ivankuzminn/BASH-Ansible-Docker/main/BASH/wordpress.conf
wget https://raw.githubusercontent.com/ivankuzminn/BASH-Ansible-Docker/main/BASH/wp-config.php
echo -e 'git OK' >> /root/script.log

# Установка nginx
sudo apt-get install nginx -y
sudo rm  /etc/nginx/sites-enabled/*
sudo rm /etc/nginx/sites-available/*
sudo cp /root/bash/nginx-proxy.conf  /etc/nginx/sites-available/nginx-proxy.conf
cd /etc/nginx/sites-enabled/
ln -s ../sites-available/nginx-proxy.conf nginx-proxy.conf
service nginx reload
echo -e 'NGINX OK' >> /root/script.log

# Установка apache2
sudo apt-get install apache2 -y
sudo rm /etc/apache2/sites-available/*
sudo cp /root/bash/ports.conf  /etc/apache2/ports.conf
sudo cp /root/bash/wordpress.conf  /etc/apache2/sites-available/wordpress.conf
ln -s /etc/apache2/sites-available/wordpress.conf /etc/apache2/sites-enabled/
sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
echo -e 'APACHE2 OK' >> /root/script.log

# Установка PHP
sudo apt install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip libapache2-mod-php php-mysql -y
sudo systemctl restart apache2
echo -e 'PHP OK' >> /root/script.log

# Установка MariaDB (MySQL)
sudo apt-get install mariadb-server -y
mysql -u root -p <<EOF
CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'wordpress';
CREATE DATABASE IF NOT EXISTS wordpress;
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';
ALTER DATABASE wordpress CHARACTER SET utf8 COLLATE utf8_general_ci;
FLUSH PRIVILEGES;
EXIT
EOF
echo -e 'MYSQL OK' >> /root/script.log

# Загрузка WordPress
wget https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
sudo cp -R wordpress/* /var/www/html
rm -rf wordpress latest.tar.gz
cp /root/bash/wp-config.php /var/www/html/wp-config.php
sudo chown -R www-data:www-data /var/www/html
sudo chmod 755 -R /var/www/
sudo rm /var/www/html/index.html
echo -e 'WP OK' >> /root/script.log

# Перезапуск служб
sudo service apache2 restart
sudo service nginx restart
sudo service mysql restart

#вывод && тест
echo -e ' ALL DONE' >> /root/script.log
echo  'DONE'
TOKEN="****************************"
CHAT_ID="*************************"
MESSAGE1="Script.sh отработал корректно. Успешный запрос wordpress"
MESSAGE2="Script.sh отработал некорректно. Запрос wordpress не удался"
URL1="https://api.telegram.org/bot$TOKEN/sendMessage"
URL2="http://localhost/wp-admin/install.php"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $URL2)
if [ $RESPONSE -eq 200 ]; then
    echo "Успешный запрос"
    curl -s -X POST $URL1 -d chat_id=$CHAT_ID -d text="$MESSAGE1"
else
    echo "Запрос не удался"
    curl -s -X POST $URL1 -d chat_id=$CHAT_ID -d text="$MESSAGE2"
fi



trap : 0

echo >&2 '
************
*** DONE *** 
************
'