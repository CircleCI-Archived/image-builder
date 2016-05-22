FROM circleci/ubuntu-server:trusty-latest

ADD circleci-install /usr/local/bin/circleci-install

ADD circleci-provision-scripts /opt/circleci-provision-scripts

RUN circleci-install base_requirements

RUN circleci-install circleci_specific

LABEL circleci.user="ubuntu"
