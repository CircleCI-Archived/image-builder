#!/bin/bash

function install_firefox() {
    echo '>>> Installing Firefox'

    local url="https://s3.amazonaws.com/circle-downloads/firefox_46.0.1%2Bbuild1-0ubuntu0.14.04.3_amd64.deb"
    local deb_path="/tmp/firefox.deb"

    curl --output $deb_path $url

    dpkg -i $deb_path || apt-get -f install
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
