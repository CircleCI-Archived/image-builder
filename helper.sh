#!/bin/bash

set -ex

export CIRCLECI_USER=$1
[ -n "$CIRCLECI_USER" ] || export CIRCLECI_USER=${SUDO_USER}

if [ -z "$CIRCLECI_USER" ]
then
    echo CIRCLECI_USER env-var is not defined
    exit 1
fi

export CIRCLECI_HOME=/home/${CIRCLECI_USER}

export USER_STEP="sudo -H -u ${CIRCLECI_USER}"


echo Using user ${CIRCLECI_USER}
