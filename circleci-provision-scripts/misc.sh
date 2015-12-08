#/bin/bash

function redis() {
    apt-get install -qq redis-server
}

function memcached() {
    apt-get install -qq memcached libmemcache-dev
}
