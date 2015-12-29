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

    if [[ "$PACKAGE" =~ ^android-[0-9][0-9]$ ]]; then
       AVD_VERSION=$(echo $PACKAGE | sed 's/android-//')
       create_avd $AVD_VERSION
    fi
}

function create_avd() {
    VERSION=$1
    AVD_TARGET=android$VERSION
    IMG_TARGET=android-$VERSION
    AVD_NAME=circleci-$AVD_TARGET
    IMG_NAME=sys-img-armeabi-v7a-$IMG_TARGET

    echo ">>> Creating AVD $AVD_NAME"
    (cat <<'EOF'
source ~/.circlerc
echo "y" | android update sdk --no-ui --all --filter $IMG_NAME
echo "no" | android create avd -n $AVD_NAME -t $IMG_TARGET --abi "default/armeabi-v7a"
EOF
    ) | as_user VERSION=$VERSION AVD_NAME=$AVD_NAME AVD_TARGET=$AVD_TARGET IMG_NAME=$IMG_NAME IMG_TARGET=$IMG_TARGET bash
}

function install_sdk(){
    SDK_VERSION=r24
    TMP_SDK=/tmp/sdk
    FILE=android-sdk_${SDK_VERSION}-linux.tgz

    mkdir -p $TMP_SDK
    sudo apt-get install -y openjdk-7-jdk lib32stdc++6 lib32z1
    curl -L -o $TMP_SDK/$FILE https://dl.google.com/android/$FILE
    tar --no-same-owner -zxf $TMP_SDK/$FILE -C /usr/local
    echo 'export PATH=/usr/local/android-sdk-linux/tools:$PATH' >> ${CIRCLECI_HOME}/.circlerc
    echo 'export PATH=/usr/local/android-sdk-linux/platform-tools:$PATH' >> ${CIRCLECI_HOME}/.circlerc
    echo 'export ANDROID_HOME=/usr/local/android-sdk-linux' >> ${CIRCLECI_HOME}/.circlerc
    echo 'export ADB_INSTALL_TIMEOUT=10' >> ${CIRCLECI_HOME}/.circlerc
    chown -R $CIRCLECI_USER:$CIRCLECI_USER /usr/local/android-sdk-linux
    rm -rf $TMP_SDK
}

function install_android_sdk() {
    SDK_PACKAGE=$1
    [[ -e /usr/local/android-sdk ]] || install_sdk

    install_sdk_package $SDK_PACKAGE
}
