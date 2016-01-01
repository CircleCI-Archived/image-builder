#!/bin/bash

function as_user() {
    sudo -H -u ${CIRCLECI_USER} $@
}

function add_path() {
    local PATH=$1

    echo "export PATH=$PATH:"'$PATH' >> $CIRCLECI_RC
}

function append_rc() {
    echo "export $1" >> $CIRCLECI_RC
}

function load_rc() {
    source $CIRCLECI_RC
}

function use_precompile() {
    local PKG=$1

    [ -n "$USE_PRECOMPILE" ] && type -t install_${PKG}_precompile >/dev/null
}

