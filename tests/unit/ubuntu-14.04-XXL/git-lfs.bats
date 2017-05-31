#!/usr/bin/env bats

load ../test_helper_go

@test "git-lfs: 1.5.4 works" {
    run bash -c "git-lfs | grep 1.5.4"

    [ "$status" -eq 0 ]
}
