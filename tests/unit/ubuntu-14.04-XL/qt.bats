#!/usr/bin/env bats

load ../bats-support/load
load ../bats-assert/load

@test "qt: default is 5.2" {
    run bash -c "qmake -query QT_VERSION | grep 5.2"

    assert_success
}

@test "qt: switching to 5.5 works" {
    run bash -c "source /opt/qt55/bin/qt55-env.sh && qmake -query QT_VERSION | grep 5.5"

    assert_success
}

# You don't want to run these tests at every build since building capybara-webkit is slow
#@test "qt: building capybara-webkit with 5.2 works" {
#    run gem install capybara-webkit
#
#    assert_success
#}
#
#@test "qt: building capybara-webkit with 5.5 works" {
#    run bash -c "source /opt/qt55/bin/qt55-env.sh && QMAKE=/opt/qt55/bin/qmake gem install capybara-webkit"
#
#    assert_success
#}
