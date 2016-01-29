#!/bin/bash

set -ex
[ -n "$CIRCLECI_USER" ] || export CIRCLECI_USER=ubuntu
export CIRCLECI_HOME=/home/${CIRCLECI_USER}

function as_user() {
    sudo -H -u ${CIRCLECI_USER} $@
}
export -f as_user


[[ $SCRIPTS_PATH ]] || export SCRIPTS_PATH=/opt/circleci-provision-scripts

