#!/bin/bash

function install_sqlite3_15() {
    local version="linux-x86-3150200"
    local package="sqlite-tools-${version}.zip"
    local bin_path="/usr/local/bin/sqlite3-15"

    pushd /tmp
    curl -o sqlite3.zip http://www.sqlite.org/2016/$package
    unzip sqlite3.zip
    cd sqlite-tools-${version}
    cp sqlite3 $bin_path
    chmod +x $bin_path
    rm ../sqlite3.zip
    popd
}
