FROM circleci/ubuntu-server:trusty-latest

ADD circleci-install /usr/local/bin/circleci-install
ADD circleci-provision-scripts/base.sh /opt/circleci-provision-scripts/base.sh
ADD circleci-provision-scripts/circleci-specific.sh /opt/circleci-provision-scripts/circleci-specific.sh
RUN circleci-install base_requirements && circleci-install circleci_specific

LABEL circleci.user="ubuntu"
