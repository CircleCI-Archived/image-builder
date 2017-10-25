function install_curl_7_56() {
    local build_dir=/tmp/curl
    apt-get install libssl-dev # Needed for ssl support for curl
    apt-get build-dep curl

    # Get latest (as of Feb 25, 2016) libcurl
    mkdir $build_dir
    cd $build_dir
    wget http://curl.haxx.se/download/curl-7.56.1.tar.bz2
    tar -xvjf curl-7.56.1.tar.bz2
    cd curl-7.56.1

    # The usual steps for building an app from source
    # ./configure
    # ./make
    # sudo make install
    ./configure
    make
    make install

    # Resolve any issues of C-level lib
    # location caches ("shared library cache")
    ldconfig

    rm -rf $build_dir
}
