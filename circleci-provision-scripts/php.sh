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
# Because of https://github.com/phpenv/phpenv/issues/43 I can't install from git directly
curl -L https://raw.github.com/CHH/phpenv/master/bin/phpenv-install.sh | bash
mv ~/.phpenv $CIRCLECI_PKG_DIR
git clone https://github.com/php-build/php-build.git $CIRCLECI_PKG_DIR/.phpenv/plugins/php-build
echo "export PHPENV_ROOT=$CIRCLECI_PKG_DIR/.phpenv" >> ~/.circlerc
echo 'export PATH=$PHPENV_ROOT/bin:$PATH' >> ~/.circlerc
echo 'eval "$(phpenv init -)"' >> ~/.circlerc
EOF
    ) | as_user CIRCLECI_PKG_DIR=$CIRCLECI_PKG_DIR bash

    if [ -n "$USE_PRECOMPILE" ]; then
        # Preparing for hooking up packaged Python into pyenv directories
        (cat <<'EOF'
mkdir $CIRCLECI_PKG_DIR/php
ln -s $CIRCLECI_PKG_DIR/php $CIRCLECI_PKG_DIR/.phpenv/versions
EOF
        ) | as_user CIRCLECI_PKG_DIR=$CIRCLECI_PKG_DIR bash
    fi

    rm -rf $PHP_TMP
}

function install_composer() {
    curl -sS https://getcomposer.org/installer | /usr/bin/php
    mv composer.phar /usr/local/bin/composer
    chmod a+x /usr/local/bin/composer
    echo 'export PATH=~/.composer/vendor/bin:$PATH' >> ${CIRCLECI_HOME}/.circlerc
}

function install_phpunit() {
    wget https://phar.phpunit.de/phpunit.phar
    chmod +x phpunit.phar
    mv phpunit.phar /usr/local/bin/phpunit
}

function install_php_version_phpenv() {
    PHP_VERSION=$1
    echo ">>> Installing php $PHP_VERSION"

    (cat <<'EOF'
source ~/.circlerc
phpenv install $PHP_VERSION
EOF
    ) | as_user PHP_VERSION=$PHP_VERSION bash
}

function install_php_version_precompile() {
    local PHP_VERSION=$1
    echo ">>> Installing php $PHP_VERSION"

    maybe_run_apt_update
    apt-get install circleci-php-$PHP_VERSION
    chown -R $CIRCLECI_USER:$CIRCLECI_USER $CIRCLECI_PKG_DIR/php/$PHP_VERSION
}

function install_php_version() {
    local VERSION=$1

    if [ -n "$USE_PRECOMPILE" ]; then
        install_php_version_precompile $VERSION
    else
        install_php_version_phpenv $VERSION
    fi
}

function install_php() {
    local VERSION=$1

    [[ -e $CIRCLECI_PKG_DIR/.phpenv ]] || install_phpenv
    type composer &>/dev/null || install_composer
    type phpunit &>/dev/null || install_phpunit
    install_php_version $VERSION
}
