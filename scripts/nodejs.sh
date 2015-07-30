#!/bin/bash

set -ex

echo '>>> Installing NodeJS'

function install_nvm() {
	apt-get install -qq build-essential libssl-dev make python g++ curl libssl-dev

	echo 'Install VNM'
	(cat <<'EOF'
set -e
cd ~
[[ -e nvm ]] || git clone https://github.com/creationix/nvm.git nvm
mkdir -p nvm/log
echo 'source ~/nvm/nvm.sh' >> ~/.circlerc
EOF
	) | $USER_STEP bash
}

function install_nodejs() {
	NODEJS_VERSION=$1
	(cat <<'EOF'
set -e
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
	) | $USER_STEP NODEJS_VERSION=$NODEJS_VERSION bash
}

function set_nodejs_default() {
	NODEJS_VERSION=$1
	(cat <<'EOF'
set -e
source ~/.circlerc
nvm alias default $NODEJS_VERSION
EOF
	) | $USER_STEP NODEJS_VERSION=$NODEJS_VERSION bash
}

install_nvm

install_nodejs "v0.10.34"
install_nodejs "v0.11.14"
install_nodejs "v0.12.0"

set_nodejs_default "v0.12.0"
