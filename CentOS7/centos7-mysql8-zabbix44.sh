#!/bin/bash

setenforce 0

rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm

rpm -Uvh https://repo.zabbix.com/zabbix/4.4/rhel/7/x86_64/zabbix-release-4.4-1.el7.noarch.rpm

yum -y install epel-release

yum makecache fast

yum -y install mysql-community-server

systemctl start mysqld

systemctl status mysqld

# change password. do not use '!' in password
grep "temporary password" /var/log/mysqld.log | sed "s|^.*localhost:.||" | xargs -i echo "/usr/bin/mysqladmin -u root password 'z4bbi#SIA' -p'{}'" | sudo bash

# set the same password as in previous step
cat << 'EOF' > ~/.my.cnf
[client]
user=root
password='z4bbi#SIA'
EOF

sleep 1

mysql -e 'CREATE DATABASE zabbix character set utf8 collate utf8_bin;'

# if ERROR 1396 (HY000): Operation CREATE USER failed for 'zabbix'@'127.0.0.1'
# then


# DROP USER "zabbix"@"127.0.0.1";
# DROP USER "zabbix"@"localhost";
# DROP USER "root"@"localhost";

# flush privileges;
# CREATE USER "zabbix"@"127.0.0.1" IDENTIFIED BY "z4bbi#SIA";
# CREATE USER "zabbix"@"localhost" IDENTIFIED BY "z4bbi#SIA";
# ALTER USER "zabbix"@"127.0.0.1" IDENTIFIED WITH mysql_native_password BY "z4bbi#SIA";
# ALTER USER "zabbix"@"localhost" IDENTIFIED WITH mysql_native_password BY "z4bbi#SIA";
# flush privileges;
# 
# mysql -h127.0.0.1 -uzabbix -p'z4bbi#SIA'
# mysql -hlocalhost -uzabbix -p'z4bbi#SIA'


mysql -e 'DROP USER "zabbix"@"127.0.0.1";'
mysql -e 'DROP USER "zabbix"@"localhost";'

mysql -e 'flush privileges;'

mysql -e 'CREATE USER "zabbix"@"127.0.0.1" IDENTIFIED BY "z4bbi#SIA";'
mysql -e 'CREATE USER "zabbix"@"localhost" IDENTIFIED BY "z4bbi#SIA";'

# from docker host
mysql -e 'CREATE USER "zabbix"@"172.17.0.10" IDENTIFIED BY "z4bbi#SIA";'
mysql -e 'CREATE USER "odbcuser"@"%" IDENTIFIED BY "z4bbi#SIA";'



# [Z3001] connection to database 'zabbix' failed: [2059] Authentication plugin 'caching_sha2_password' cannot be loaded: /usr/lib64/mysql/plugin/caching_sha2_password.so: cannot open shared object file: No such file or directory
mysql -e 'ALTER USER "zabbix"@"127.0.0.1" IDENTIFIED WITH mysql_native_password BY "z4bbi#SIA";'
mysql -e 'ALTER USER "zabbix"@"localhost" IDENTIFIED WITH mysql_native_password BY "z4bbi#SIA";'

<<<<<<< HEAD

# ERROR 1396 (HY000): Operation ALTER USER failed for 'root'@'%'

# for mysql monitoring using root from 127.0.0.1 while using 'skip_name_resolve=1'
mysql -e 'ALTER USER "root"@"%" IDENTIFIED WITH mysql_native_password BY "z4bbi#SIA";'

=======
# allow DB to be accessed from docker host
mysql -e 'ALTER USER "zabbix"@"172.17.0.10" IDENTIFIED WITH mysql_native_password BY "z4bbi#SIA";'
mysql -e 'ALTER USER "odbcuser"@"%" IDENTIFIED WITH mysql_native_password BY "z4bbi#SIA";'
>>>>>>> d2e095dfaa386d9e614c1437de25aeb93a48a8f6

# ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'identified by 'z4bbi#SIA'' at line 1
# assign privilages
mysql -e 'GRANT ALL ON zabbix.* TO "zabbix"@"127.0.0.1";'
mysql -e 'GRANT ALL ON zabbix.* TO "zabbix"@"localhost";'
mysql -e 'GRANT ALL ON z40.* TO "zabbix"@"10.133.253.43";'

<<<<<<< HEAD
# perfect user root to use together with 'skip_name_resolve=1'
DROP USER "root"@"localhost";
FLUSH PRIVILEGES;
CREATE USER "root"@"127.0.0.1" IDENTIFIED BY "z4bbi#SIA";
ALTER USER "root"@"127.0.0.1" IDENTIFIED WITH mysql_native_password BY "z4bbi#SIA";
FLUSH PRIVILEGES;
=======
# allow DB to be accessed from docker host
mysql -e 'GRANT ALL ON zabbix.* TO "zabbix"@"172.17.0.10";'
mysql -e 'GRANT ALL ON zabbix.* TO "odbcuser"@"%";'
>>>>>>> d2e095dfaa386d9e614c1437de25aeb93a48a8f6

mysql -e 'flush privileges;'


yum -y install zabbix-server-mysql zabbix-web-mysql zabbix-nginx-conf zabbix-agent

# insert schema
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql zabbix

# define server conf file
server=/etc/zabbix/zabbix_server.conf
grep "^DBPassword=" $server
if [ $? -eq 0 ]; then
sed -i "s/^DBPassword=.*/DBPassword=z4bbi#SIA/" $server #modifies already customized setting
else
ln=$(grep -n "DBPassword=" $server | egrep -o "^[0-9]+"); ln=$((ln+1)) #calculate the the line number after default setting
sed -i "`echo $ln`iDBPassword=z4bbi#SIA" $server #adds new line
fi

# determine the external ip in digital ocean
yum -y install bind-utils
connect=$(dig +short myip.opendns.com @resolver1.opendns.com)

# configure web server to listen on external IP
sed -i "s|^.*listen.*80.*$|listen 80;|1" /etc/nginx/conf.d/zabbix.conf 
sed -i "s|^.*server_name.*example.com.*$|server_name $connect;|1" /etc/nginx/conf.d/zabbix.conf

# set timezone
timezone=Europe/Riga
sed -i "s|^.*php_value.date.timezone.*$|php_value[date.timezone] = $timezone|" /etc/php-fpm.d/zabbix.conf

cat << 'EOF' > /etc/zabbix/web/zabbix.conf.php
<?php
// Zabbix GUI configuration file.
global $DB;

$DB['TYPE']     = 'MYSQL';
$DB['SERVER']   = '127.0.0.1';
$DB['PORT']     = '0';
$DB['DATABASE'] = 'zabbix';
$DB['USER']     = 'zabbix';
$DB['PASSWORD'] = 'z4bbi#SIA';

// Schema name. Used for IBM DB2 and PostgreSQL.
$DB['SCHEMA'] = '';

$ZBX_SERVER      = '127.0.0.1';
$ZBX_SERVER_PORT = '10051';
$ZBX_SERVER_NAME = '';

$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
EOF

setenforce 0
systemctl restart zabbix-agent zabbix-server nginx php-fpm
systemctl enable zabbix-agent zabbix-server nginx php-fpm
