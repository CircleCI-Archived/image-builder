#!/usr/bin/env bats

load ../test_helper_nodejs

@test "nodejs: all versions are installed" {
    nodejs_test_all_installed
}

# Run this test first before version is changed by subsequent tests
@test "nodejs: default is 4.2.6" {
    run nodejs_test_version 4.2.6

    [ "$status" -eq 0 ]
}

@test "nodejs: 0.12.9 works" {
    test_nodejs 0.12.9
}

@test "nodejs: 4.0.0 works" {
    test_nodejs 4.0.0
}

@test "nodejs: 4.1.2 works" {
    test_nodejs 4.1.2
}

@test "nodejs: 4.2.6 works" {
    test_nodejs 4.2.6
}

@test "nodejs: 4.3.0 works" {
    test_nodejs 4.3.0
}

@test "nodejs: 4.5.0 works" {
    test_nodejs 4.5.0
}

@test "nodejs: 5.0.0 works" {
    test_nodejs 5.0.0
}

@test "nodejs: 5.1.1 works" {
    test_nodejs 5.1.1
}

@test "nodejs: 5.2.0 works" {
    test_nodejs 5.2.0
}

@test "nodejs: 5.3.0 works" {
    test_nodejs 5.3.0
}

@test "nodejs: 5.4.1 works" {
    test_nodejs 5.4.1
}

@test "nodejs: 5.5.0 works" {
    test_nodejs 5.5.0
}

@test "nodejs: 5.6.0 works" {
    test_nodejs 5.6.0
}

@test "nodejs: 5.7.0 works" {
    test_nodejs 5.7.0
}

@test "nodejs: 6.1.0 works" {
    test_nodejs 6.1.0
}

# We are not testing the behavior of nvm here...
# There was a bug that implicit versioning of nvm is broken
# because we use $CIRCLECI_PKG_DIR to store installed nodejs.
# This test makes sure the bug is fixed.
@test "nodejs: nvm implicit default alias works" {
    . /opt/circleci/.nvm/nvm.sh;

    local version="5"
    # Need to remove color from the string with sed
    local explicit=$(nvm ls-remote | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | grep v5 | tail -1)

    nvm install $version
    nvm alias default $version

    # Reload nvm to make sure default versinon persists
    nvm unload; . /opt/circleci/.nvm/nvm.sh;

    run node --version

    [ "$output" = $explicit ]
}
