#/bin/bash

function install_redis() {
    apt-get install redis-server
}

function install_memcached() {
    apt-get install memcached libmemcache-dev
}
