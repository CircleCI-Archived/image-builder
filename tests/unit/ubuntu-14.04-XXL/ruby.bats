#!/usr/bin/env bats

load ../test_helper_ruby
load ../bats-support/load
load ../bats-assert/load

@test "ruby: all versions are installed" {
    ruby_test_all_installed
}

# Run this test first before version is changed by subsequent tests
@test "ruby: default is 2.2.6" {
    run ruby_test_version 2.2.6

    assert_success
}

@test "ruby: 2.1.8 works" {
    run test_ruby 2.1.8
    assert_success
}

@test "ruby: 2.1.9 works" {
    run test_ruby 2.1.9
    assert_success
}

@test "ruby: 2.2.6 works" {
    run test_ruby 2.2.6
    assert_success
}

@test "ruby: 2.2.7 works" {
    run test_ruby 2.2.7
    assert_success
}

@test "ruby: 2.3.4 works" {
    run test_ruby 2.3.4
    assert_success
}

@test "ruby: 2.3.5 works" {
    run test_ruby 2.3.5
    assert_success
}

@test "ruby: 2.4.1 works" {
    run test_ruby 2.4.1
    assert_success
}

@test "ruby: 2.4.2 works" {
    run test_ruby 2.4.2
    assert_success
}
