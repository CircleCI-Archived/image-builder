#!/bin/bash

function install_phantomjs() {
    echo '>>> Installing PhantomJS'

    curl --output /home/ubuntu/bin/phantomjs-2.0.1-linux-x86_64-dynamic https://s3.amazonaws.com/circle-support-bucket/phantomjs/phantomjs-2.0.1-linux-x86_64-dynamic
    chmod a+x /home/ubuntu/bin/phantomjs-2.0.1-linux-x86_64-dynamic
    sudo ln -s --force /home/ubuntu/bin/phantomjs-2.0.1-linux-x86_64-dynamic /usr/local/bin/phantomjs
}
