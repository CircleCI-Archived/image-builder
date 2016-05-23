#!/usr/bin/env bats

@test "pkg-versions: versions.json is valid json" {
    run bash -c "/opt/circleci/bin/pkg-versions.sh | jq ."

    [ "$status" -eq 0 ]
}

# Making sure all version commands succeed thus no empty version string
@test "pkg-version: versions.json doesn't contain empty version" {
    run bash -c '/opt/circleci/bin/pkg-versions.sh | jq . | grep "\"\""'

    [ "$status" -eq 1 ]
}
