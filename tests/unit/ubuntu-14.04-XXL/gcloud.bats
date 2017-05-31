#!/usr/bin/env bats

load ../test_helper_go
load ../bats-support/load
load ../bats-assert/load

@test "gcloud works" {
    run gcloud --version

    assert_success
}
