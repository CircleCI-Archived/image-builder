#!/usr/bin/env bats

test_nodejs () {
    local version=$1

    # Loading nvm.sh makes bats very slow but getting
    # 'nvm command not found' error otherwise, so no choise :(
    . /opt/circleci/.nvm/nvm.sh

    nvm use $version

    run nodejs_test_version $version
    [[ "$status" -eq 0 ]]

    run nodejs_test_npm
    [[ "$status" -eq 0 ]]
}

nodejs_test_version () {
    local version=$1

    node -e "console.log(process.version);" | grep "$version"
}

nodejs_test_npm () {
    npm --version
}

@test "nodejs: all versions are installed" {
    local expected=$(grep "circleci-install nodejs" /opt/circleci/Dockerfile | awk '{print "v" $4}' | sort)
    local actual=$(ls /opt/circleci/nodejs/ | sort)

    run test "$expected" = "$actual"

    [[ "$status" -eq 0 ]]
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
