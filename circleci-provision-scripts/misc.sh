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

function install_closure() {
    curl -L -o /tmp/closure.zip https://dl.google.com/closure-compiler/compiler-latest.zip
    unzip -n /tmp/closure.zip
}

function install_prince() {
    curl -L -o /tmp/prince.zip http://www.princexml.com/download/prince_9.0-5_ubuntu14.04_amd64.deb
    dpkg -i /tmp/prince.zip
    ln -s /usr/bin/prince /usr/local/bin/prince
}
