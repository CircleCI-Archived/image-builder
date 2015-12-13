#/bin/bash

function redis() {
    apt-get install redis-server
}

function memcached() {
    apt-get install memcached libmemcache-dev
}
