#!/bin/bash

function install_mongo() {
    MONGO_MAJOR=3.0
    MONGO_VERSION=3.0.7

    echo '>>>> Install Mongo $VERSION'

    # From http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/

    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
    echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/${MONGO_MAJOR} multiverse" \
        | tee /etc/apt/sources.list.d/mongodb-org-${MONGO_MAJOR}.list
    apt-get update

    apt-get install -y \
            --no-install-recommends \
            ca-certificates curl \
            numactl \
            mongodb-org=$MONGO_VERSION \
            mongodb-org-server=$MONGO_VERSION \
            mongodb-org-shell=$MONGO_VERSION \
            mongodb-org-mongos=$MONGO_VERSION \
            mongodb-org-tools=$MONGO_VERSION

    rm -rf /var/lib/mongodb \
    mv /etc/mongod.conf /etc/mongod.conf.orig

    # Customize mongo more
    echo 'noprealloc = true' >> /etc/mongod.conf
    echo 'nojournal = true' >> /etc/mongod.conf
    echo 'smallfiles = true' >> /etc/mongod.conf

    mkdir -p /data/db && chown -R mongodb:mongodb /data/db

    rm -rf /var/lib/mongodb/journal/prealloc.*
    rm -rf /var/lib/mongodb/journal/j.*
}
