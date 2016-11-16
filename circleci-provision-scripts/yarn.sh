#!/bin/bash

function install_yarn() {
    NODEJS_VERSION=$1
    (cat <<'EOF'
source ~/.circlerc
nvm use $NODEJS_VERSION
# tell npm to use known registrars for CA certs -
# http://blog.npmjs.org/post/78085451721/npms-self-signed-certificate-is-no-more
npm config set ca "" --global
npm install -g yarn
hash -r
EOF
    ) | as_user NODEJS_VERSION=$NODEJS_VERSION bash
}