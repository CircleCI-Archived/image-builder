#!/usr/bin/env bats

# Idealy we can actually run android emulator to make sure
# Android is working but emulator is too slow to test.
# So only checking whether correct versions of packages are installed.

android_test_sdk_tool_version() {
    local expected=$1
    local actual=$(grep 'Pkg.Revision=' $ANDROID_HOME/tools/source.properties | sed 's/Pkg.Revision=//')

    test "$expected" = "$actual"
}

android_test_sdk_build_tool_installed() {
    local version=$1
    local install_path=$ANDROID_HOME/build-tools/$version

    ls $install_path
}

android_test_sdk_platform_installed() {
    local version=$1
    local install_path=$ANDROID_HOME/platforms/android-$version

    ls $install_path
}

android_test_sdk_extra_installed() {
    local pkg=$1
    local type=$2
    local install_path=$ANDROID_HOME/extras/$type/$pkg

    ls $install_path
}

android_test_sdk_addons_installed() {
    local pkg=$1
    local install_path=$ANDROID_HOME/add-ons/$pkg

    ls $install_path
}

@test "android: correct version of sdk tool is installed" {
    run android_test_sdk_tool_version "24.4.1"

    [ "$status" -eq 0 ]
}

@test "android: build-tools-23.0.3 is installed" {
    run android_test_sdk_build_tool_installed "23.0.3"

    [ "$status" -eq 0 ]
}

@test "android: build-tools-23.0.2 is installed" {
    run android_test_sdk_build_tool_installed "23.0.2"

    [ "$status" -eq 0 ]
}

@test "android: build-tools-22.0.1 is installed" {
    run android_test_sdk_build_tool_installed "22.0.1"

    [ "$status" -eq 0 ]
}

@test "android: android-23 is installed" {
    run android_test_sdk_platform_installed "23"

    [ "$status" -eq 0 ]
}

@test "android: android-22 is installed" {
    run android_test_sdk_platform_installed "22"

    [ "$status" -eq 0 ]
}

@test "android: extra-android-m2repository is installed" {
    run android_test_sdk_extra_installed "m2repository" "android"

    [ "$status" -eq 0 ]
}

@test "android: extra-google-m2repository is installed" {
    run android_test_sdk_extra_installed "m2repository" "google"

    [ "$status" -eq 0 ]
}

@test "android: extra-google-google_play_services is installed" {
    run android_test_sdk_extra_installed "google_play_services" "google"

    [ "$status" -eq 0 ]
}

@test "android: addon-google_apis-google-23 is installed" {
    run android_test_sdk_addons_installed "addon-google_apis-google-23"

    [ "$status" -eq 0 ]
}

@test "android: addon-google_apis-google-22 is installed" {
    run android_test_sdk_addons_installed "addon-google_apis-google-22"

    [ "$status" -eq 0 ]
}
