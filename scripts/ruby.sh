#!/bin/bash

set -ex

echo '>>> Installing RVM and Ruby'

function install_rvm() {
    $USER_STEP gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    curl -sSL https://get.rvm.io | $USER_STEP bash -s stable --ruby

    ln -sf ${CIRCLECI_HOME}/.rvm /usr/local/rvm

    echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function' | $USER_STEP tee -a ${CIRCLECI_HOME}/.circlerc

    # Setting up user rmvrc

    (cat <<'EOF'
export rvm_gemset_create_on_use_flag=1
export rvm_install_on_use_flag=1
export rvm_trust_rvmrcs_flag=1
export rvm_verify_downloads_flag=1
EOF
    ) | $USER_STEP tee ${CIRCLECI_HOME}/.rvmrc

    # Setting up default gemrc

    (cat <<'EOF'
:sources:
- https://rubygems.org
gem:  --no-ri --no-rdoc
EOF
    ) | $USER_STEP tee ${CIRCLECI_HOME}/.gemrc

    (cat <<'EOF'
source ~/.circlerc
rvm rvmrc warning ignore allGemfiles
EOF
    ) | $USER_STEP bash
}


function install_ruby() {
    RUBY_VERSION=$1
    RUBYGEMS_MAJOR_RUBY_VERSION=${2:-2}
    (cat <<'EOF'

set -e

echo Installing Ruby version: $RUBY_VERSION
source ~/.circlerc

rvm use $RUBY_VERSION

# TODO: Avoid this for jruby
rvm rubygems latest-${RUBYGEMS_MAJOR_RUBY_VERSION}
rvm @global do gem install bundler -v 1.9.5

# For projects without gemfiles
rvm @global do gem install rspec

EOF
    ) | $USER_STEP RUBY_VERSION=$RUBY_VERSION RUBYGEMS_MAJOR_RUBY_VERSION=$RUBYGEMS_MAJOR_RUBY_VERSION bash
}

install_rvm
install_ruby 2.2.2
install_ruby 2.2.0
install_ruby 1.9.3-p551
