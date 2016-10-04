#!/usr/bin/env bats

@test "java: default is oraclejdk1.8" {
    run bash -c "java -version 2>&1 | grep 'Java(TM) SE Runtime Environment' | grep 1.8"

    [ "$status" -eq 0 ]
}

@test "java: openjdk8 works" {
    sudo update-alternatives --set  "java" "/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java"

    run bash -c "java -version 2>&1 | grep 'OpenJDK Runtime Environment'"
    [ "$status" -eq 0 ]

    run bash -c "java -version 2>&1 | grep 'openjdk version \"1.8'"
    [ "$status" -eq 0 ]
}

@test "java: openjdk7 works" {
    sudo update-alternatives --set  "java" "/usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java"

    run bash -c "java -version 2>&1 | grep 'OpenJDK Runtime Environment'"
    [ "$status" -eq 0 ]

    run bash -c "java -version 2>&1 | grep 'java version \"1.7'"
    [ "$status" -eq 0 ]
}

@test "java: maven works" {
    run mvn --version

    [ "$status" -eq 0 ]
}

@test "java: gradle works" {
    run gradle --version

    [ "$status" -eq 0 ]
}
