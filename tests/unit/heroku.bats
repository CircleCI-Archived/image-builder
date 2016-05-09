#!/usr/bin/env bats

@test "heroku: heroku-cli works" {
    run heroku --version

    [ "$status" -eq 0 ]
}

@test "heroku: config dir is writable by user" {
    run touch ~/.config/heroku/foo

    [ "$status" -eq 0 ]
}
