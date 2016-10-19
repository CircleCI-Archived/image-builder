#!/usr/bin/env bats

load ../test_helper_go

@test "go: 1.6.2 works" {
    run go_test_version 1.6.2

    [ "$status" -eq 0 ]
}

@test "go: go get works" {
    run go_test_get

    [ "$status" -eq 0 ]
}

@test "go: go build works" {
    run go_test_build

    [ "$status" -eq 0 ]
}
