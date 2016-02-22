#!/bin/bash

function install_phantomjs() {
    echo '>>> Installing PhantomJS'

    local BIN=/usr/local/bin/phantomjs

    curl --output $BIN https://s3.amazonaws.com/circle-downloads/phantomjs-2.1.1
    chmod +x $BIN
}
