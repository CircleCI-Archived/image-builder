#!/bin/bash

function configure_mysql() {
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
    sudo -u mysql mysqld &
    MYSQL_PID=$!
    sleep 5

    ## Add users and such
    echo "CREATE USER '${CIRCLECI_USER}'@'localhost'" | mysql -u root
    echo "GRANT ALL PRIVILEGES ON *.* TO '${CIRCLECI_USER}'@'localhost' WITH GRANT OPTION" | mysql -u root
    echo "CREATE USER 'circle'@'localhost'" | mysql -u root
    echo "GRANT ALL PRIVILEGES ON *.* TO 'circle'@'localhost' WITH GRANT OPTION" | mysql -u root
    echo "FLUSH PRIVILEGES" | mysql -u root
    echo "CREATE DATABASE circle_test" | mysql -u root

    kill $MYSQL_PID
}

function install_mysql_56() {
    {
            echo mysql-community-server mysql-community-server/data-dir select '';
            echo mysql-community-server mysql-community-server/root-pass password '';
            echo mysql-community-server mysql-community-server/re-root-pass password '';
            echo mysql-community-server mysql-community-server/remove-test-db select false;
    } | debconf-set-selections

    DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server-5.6 libmysqld-dev

    configure_mysql
}

function install_mysql_57() {
    apt-key adv --keyserver pgp.mit.edu --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5

    curl -LO http://dev.mysql.com/get/mysql-apt-config_0.6.0-1_all.deb

    {
        echo mysql-apt-config mysql-apt-config/unsupported-platform select abort
        echo mysql-apt-config mysql-apt-config/repo-codename   select trusty
        echo mysql-apt-config mysql-apt-config/select-tools select
        echo mysql-apt-config mysql-apt-config/repo-distro select ubuntu
        echo mysql-apt-config mysql-apt-config/select-server select mysql-5.7
        echo mysql-apt-config mysql-apt-config/select-product select Apply

        echo mysql-community-server mysql-community-server/data-dir select '';
        echo mysql-community-server mysql-community-server/remove-test-db select false;
        echo mysql-community-server mysql-community-server/re-root-pass password ""
        echo mysql-community-server mysql-community-server/root-pass    password ""
    } | debconf-set-selections

    DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.6.0-1_all.deb

    apt-get update

    apt-get -y install mysql-server libmysqld-dev

    # root password is set only for socket but not for network during the installation.
    # See: https://www.percona.com/blog/2016/03/16/change-user-password-in-mysql-5-7-with-plugin-auth_socket/
    sudo -u mysql mysqld &
    sleep 5
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';"
    sleep 5
    pkill -9 mysqld

    configure_mysql
}
