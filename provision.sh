#!/bin/bash
export VERBOSE=true
export CIRCLECI_USER=circleci

set -ex

cp circleci-install /usr/local/bin/circleci-install
cp -r circleci-provision-scripts /opt/circleci-provision-scripts
circleci-install base_requirements && circleci-install circleci_specific

circleci-install java oraclejdk8 && circleci-install java openjdk8

for package in sysadmin devtools jq; do circleci-install $package; done

# Docker have be last - to utilize cache better
circleci-install docker && circleci-install docker_compose

# For some reason dpkg might start throwing errors after VM creation
# auto correction allows to avoid
sudo dpkg --configure -a

true
