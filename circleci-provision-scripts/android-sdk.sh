#!/bin/bash
set -ex

function install_circle_android_helper() {
    cat <<'EOF' > /usr/local/bin/circle-android
#!/usr/bin/env bash

spinstr='|/-\'
spin_index=0

spin_until () {
    while ! $@
    do
        spin_index=$(expr $(expr $spin_index + 1) % 4)
        printf "\r${spinstr:spin_index:1}"
        sleep 0.5
    done
    printf "\r"
}

adb_shell_getprop () {
    adb shell getprop $1 | tr -d [:space:] # delete the whitespace
}

device_actually_ready () {
    # https://devmaze.wordpress.com/2011/12/12/starting-and-stopping-android-emulators/
    [ "$(adb_shell_getprop init.svc.bootanim)" = "stopped" ]
}

if [ "$1" == "wait-for-boot" ]
then
    # wait for the device to respond to shell commands
    spin_until adb shell true 2> /dev/null
    # wait for the emulator to be completely finished booting.
    # adb wait-for-device is not sufficient for this.
    spin_until device_actually_ready
else
    echo "$0, a collection of tools for CI with android."
    echo ""
    echo "Usage:"
    echo "  $0 wait-for-boot - wait for a device to fully boot."
    echo "    (adb wait-for-device only waits for it to be ready for shell access)."
fi

EOF

    chmod +x /usr/local/bin/circle-android
}

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
    SDK_VERSION="r24.4.1"
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
    [[ -e /usr/local/bin/circle-android ]] || install_circle_android_helper

    install_sdk_package $SDK_PACKAGE
}
