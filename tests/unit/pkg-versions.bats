#!/usr/bin/env bats

function versions-json-path () {
    echo "/opt/circleci/versions.json"
}

@test "pkg-versions: versions.json exists" {
    skip "Fixing regression is my priority"
    run ls $(versions-json-path)

    [ "$status" -eq 0 ]
}

@test "pkg-versions: versions.json is valid json" {
    skip "Fixing regression is my priority"
    run jq . < $(versions-json-path)

    [ "$status" -eq 0 ]
}

# Making sure all version commands succeed thus no empty version string
@test "pkg-version: versions.json doesn't contain empty version" {
    skip "Fixing regression is my priority"
    # We can be better with complex jq but this works for now
    run grep "\"\"" $(versions-json-path)

    [ "$status" -eq 1 ]
}
