#!/bin/bash
export VERBOSE=true
export CIRCLECI_USER=${CIRCLECI_USER:-circleci}

set -ex

cp circleci-install /usr/local/bin/circleci-install
cp -r circleci-provision-scripts /opt/circleci-provision-scripts
circleci-install base_requirements && circleci-install circleci_specific

# Installing java early beacuse a few things have the dependency to java (i.g. cassandra)
circleci-install java oraclejdk8 && circleci-install java openjdk8

for package in sysadmin devtools jq; do circleci-install $package; done

# Browsers
circleci-install firefox && circleci-install chrome && circleci-install phantomjs

# Install deployment tools
for package in awscli gcloud heroku; do circleci-install $package; done

curl -s https://packagecloud.io/install/repositories/circleci/trusty/script.deb.sh | sudo bash
circleci-install python 2.7.12
circleci-install python 3.5.2
circleci-install python 3.6.5
circleci-install python 3.7.0
sudo -H -i -u ${CIRCLECI_USER} pyenv global 2.7.12

circleci-install nodejs 6.1.0
circleci-install nodejs 8.11.2
circleci-install nodejs 10.8.0
sudo -H -i -u ${CIRCLECI_USER} nvm alias default 6.1.0

circleci-install golang 1.10.3

circleci-install ruby 2.3.1
sudo -H -i -u ${CIRCLECI_USER} rvm use 2.3.1 --default

circleci-install clojure

circleci-install scala

# Docker have be last - to utilize cache better
circleci-install docker
circleci-install docker_compose 1.23.1

circleci-install socat

circleci-install nsenter

# For some reason dpkg might start throwing errors after VM creation
# auto correction allows to avoid
sudo dpkg --configure -a

# apt-daily and apt-daily-upgrade services can potentially run on start up and lock dpkg
sudo systemctl mask apt-daily.service
sudo systemctl mask apt-daily-upgrade.service
sudo systemctl mask apt-daily.timer
sudo systemctl mask apt-daily-upgrade.timer

true
