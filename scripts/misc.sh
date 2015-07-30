#/bin/bash

set -ex

echo '>>> Setup misc tools'

apt-get install -qq \
	memcached libmemcache-dev \
	redis-server

