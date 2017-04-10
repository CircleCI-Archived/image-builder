#!/usr/bin/env bats

load ../test_helper_go

@test "gcloud works" {
    gcloud --version

    [ "$status" -eq 0 ]
}

