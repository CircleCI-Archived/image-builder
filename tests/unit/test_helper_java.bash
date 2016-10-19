java_test_orackejdk1.8_default () {
    run bash -c "java -version 2>&1 | grep 'Java(TM) SE Runtime Environment' | grep 1.8"

    [ "$status" -eq 0 ]
}

 java_test_oraclejdk8 (){
    sudo update-alternatives --set  "java" "/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java"

    run bash -c "java -version 2>&1 | grep 'OpenJDK Runtime Environment'"
    [ "$status" -eq 0 ]

    run bash -c "java -version 2>&1 | grep 'openjdk version \"1.8'"
    [ "$status" -eq 0 ]
}

java_test_oraclejdk7() {
    sudo update-alternatives --set  "java" "/usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java"

    run bash -c "java -version 2>&1 | grep 'OpenJDK Runtime Environment'"
    [ "$status" -eq 0 ]

    run bash -c "java -version 2>&1 | grep 'java version \"1.7'"
    [ "$status" -eq 0 ]
}
