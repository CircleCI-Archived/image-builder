#!/bin/bash

function install_oraclejdk8() {
    echo '>>> Installing Java 8'

    # We could install java8 with PPA but our inference code expects java to be installed under /usr/lib/jvm
    # so taking old approach here.
    FILE=jdk-8u40-linux-x64.gz
    URL="https://circle-downloads.s3.amazonaws.com/jdk-8u40-linux-x64.gz"
    JAVA_TMP=/tmp/java

    mkdir -p $JAVA_TMP
    pushd $JAVA_TMP

    curl -L -O $URL
    tar zxf $FILE
    mkdir -p /usr/lib/jvm
    mv ./jdk1.8.0_40 /usr/lib/jvm/jdk1.8.0

    update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0/bin/java" 1
    update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.8.0/bin/javac" 1
    update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.8.0/bin/javaws" 1

    echo 'export PATH=/usr/lib/jvm/jdk1.8.0/bin:$PATH' >> ${CIRCLECI_HOME}/.circlerc

    popd

    rm -rf $JAVA_TMP
}

function install_java() {
    [[ -e /usr/lib/jvm/jdk/1.8.0 ]] || install_oraclejdk8
    type mvn &>/dev/null || install_maven
    type gradle &>/dev/null || install_gradle
}


function install_maven() {
    echo '>>> Installing Maven'

    # Install Maven
    MAVEN_VERSION=3.2.5
    curl -sSL -o /tmp/maven.tar.gz http://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
    tar -xz -C /usr/local -f /tmp/maven.tar.gz
    ln -sf /usr/local/apache-maven-${MAVEN_VERSION} /usr/local/apache-maven
    rm -rf /tmp/maven.tar.gz

    as_user mkdir -p ${CIRCLECI_HOME}/.m2

    echo 'export M2_HOME=/usr/local/apache-maven' >> ${CIRCLECI_HOME}/.circlerc
    echo 'export MAVEN_OPTS=-Xmx2048m' >> ${CIRCLECI_HOME}/.circlerc
    echo 'export PATH=$M2_HOME/bin:$PATH' >> ${CIRCLECI_HOME}/.circlerc
}

function install_gradle() {
    echo '>>> Installing Gradle'

    GRADLE_VERSION=1.10
    URL=http://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip


    curl -sSL -o /tmp/gradle.zip $URL
    unzip -d /usr/local /tmp/gradle.zip

    echo 'export PATH=$PATH:/usr/local/gradle-1.10/bin' >> ${CIRCLECI_HOME}/.circlerc
    rm -rf /tmp/gradle.zip
}
