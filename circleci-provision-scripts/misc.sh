#/bin/bash

function install_redis() {
    apt-get install redis-server
}

function install_memcached() {
    apt-get install memcached libmemcache-dev
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
