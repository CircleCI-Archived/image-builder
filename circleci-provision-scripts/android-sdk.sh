#!/bin/bash
set -ex

function install_sdk_package() {
    PACKAGE=$1
    
    echo ">>> Installing SDK Package: $PACKAGE"
    (cat <<'EOF'
source ~/.circlerc
echo "y" | android update sdk --no-ui --all --filter $PACKAGE
EOF
    ) | as_user PACKAGE=$PACKAGE bash    
    
    source ${CIRCLECI_HOME}/.circlerc
    echo "y" | android update sdk --no-ui --all --filter $PACKAGE

    if [[ "$PACKAGE" =~ ^android-[0-9][0-9]$ ]]; then
	AVD_VERSION=$(echo $PACKAGE | sed 's/android-//')	
	create_avd $AVD_VERSION
    fi    
}

function create_avd() {
    VERSION=$1
    AVD_TARGET=android-$VERSION
    AVD_NAME=circleci-$AVD_TARGET
    IMG_NAME=sys-img-armeabi-v7a-$AVD_TARGET

    echo ">>> Creating AVD $AVD_NAME"
    (cat <<'EOF'
source ~/.circlerc
echo "y" | android update sdk --no-ui --all --filter $IMG_NAME
echo "no" | android create avd -n $AVD_NAME -t $AVD_TARGET --abi "default/armeabi-v7a"
EOF
    ) | as_user VERSION=$VERSION AVD_NAME=$AVD_NAME AVD_TARGET=$AVD_TARGET IMG_NAME=$IMG_NAME bash       
}

function install_sdk(){
    SDK_VERSION=r24.4    
    TMP_SDK=/tmp/sdk
    FILE=android-sdk_${SDK_VERSION}-linux.tgz

    mkdir -p $TMP_SDK    
    sudo apt-get install -y openjdk-7-jdk
    curl -L -o $TMP_SDK/$FILE https://dl.google.com/android/$FILE
    tar -zxf $TMP_SDK/$FILE -C /usr/local
    echo 'export PATH=/usr/local/android-sdk-linux/tools:$PATH' >> ${CIRCLECI_HOME}/.circlerc
    echo 'export PATH=/usr/local/android-sdk-linux/platform-tools:$PATH' >> ${CIRCLECI_HOME}/.circlerc
    echo 'export ANDROID_HOME=/usr/local/android-sdk-linux' >> ${CIRCLECI_HOME}/.circlerc
    echo 'export ADB_INSTALL_TIMEOUT=10' >> ${CIRCLECI_HOME}/.circlerc
    chown -R ubuntu:ubuntu /usr/local/android-sdk-linux
    rm -rf $TMP_SDK
}

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

function install_fb_adb() {
    FB_ADB_VERSION=1.2.0
    TMP_FB_ADB=/tmp/fb_adb
    FILE=fb-adb-$FB_ADB_VERSION.tar.gz

    mkdir -p $TMP_FB_ADB
    curl -L -o $TMP_FB_ADB/$FILE https://s3.amazonaws.com/circle-downloads/$FILE

    pushd $TMP_FB_ADB
    tar xzf $FILE
    cd fb-adb
    ./autogen.sh
    mkdir build && cd build
    source ${CIRCLECI_HOME}/.circlerc
    "../configure"
    make install
    popd

    rm -rf $TMP_FB_ADB
}

function install_android_sdk() {
    SDK_PACKAGE=$1
    [[ -e /usr/local/android-sdk ]] || install_sdk
    [[ -e /usr/local/android-ndk ]] || install_ndk
    [[ -e /usr/local/bin/fb-adb ]] || install_fb_adb
    
    install_sdk_package $SDK_PACKAGE
}
