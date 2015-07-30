#!/bin/bash

set -ex

echo '>>>> Install Mongo 3.0'

# From http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.0.list
apt-get update

sudo apt-get install -y mongodb-org

# Customize mongo more
echo 'noprealloc = true' >> /etc/mongodb.conf
echo 'nojournal = true' >> /etc/mongodb.conf
echo 'smallfiles = true' >> /etc/mongodb.conf

service mongod stop
rm -rf /var/lib/mongodb/journal/prealloc.*
rm -rf /var/lib/mongodb/journal/j.*

service mongod start
service mongod stop
