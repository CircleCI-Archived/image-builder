function install_curl_7_50() {
    local build_dir=/tmp/curl
    apt-get build-dep curl

    # Get latest (as of Feb 25, 2016) libcurl
    mkdir $build_dir
    cd $build_dir
    wget http://curl.haxx.se/download/curl-7.50.2.tar.bz2
    tar -xvjf curl-7.50.2.tar.bz2
    cd curl-7.50.2

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
