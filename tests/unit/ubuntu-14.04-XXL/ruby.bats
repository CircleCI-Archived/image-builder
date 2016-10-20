#!/usr/bin/env bats

load ../test_helper_ruby

@test "ruby: all versions are installed" {
    ruby_test_all_installed
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
