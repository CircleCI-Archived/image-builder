#!/usr/bin/env bats

load ../test_helper_java

@test "java: default is oraclejdk1.8" {
    java_test_oraclejdk1.8_default
}

@test "java: oraclejdk7 works" {
    java_test_oraclejdk7
}

@test "java: oraclejdk8 works" {
    java_test_oraclejdk8
}

@test "java: openjdk7 works" {
    java_test_openjdk7
}

@test "java: openjdk8 works" {
    java_test_openjdk8
}

@test "java: maven works" {
    run mvn --version

    [ "$status" -eq 0 ]
}

@test "java: gradle works" {
    run gradle --version

    [ "$status" -eq 0 ]
}
