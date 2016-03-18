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

function install_beanstalkd() {
    apt-get install beanstalkd
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
    apt-get install htop
}

function install_devtools() {
    apt-get install $(tr '\n' ' ' <<EOS
ack-grep
emacs
gdb
lsof
nano
tmux
vim
vnc4server
EOS
)
}

function install_closure() {
    curl -L -o /tmp/closure.zip https://dl.google.com/closure-compiler/compiler-latest.zip
    unzip -n /tmp/closure.zip
}

function install_prince() {
    curl -L -o /tmp/prince.zip http://www.princexml.com/download/prince_9.0-5_ubuntu14.04_amd64.deb
    dpkg -i /tmp/prince.zip
    ln -s /usr/bin/prince /usr/local/bin/prince
}
