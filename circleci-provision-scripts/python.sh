#!/bin/bash

function switch_python() {
    VERSION=$1
    RC_FILE=/home/$CIRCLECI_USER/.circlerc

    echo ">>> Using Python $VERSION"
    
    echo "export PATH=/opt/circleci/python/${VERSION}/bin:$PATH" >> $RC_FILE
    
    source $RC_FILE
}

function install_python() {
    VERSION=$1

    sudo apt-get install circleci-python${VERSION}=0.0.1
    chown -R $CIRCLECI_USER:$CIRCLECI_USER /opt/circleci/python/$VERSION
    switch_python $VERSION
}
