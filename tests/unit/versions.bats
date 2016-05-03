#!/usr/bin/env bats

@test "versions.json exists" {
    run ls /opt/circleci/versions.json

    [ "$status" -eq 0 ]
}
