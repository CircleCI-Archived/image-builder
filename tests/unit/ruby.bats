#!/usr/bin/env bats

test_ruby () {
    local version=$1

    # Don't use rvm!!
    # Using 'rvm use ...' requires you to source /opt/circleci/.rvm/scripts/rvm
    # and this makes bats extremely slow for some reasons. (probably same as https://github.com/sstephenson/bats/issues/107)
    # So just load only env vars
    . /opt/circleci/.rvm/environments/ruby-$version

    run ruby_test_version $version
    [ "$status" -eq 0 ]

    run ruby_test_gem
    [ "$status" -eq 0 ]

    run ruby_test_bundler
    [ "$status" -eq 0 ]
}

ruby_test_version () {
    local version=$1

    ruby -e 'puts RUBY_VERSION' | grep "$version"
}

ruby_test_gem () {
    gem --version
}

ruby_test_bundler () {
    bundler --version
}

@test "ruby: all versions are installed" {
    local expected=$(grep "circleci-install ruby" /opt/circleci/Dockerfile | awk '{print "ruby-" $4}' | sort)
    local actual=$(ls /opt/circleci/ruby/ | grep -v default | sort)

    run test "$expected" = "$actual"

    [ "$status" -eq 0 ]
}

# Run this test first before version is changed by subsequent tests
@test "ruby: default is 2.2.4" {
    run ruby_test_version 2.2.4

    [ "$status" -eq 0 ]
}

@test "ruby: 2.1.8 works" {
    test_ruby 2.1.8
}

@test "ruby: 2.1.9 works" {
    test_ruby 2.1.9
}

@test "ruby: 2.2.4 works" {
    test_ruby 2.2.4
}

@test "ruby: 2.2.5 works" {
    test_ruby 2.2.5
}

@test "ruby: 2.3.0 works" {
    test_ruby 2.3.0
}

@test "ruby: 2.3.1 works" {
    test_ruby 2.3.1
}
