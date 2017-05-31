#/bin/bash

function install_redis() {
    apt-get install redis-server
    # disable init.d script for redis
    update-rc.d redis-server disable
    rm /etc/init.d/redis-server
    # manage redis with upsatart. needs to be explicitly started with 'sudo start redis-server'
    printf 'description "redis server"\nstop on shutdown\nexec sudo -u redis /usr/bin/redis-server /etc/redis/redis.conf\nrespawn' > /etc/init/redis-server.conf
    # prevent redis-server from forking and daemonizing itself so upstart can respawn it
    sed -i "s|daemonize yes|daemonize no|g" /etc/redis/redis.conf
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
    # 2.3.3 is the last version that works with Java7 and later release needs Java8
    local version="2.3.3"
    wget -O - http://debian.neo4j.org/neotechnology.gpg.key | apt-key add -
    echo 'deb http://debian.neo4j.org/repo stable/' > /etc/apt/sources.list.d/neo4j.list
    apt-get update
    apt-get install neo4j=$version

    # Disable auth
    sed -i "s|dbms.security.auth_enabled=true|dbms.security.auth_enabled=false|g" /etc/neo4j/neo4j-server.properties

    # Memory limitation
    echo 'wrapper.java.maxmemory=1536' >> /etc/neo4j/neo4j-wrapper.conf
}

function install_elasticsearch() {
    local CONFIG_FILE=/etc/elasticsearch/elasticsearch.yml

    pushd tmp
    wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.2.deb
    dpkg -i elasticsearch-1.7.2.deb
    popd

    echo 'index.number_of_shards: 1' >> $CONFIG_FILE
    echo 'index.number_of_replicas: 0' >> $CONFIG_FILE
    # Because Getting Permission Denied error
    sudo sed -i 's/sysctl -q -w vm.max_map_count=$MAX_MAP_COUNT/true/' /etc/init.d/elasticsearch
}

function install_cassandra() {
    local VERSION=34
    echo "deb http://www.apache.org/dist/cassandra/debian ${VERSION}x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list

    apt-get update
    apt-get install cassandra

    # Supressing ulimit error because of the lack of permission
    sed -i 's/ulimit/#ulimit/'  /etc/init.d/cassandra

    # Putting resource restriction
    sed -i 's/system_memory_in_mb=.*/system_memory_in_mb=2048/' /etc/cassandra/cassandra-env.sh
    sed -i 's/system_cpu_cores=.*/system_cpu_cores=1/' /etc/cassandra/cassandra-env.sh
    sed -i 's/JVM_OPTS="$JVM_OPTS -Xms${MAX_HEAP_SIZE}"/JVM_OPTS="$JVM_OPTS -Xms256M"/' /etc/cassandra/cassandra-env.sh
}

function install_riak() {
    local VERSION=2.1.3

    curl -s https://packagecloud.io/install/repositories/basho/riak/script.deb.sh | sudo bash
    sudo apt-get install riak=${VERSION}-1
}

function install_couchdb() {
    add-apt-repository ppa:couchdb/stable
    apt-get update
    apt-get install couchdb
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

function install_jq() {
    local url="https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64"
    local install_path="/usr/local/bin/jq"

    curl -L -o $install_path $url
    chmod +x $install_path
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
