java_test_oraclejdk1.8_default () {
    run bash -c "update-alternatives --display java | grep 'link currently points to /usr/lib/jvm/jdk1.8.0/bin/java'"

    [ "$status" -eq 0 ]
}

java_test_oraclejdk7 (){
    sudo update-alternatives --set "java" "/usr/lib/jvm/jdk1.7.0/bin/java"

    run bash -c "java -version 2>&1 | grep 'Java(TM)'"
    [ "$status" -eq 0 ]

    run bash -c "java -version 2>&1 | grep 'java version \"1.7'"
    [ "$status" -eq 0 ]
}

java_test_oraclejdk8 (){
    sudo update-alternatives --set "java" "/usr/lib/jvm/jdk1.8.0/bin/java"

    run bash -c "java -version 2>&1 | grep 'Java(TM)'"
    [ "$status" -eq 0 ]

    run bash -c "java -version 2>&1 | grep 'java version \"1.8'"
    [ "$status" -eq 0 ]
}

java_test_oraclejdk9 (){
    sudo update-alternatives --set "java" "/usr/lib/jvm/java-9-oracle/bin/java"

    run bash -c "java -version 2>&1 | grep 'Java(TM)'"
    [ "$status" -eq 0 ]

    run bash -c "java -version 2>&1 | grep 'java version \"9.0.1'"
    [ "$status" -eq 0 ]
}

java_test_openjdk7() {
    sudo update-alternatives --set "java" "/usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java"

    run bash -c "java -version 2>&1 | grep 'OpenJDK Runtime Environment'"
    [ "$status" -eq 0 ]

    run bash -c "java -version 2>&1 | grep 'java version \"1.7'"
    [ "$status" -eq 0 ]
}

java_test_openjdk8() {
    sudo update-alternatives --set  "java" "/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java"

    run bash -c "java -version 2>&1 | grep 'OpenJDK Runtime Environment'"
    [ "$status" -eq 0 ]

    run bash -c "java -version 2>&1 | grep 'openjdk version \"1.8'"
    [ "$status" -eq 0 ]
}
