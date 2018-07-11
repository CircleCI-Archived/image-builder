#!/bin/bash

function set_default_version() {
    # Set jdk1.8.0 to the default version
    update-alternatives --set  "java" "/usr/lib/jvm/jdk1.8.0/bin/java"
    update-alternatives --set  "javac" "/usr/lib/jvm/jdk1.8.0/bin/javac"
    update-alternatives --set  "javaws" "/usr/lib/jvm/jdk1.8.0/bin/javaws"
    update-alternatives --set  "javadoc" "/usr/lib/jvm/jdk1.8.0/bin/javadoc"
}

function _install_oraclejdk() {
    local VERSION=$1
    local RELEASE=$2

    local FILE="jdk-${VERSION}u${RELEASE}-linux-x64.tar.gz"
    local URL="https://circle-downloads.s3.amazonaws.com/$FILE"
    local JAVA_TMP=/tmp/java
    local JDK="jdk1.${VERSION}.0_${RELEASE}"
    local INSTALL_PATH="/usr/lib/jvm/jdk1.${VERSION}.0"

    mkdir -p $JAVA_TMP
    pushd $JAVA_TMP

    curl -L -O $URL
    tar zxf $FILE
    mkdir -p /usr/lib/jvm
    mv ./$JDK $INSTALL_PATH

    update-alternatives --install "/usr/bin/java" "java" "${INSTALL_PATH}/bin/java" $VERSION
    update-alternatives --install "/usr/bin/javac" "javac" "${INSTALL_PATH}/bin/javac" $VERSION
    update-alternatives --install "/usr/bin/javaws" "javaws" "${INSTALL_PATH}/bin/javaws" $VERSION
    update-alternatives --install "/usr/bin/javadoc" "javadoc" "${INSTALL_PATH}/bin/javadoc" $VERSION

    popd

    rm -rf $JAVA_TMP
}

function install_oraclejdk7() {
    echo '>>> Installing Oracle Java 7'

    _install_oraclejdk 7 181
}

function install_oraclejdk8() {
    echo '>>> Installing Oracle Java 8'

    _install_oraclejdk 8 102
    set_default_version
}

function install_oraclejdk9() {
    echo '>>> Installing Oracle Java 9'

    add-apt-repository --yes ppa:webupd8team/java
    apt-get update

    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
    apt-get install oracle-java9-installer

    set_default_version
}

function _install_openjdk() {

    local version=$1
    local package="openjdk-$version-jdk"

    add-apt-repository -y ppa:openjdk-r/ppa
    apt-get update
    apt-get install $package
}

function install_openjdk7() {
    _install_openjdk 7
}

function install_openjdk8() {
    _install_openjdk 8
}

function install_java() {
    local VERSION=$1

    install_$VERSION

    [[ -e /usr/local/apache-maven/bin/mvn ]] || install_maven
    [[ -e /usr/local/gradle-1.10 ]] || install_gradle
    type ant &>/dev/null || apt-get install ant
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
