FROM circleci/ubuntu-server:trusty-latest

ADD circleci-install /usr/local/bin/circleci-install

ADD circleci-provision-scripts /opt/circleci-provision-scripts

LABEL circleci.user="ubuntu"
