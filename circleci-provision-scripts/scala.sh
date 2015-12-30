#!/bin/bash

function install_scala() {
    curl -sSL -o /tmp/scala.deb http://apt.typesafe.com/repo-deb-build-0002.deb
    dpkg -i /tmp/scala.deb
    rm -rf /tmp/scala.deb

    apt-get update
    apt-get install typesafe-stack

    # Maybe it's my bug but sbt doesn't respect the default java set by update-alternatives previously.
    # Using --set will make sbt to use the correct java.
    update-alternatives --set java /usr/lib/jvm/jdk1.8.0/bin/java

    # Force dependencies to download
    as_user sbt -batch
}
