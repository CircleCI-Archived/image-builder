#!/bin/bash

function install_ruby() {
    VERSION=$1

    sudo apt-get install circleci-ruby${VERSION}=0.0.1
    chown -R $CIRCLECI_USER:$CIRCLECI_USER /opt/circleci/ruby/$VERSION
    
    (cat <<'EOF'

echo "export PATH=/opt/circleci/ruby/${VERSION}/bin:$PATH" >> ~/.circlerc
echo "export RUBYLIB=/opt/circleci/ruby/${VERSION}/lib/ruby/2.2.0:/opt/circleci/ruby/${VERSION}/lib/ruby/2.2.0/x86_64-linux" >> ~/.circlerc

source  ~/.circlerc
gem install bundler

EOF
    ) | as_user VERSION=$VERSION bash
    
}
