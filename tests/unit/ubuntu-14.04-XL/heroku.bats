#!/usr/bin/env bats

load ../test_helper_heroku

@test "heroku: heroku-cli works" {
    heroku_test_heroku_cli
}

@test "heroku: config dir is writable by user" {
    heroku_test_config_writable
}
