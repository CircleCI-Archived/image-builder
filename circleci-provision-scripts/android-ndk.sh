#!/bin/bash

function install_ndk() {
    NDK_VERSION=r10d
    TMP_NDK=/tmp/ndk
    DIR=android-ndk-$NDK_VERSION
    FILE=$DIR-linux-x86_64.bin

    mkdir -p $TMP_NDK
    curl -L -o $TMP_NDK/$FILE https://dl.google.com/android/ndk/$FILE

    pushd $TMP_NDK
    chmod a+x $FILE
    ./$FILE
    mv $DIR /usr/local/android-ndk
    popd

    echo 'export "ANDROID_NDK=/usr/local/android-ndk"' >> ${CIRCLECI_HOME}/.circlerc
    rm -rf $TMP_NDK
}

# I'm not sure how many users actually use fb-adb, so disabling for now.
#function install_fb_adb() {
#    FB_ADB_VERSION=1.2.0
#    TMP_FB_ADB=/tmp/fb_adb
#    FILE=fb-adb-$FB_ADB_VERSION.tar.gz
#
#    mkdir -p $TMP_FB_ADB
#    curl -L -o $TMP_FB_ADB/$FILE https://s3.amazonaws.com/circle-downloads/$FILE
#
#    pushd $TMP_FB_ADB
#    tar xzf $FILE
#    cd fb-adb
#    ./autogen.sh
#    mkdir build && cd build
#    source ${CIRCLECI_HOME}/.circlerc
#    "../configure"
#    make install
#    popd
#
#    rm -rf $TMP_FB_ADB
#}

function install_android_ndk() {
    [[ -e /usr/local/android-ndk ]] || install_ndk
}
