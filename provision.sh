#!/bin/bash
export VERBOSE=true
export CIRCLECI_USER=circleci
DOCKER_VERSION_TO_INSTALL=$1

set -ex

cp circleci-install /usr/local/bin/circleci-install
cp -r circleci-provision-scripts /opt/circleci-provision-scripts
circleci-install base_requirements && circleci-install circleci_specific

# Databases
for package in mysql_57 mongo postgres; do circleci-install $package; done

# Installing java early beacuse a few things have the dependency to java (i.g. cassandra)
circleci-install java oraclejdk8 && circleci-install java openjdk8

for package in sysadmin devtools jq redis memcached rabbitmq ; do circleci-install $package; done

# Dislabe services by default
for s in apache2 memcached rabbitmq-server neo4j neo4j-service elasticsearch beanstalkd cassandra riak couchdb mysql postgresql; do sysv-rc-conf $s off; done
echo manual | tee /etc/init/mongod.override

# Browsers
circleci-install firefox && circleci-install chrome && circleci-install phantomjs

# Install deployment tools
for package in awscli gcloud heroku; do circleci-install $package; done

# Languages
export use_precompile=true
export USE_PRECOMPILE=$use_precompile
export RUN_APT_UPDATE=true

curl -s https://packagecloud.io/install/repositories/circleci/trusty/script.deb.sh | sudo bash
circleci-install python 2.7.12
circleci-install python 3.5.2
sudo -H -i -u ${CIRCLECI_USER} pyenv global 2.7.12

circleci-install nodejs 6.1.0
sudo -H -i -u ${CIRCLECI_USER} nvm alias default 6.1.0

circleci-install golang 1.7.3

circleci-install ruby 2.3.1
sudo -H -i -u ${CIRCLECI_USER} rvm use 2.3.1 --default

circleci-install clojure

circleci-install scala

# Docker have be last - to utilize cache better
circleci-install docker ${DOCKER_VERSION_TO_INSTALL} && circleci-install docker_compose

circleci-install socat

circleci-install nsenter

# For some reason dpkg might start throwing errors after VM creation
# auto correction allows to avoid
sudo dpkg --configure -a

true
