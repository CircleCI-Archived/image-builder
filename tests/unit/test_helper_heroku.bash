heroku_test_heroku_cli () {
    run heroku --version

    [ "$status" -eq 0 ]
}

heroku_test_config_writable () {
    run touch ~/.config/heroku/foo

    [ "$status" -eq 0 ]
}
