#!/bin/bash

function install_memcached() {
    DEBIAN_FRONTEND=noninteractive apt-get install -y memcached

    service memcached stop
    update-rc.d memcached disable
    rm /etc/init.d/memcached

    # create upstart script
    (cat <<'EOF'
description "memcached daemon"

start on (filesystem and net-device-up IFACE!=lo)
stop on runlevel [!2345]

# yes there is a /etc/memcached.conf file and yes
# there is a fancy perl script and decode it, ...
# but that hides a lot of debug output and we use
# the defaults so they are presented below

env MEMCACHED_BIN=/usr/bin/memcached

pre-start script
  test -x $MEMCACHED || { stop; exit 0; }
end script

respawn
exec $MEMCACHED_BIN -m 64 -p 11211 -u memcache -l 127.0.0.1
EOF
    ) > /etc/init/memcached.conf
}