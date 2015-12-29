#!/bin/bash

function install_phpenv(){
    PHP_TMP=/tmp/php

    apt-get install -y libpng12-dev re2c m4 libxslt1-dev libjpeg-dev libxml2-dev libtidy-dev libmcrypt-dev libreadline-dev libmagic-dev libssl-dev libcurl4-openssl-dev libfreetype6-dev libapache2-mod-php5

    # bison 2.7 is the latest version that php supports
    mkdir -p $PHP_TMP
    curl -L -o $PHP_TMP/libbison-dev_2.7.1.dfsg-1_amd64.deb http://launchpadlibrarian.net/140087283/libbison-dev_2.7.1.dfsg-1_amd64.deb
    curl -L -o $PHP_TMP/bison_2.7.1.dfsg-1_amd64.deb http://launchpadlibrarian.net/140087282/bison_2.7.1.dfsg-1_amd64.deb
    dpkg -i $PHP_TMP/libbison-dev_2.7.1.dfsg-1_amd64.deb
    dpkg -i $PHP_TMP/bison_2.7.1.dfsg-1_amd64.deb

    echo '>>> Installing php-env and php-build'
    (cat <<'EOF'
curl -L https://raw.github.com/CHH/phpenv/master/bin/phpenv-install.sh | bash
git clone git://github.com/php-build/php-build.git ~/.phpenv/plugins/php-build
echo 'export PATH="$HOME/.phpenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(phpenv init -)"' >> ~/.bash_profile
git clone https://github.com/ngyuki/phpenv-composer.git ~/.phpenv/plugins/phpenv-composer
EOF
    ) | as_user bash

    rm -rf $PHP_TMP
}

function install_php_version() {
    PHP_VERSION=$1
    echo ">>> Installing php $PHP_VERSION"
    
    (cat <<'EOF'
set -ex
source ~/.bash_profile
phpenv install $PHP_VERSION
rm -rf /tmp/php-build*
EOF
    ) | as_user PHP_VERSION=$PHP_VERSION bash
}

function install_php() {
    VERSION=$1
    [[ -e $CIRCLECI_HOME/.phpenv ]] || install_phpenv
    install_php_version $VERSION
}
