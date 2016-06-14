#!/usr/bin/env bats

test_php () {
    local version=$1

    phpenv local $version

    run php_test_version $version
    [ "$status" -eq 0 ]

    run php_test_composer
    [ "$status" -eq 0 ]

    run php_test_pecl
    [ "$status" -eq 0 ]

    run php_test_libphp_exists $version
    [ "$status" -eq 0 ]

    # Current version of phpunit (5.3) doesn't support php 5.5
    # but this appears not to be a major issue for our customers.
    if ! echo $version | grep "5.5"; then
       run php_test_phpunit
       [ "$status" -eq 0 ]
    fi
}

php_test_version () {
    local version=$1

    php -r 'echo phpversion();' | grep "$version"
}

php_test_composer () {
    composer --version
}

php_test_phpunit () {
    phpunit --version
}

php_test_pecl () {
    pecl --version
}

php_test_libphp_exists () {
    local version=$1

    # PHP 5
    if echo $version | grep -q "^5"; then
        local libphp_path="$PHPENV_ROOT/versions/$version/usr/lib/apache2/modules/libphp5.so"
    # PHP 7
    elif echo $version | grep -q "^7"; then
        local libphp_path="$PHPENV_ROOT/versions/$version/usr/lib/apache2/modules/libphp7.so"
    else
        echo "unknown version: $version" && return 1
    fi

    test -e $libphp_path
}

@test "php: all versions are installed" {
    local expected=$(grep "circleci-install php" /opt/circleci/Dockerfile | awk '{print $4}' | sort)
    local actual=$(ls /opt/circleci/php/ | sort)

    run test "$expected" = "$actual"

    [ "$status" -eq 0 ]
}

# Run this test first before version is changed by subsequent tests
@test "php: default is 5.6.17" {
    run php_test_version 5.6.17

    [ "$status" -eq 0 ]
}

@test "php: 5.5.31 works" {
    test_php 5.5.31
}

@test "php: 5.5.32 works" {
    test_php 5.5.32
}

@test "php: 5.5.36 works" {
    test_php 5.5.36
}

@test "php: 5.6.17 works" {
    test_php 5.6.17
}

@test "php: 5.6.18 works" {
    test_php 5.6.18
}

@test "php: 5.6.22 works" {
    test_php 5.6.22
}

@test "php: 7.0.3 works" {
    test_php 7.0.3
}

@test "php: 7.0.4 works" {
    test_php 7.0.4
}

@test "php: 7.0.7 works" {
    test_php 7.0.7
}
