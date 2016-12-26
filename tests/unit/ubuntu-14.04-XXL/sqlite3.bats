#!/usr/bin/env bats

@test "sqlite3: 3.15 is installed" {
    run bash -c "sqlite3-15 --version | grep '3.15'"

    [ "$status" -eq 0 ]
}
