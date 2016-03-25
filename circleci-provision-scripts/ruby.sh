#!/bin/bash

function install_rvm() {
    echo '>>> Installing RVM and Ruby'

    apt-get install libmagickwand-dev

    as_user gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    curl -sSL https://get.rvm.io | as_user bash -s -- --path $CIRCLECI_PKG_DIR/.rvm

    echo "[[ -s '$CIRCLECI_PKG_DIR/.rvm/scripts/rvm' ]] && . $CIRCLECI_PKG_DIR/.rvm/scripts/rvm # Load RVM function" | as_user tee -a ${CIRCLECI_HOME}/.circlerc

    # Setting up user rmvrc

    (cat <<'EOF'
export rvm_gemset_create_on_use_flag=1
export rvm_install_on_use_flag=1
export rvm_trust_rvmrcs_flag=1
export rvm_verify_downloads_flag=1
EOF
    ) | as_user tee ${CIRCLECI_HOME}/.rvmrc

    # Setting up default gemrc

    (cat <<'EOF'
:sources:
- https://rubygems.org
gem:  --no-ri --no-rdoc
EOF
    ) | as_user tee ${CIRCLECI_HOME}/.gemrc

    (cat <<'EOF'
set -ex
source ~/.circlerc
rvm rvmrc warning ignore allGemfiles
EOF
    ) | as_user bash

    if [ -n "$USE_PRECOMPILE" ]; then
    # Preparing for hooking up packaged Ruby into rvm directories

    (cat <<'EOF'
set -ex
mkdir $CIRCLECI_PKG_DIR/ruby
rm -r $CIRCLECI_PKG_DIR/.rvm/rubies
ln -s $CIRCLECI_PKG_DIR/ruby $CIRCLECI_PKG_DIR/.rvm/rubies
EOF
    ) | as_user CIRCLECI_PKG_DIR=$CIRCLECI_PKG_DIR bash
    fi

    # Install bundler to @global gemset
    # Otherwise bundler is missing when not pre-installed version of ruby is used
    # because `rvm install` doesn't take care of bundler installation
    local BUNDLER_VERSION=1.11.2

    (cat <<'EOF'
set -ex
source ~/.circlerc
rvmsudo rvm @global do gem install bundler -v $BUNDLER_VERSION
EOF
    ) | as_user BUNDLER_VERSION=$BUNDLER_VERSION bash
}

function install_ruby_version_rvm() {
    INSTALL_RUBY_VERSION=$1
    RUBYGEMS_MAJOR_RUBY_VERSION=${2:-2}
    (cat <<'EOF'
set -ex
echo Installing Ruby version: $INSTALL_RUBY_VERSION
source ~/.circlerc
rvm use $INSTALL_RUBY_VERSION
# TODO: Avoid this for jruby
rvm rubygems latest-${RUBYGEMS_MAJOR_RUBY_VERSION}
rvm @global do gem install bundler -v 1.9.5
# For projects without gemfiles
rvm @global do gem install rspec
EOF
    ) | as_user INSTALL_RUBY_VERSION=$INSTALL_RUBY_VERSION RUBYGEMS_MAJOR_RUBY_VERSION=$RUBYGEMS_MAJOR_RUBY_VERSION bash
}

function install_ruby_version_precompile() {
    local INSTALL_RUBY_VERSIONS="$@"
    local INSTALL_ARGS=""

    for v in $INSTALL_RUBY_VERSIONS; do
	INSTALL_ARGS="$INSTALL_ARGS circleci-ruby-$v"
    done

    echo ">>> Installing Ruby $INSTALL_RUBY_VERSIONS"

    apt-get install $INSTALL_ARGS
    chown -R $CIRCLECI_USER:$CIRCLECI_USER $CIRCLECI_PKG_DIR/ruby/

    (cat <<'EOF'
for v in $INSTALL_RUBY_VERSIONS; do
echo Installing Ruby version: $v
source ~/.circlerc
rvm use $v
gem install bundler
done
EOF
    ) | as_user INSTALL_RUBY_VERSIONS=$INSTALL_RUBY_VERSIONS bash
}

function install_ruby_version() {
    local VERSIONS="$@"

    if [ -n "$USE_PRECOMPILE" ]; then
        install_ruby_version_precompile $VERSIONS
    else
        install_ruby_version_rvm $VERSIONS
    fi
}

function install_ruby() {
    local VERSIONS="$@"

    [[ -e $CIRCLECI_PKG_DIR/.rvm ]] || install_rvm
    install_ruby_version $VERSIONS
}
