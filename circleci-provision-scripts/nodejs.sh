#!/bin/bash

function install_nvm() {
    echo '>>> Installing NodeJS NVM'

    apt-get install build-essential libssl-dev make python g++ curl libssl-dev

    echo 'Install NVM'
    (cat <<'EOF'
set -ex
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.30.2/install.sh | NVM_DIR=$CIRCLECI_PKG_DIR/.nvm bash
echo "export NVM_DIR=$CIRCLECI_PKG_DIR/.nvm" >> ~/.circlerc
echo 'source $NVM_DIR/nvm.sh' >> ~/.circlerc
EOF
    ) | as_user CIRCLECI_PKG_DIR=$CIRCLECI_PKG_DIR bash


    if [ -n "$USE_PRECOMPILE" ]; then
        patch_nvm_always_delete_npm_prefix

        # Preparing for hooking up packaged NodeJS into nvm directories
        (cat <<'EOF'
set -ex
mkdir $CIRCLECI_PKG_DIR/nodejs
mkdir $CIRCLECI_PKG_DIR/.nvm/versions
ln -s $CIRCLECI_PKG_DIR/nodejs $CIRCLECI_PKG_DIR/.nvm/versions/node

EOF
        ) | as_user CIRCLECI_PKG_DIR=$CIRCLECI_PKG_DIR bash
    fi
}

# This is a kind of hack to prevent 'nvm is not compatible with the npm config "prefix" option' error
# when you run `nvm use vX.Y.Z`. We get this error because nvm expects nodejs to be installed under $NVM_DIR
# but we actually install under /opt/circleci/nodejs.
function patch_nvm_always_delete_npm_prefix() {
     sed -i 's/NVM_DELETE_PREFIX=0/NVM_DELETE_PREFIX=1/' $CIRCLECI_PKG_DIR/.nvm/nvm.sh
}

function install_nodejs_version_nvm() {
    NODEJS_VERSION=$1
    (cat <<'EOF'
set -ex
source ~/.circlerc
nvm install $NODEJS_VERSION
rm -rf ~/nvm/src
hash -r
nvm use $NODEJS_VERSION
# tell npm to use known registrars for CA certs -
# http://blog.npmjs.org/post/78085451721/npms-self-signed-certificate-is-no-more
npm config set ca "" --global
# Install some common libraries
npm install -g npm
npm install -g coffee-script
npm install -g grunt
npm install -g bower
npm install -g grunt-cli
npm install -g nodeunit
npm install -g mocha
hash -r
EOF
    ) | as_user NODEJS_VERSION=$NODEJS_VERSION bash

    set_nodejs_default $NODEJS_VERSION
}

function install_nodejs_version_precompile() {
    local NODEJS_VERSION=$1

    apt-get install circleci-nodejs-$NODEJS_VERSION
    chown -R $CIRCLECI_USER:$CIRCLECI_USER $CIRCLECI_PKG_DIR/nodejs
    set_nodejs_default $NODEJS_VERSION
}

function install_nodejs_version() {
    local VERSION=$1

    if [ -n "$USE_PRECOMPILE" ]; then
        install_nodejs_version_precompile $VERSION
    else
        install_nodejs_version_nvm $VERSION
    fi
}

function set_nodejs_default() {
    local NODEJS_VERSION=$1

    (cat <<'EOF'
set -ex
source ~/.circlerc
nvm alias default $NODEJS_VERSION
EOF
    ) | as_user NODEJS_VERSION=$NODEJS_VERSION bash
}

function install_nodejs() {
    local NODEJS_VERSION=$1

    [[ -e $CIRCLECI_PKG_DIR/.nvm ]] || install_nvm
    install_nodejs_version $NODEJS_VERSION
}
