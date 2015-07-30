#!/bin/bash

set -ex

DEBIAN_FRONTEND=noninteractive apt-get install -qq mysql-server libmysql++-dev

cat <<EOF >> /etc/mysql/my.cnf
[client]
default-character-set=utf8

[mysql]
default-character-set=utf8


[mysqld]
collation-server = utf8_unicode_ci
init-connect='SET NAMES utf8'
character-set-server = utf8
innodb_flush_log_at_trx_commit=2
sync_binlog=0
EOF

service mysql restart

# Add users and such
echo "CREATE USER '${CIRCLECI_USER}'@'localhost'" | mysql -u root
echo "GRANT ALL PRIVILEGES ON *.* TO '${CIRCLECI_USER}'@'localhost' WITH GRANT OPTION" | mysql -u root
echo "CREATE USER 'circle'@'localhost'" | mysql -u root
echo "GRANT ALL PRIVILEGES ON *.* TO 'circle'@'localhost' WITH GRANT OPTION" | mysql -u root
echo "FLUSH PRIVILEGES" | mysql -u root
echo "CREATE DATABASE circle_test" | mysql -u root
