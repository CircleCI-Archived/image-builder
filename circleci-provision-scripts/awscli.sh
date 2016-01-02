#!/bin/bash

function install_awscli() {
    pushd /tmp
    curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
    unzip awscli-bundle.zip
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    rm -rf awscli-bundle*
    popd
}
