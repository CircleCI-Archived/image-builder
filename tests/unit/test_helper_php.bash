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
}

php_test_version () {
    local version=$1

    php -r 'echo phpversion();' | grep "$version"
}

php_test_composer () {
    composer --version
}

php_test_pecl () {
    pecl version
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

php_test_all_installed () {
    local expected=$(grep "circleci-install php" /opt/circleci/Dockerfile | awk '{print $4}' | sort)
    local actual=$(ls /opt/circleci/php/ | sort)

    run test "$expected" = "$actual"

    [ "$status" -eq 0 ]
}
