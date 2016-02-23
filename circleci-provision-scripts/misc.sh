#/bin/bash

function install_redis() {
    apt-get install redis-server
}

function install_memcached() {
    apt-get install memcached libmemcache-dev
}

function install_rabbitmq() {
    apt-get install rabbitmq-server
}

function install_neo4j() {
    wget -O - http://debian.neo4j.org/neotechnology.gpg.key | apt-key add -
    echo 'deb http://debian.neo4j.org/repo stable/' > /etc/apt/sources.list.d/neo4j.list
    apt-get update
    apt-get install neo4j

    # Disable auth
    sed -i "s|dbms.security.auth_enabled=true|dbms.security.auth_enabled=false|g" /etc/neo4j/neo4j-server.properties
}

function install_elasticsearch() {
    local CONFIG_FILE=/etc/elasticsearch/elasticsearch.yml

    pushd tmp
    wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.2.deb
    dpkg -i elasticsearch-1.7.2.deb
    popd

    echo 'index.number_of_shards: 1' >> $CONFIG_FILE
    echo 'index.number_of_replicas: 0' >> $CONFIG_FILE
}

function install_sysadmin() {
    cat << EOS | xargs apt-get install
htop
EOS
}

function install_devtools() {
    cat << EOS | xargs apt-get install
ack-grep
emacs
gdb
lsof
nano
tmux
vim
vnc4server
EOS
}
