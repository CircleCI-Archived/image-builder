#!/usr/bin/env bats

test_php () {
    local version=$1

    phpenv local $version

    run php_test_version $version
    [ "$status" -eq 0 ]

    run php_test_composer
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

@test "php: all versions are installed" {
    local expected=$(grep "circleci-install php" /opt/circleci/Dockerfile | awk '{print $4}' | sort)
    local actual=$(ls /opt/circleci/php/ | sort)

    run test "$expected" = "$actual"

    [ "$status" -eq 0 ]
}

@test "php: 5.5.31 works" {
    test_php 5.5.31
}

@test "php: 5.5.32 works" {
    test_php 5.5.32
}

@test "php: 5.6.17 works" {
    test_php 5.6.17
}

@test "php: 5.6.18 works" {
    test_php 5.6.18
}

@test "php: 7.0.2 works" {
    test_php 7.0.2
}

@test "php: 7.0.3 works" {
    test_php 7.0.3
}
