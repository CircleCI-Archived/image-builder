#!/bin/bash

function install_firefox() {
    echo '>>> Installing Firefox'

    apt-get install -y firefox
}

function install_firefox_version() {
    VERSION="$1"
    echo ">>> Installing Firefox $VERSION"
    curl -L -o "/tmp/firefox-$VERSION.tar.bz2" "https://download-installer.cdn.mozilla.net/pub/firefox/releases/$VERSION/linux-x86_64/en-US/firefox-$VERSION.tar.bz2"
    tar -jxf "/tmp/firefox-$VERSION.tar.bz2" -C "/tmp/"
    sudo mv "/tmp/firefox" "/opt/firefox-$VERSION"
    sudo ln -sf "/opt/firefox-$VERSION/firefox" "/usr/bin/firefox"
    hash -r
    firefox --version
}
