#!/bin/bash

function switch_ruby() {
    VERSION=$1
    RC_FILE=/home/$CIRCLECI_USER/.circlerc

    echo ">>> Using Ruby $VERSION"
    
    echo "export PATH=/opt/circleci/ruby/${VERSION}/bin:$PATH" >> $RC_FILE
    echo "export RUBYLIB=/opt/circleci/ruby/${VERSION}/lib/ruby/2.2.0:/opt/circleci/ruby/${VERSION}/lib/ruby/2.2.0/x86_64-linux" >> $RC_FILE
    
    source $RC_FILE
}

function install_ruby() {
    VERSION=$1
    
    sudo apt-get install circleci-ruby${VERSION}=0.0.1
    chown -R $CIRCLECI_USER:$CIRCLECI_USER /opt/circleci/ruby/$VERSION
    switch_ruby $VERSION
}
