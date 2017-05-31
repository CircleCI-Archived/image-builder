#!/usr/bin/env bats

load ../test_helper_php
load ../bats-support/load
load ../bats-assert/load

@test "php: all versions are installed" {
    php_test_all_installed
}

# Run this test first before version is changed by subsequent tests
@test "php: default is 5.6.17" {
    run php_test_version 5.6.17

    assert_success
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

@test "php: 7.0.4 works" {
    test_php 7.0.4
}

@test "php: 7.0.7 works" {
    test_php 7.0.7
}

@test "php: 7.0.11 works" {
    test_php 7.0.11
}

@test "php: 7.1.0 works" {
    test_php 7.1.0
}
