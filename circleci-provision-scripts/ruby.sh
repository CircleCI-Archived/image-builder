#!/bin/bash

function install_rvm() {
    echo '>>> Installing RVM and Ruby'

    as_user gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    curl -sSL https://get.rvm.io | as_user bash -s stable --ruby

    ln -sf ${CIRCLECI_HOME}/.rvm /usr/local/rvm

    echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function' | as_user tee -a ${CIRCLECI_HOME}/.circlerc

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
}


function install_ruby_version() {
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

function install_ruby() {
    VERSION=$1
    [[ -e $CIRCLECI_HOME/.rvm ]] || install_rvm
    install_ruby_version $1
}
