#!/bin/bash

function install_nodejs() {
    curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
    sudo apt-get install -y nodejs
}

function install_yarn() {
    local version=$1

    (cat <<EOF
source ~/.circlerc
curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version $version
EOF
    ) | as_user version=$version bash
}
