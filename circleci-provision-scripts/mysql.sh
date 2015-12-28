#!/bin/bash

function install_mysql_56() {
    {
            echo mysql-community-server mysql-community-server/data-dir select '';
            echo mysql-community-server mysql-community-server/root-pass password '';
            echo mysql-community-server mysql-community-server/re-root-pass password '';
            echo mysql-community-server mysql-community-server/remove-test-db select false;
    } | debconf-set-selections

    DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server-5.6

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
innodb_use_native_aio=0
EOF

    # start MySQL manually
    mysqld &
    sleep 5

    ## Add users and such
    echo "CREATE USER '${CIRCLECI_USER}'@'localhost'" | mysql -u root
    echo "GRANT ALL PRIVILEGES ON *.* TO '${CIRCLECI_USER}'@'localhost' WITH GRANT OPTION" | mysql -u root
    echo "CREATE USER 'circle'@'localhost'" | mysql -u root
    echo "GRANT ALL PRIVILEGES ON *.* TO 'circle'@'localhost' WITH GRANT OPTION" | mysql -u root
    echo "FLUSH PRIVILEGES" | mysql -u root
    echo "CREATE DATABASE circle_test" | mysql -u root
}
