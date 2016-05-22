FROM circleci/ubuntu-server:trusty-latest

ADD circleci-provision-scripts /opt/circleci-provision-scripts

LABEL circleci.user="ubuntu"
