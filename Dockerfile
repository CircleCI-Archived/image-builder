FROM circleci/ubuntu-server:trusty-latest

# Avoid any installation scripts interact with upstart
# So divert now, but undivert at the end
RUN echo 'exit 101' > /usr/sbin/policy-rc.d \
	&& chmod +x /usr/sbin/policy-rc.d \
        && dpkg-divert --local --rename --add /sbin/initctl \
        && ln -s /bin/true /sbin/initctl

ADD circleci-install /usr/local/bin/circleci-install

ADD circleci-provision-scripts/base.sh /opt/circleci-provision-scripts/base.sh
ADD circleci-provision-scripts/circleci-specific.sh /opt/circleci-provision-scripts/circleci-specific.sh
RUN circleci-install base_requirements  && circleci-install circleci_specific

ADD circleci-provision-scripts /opt/circleci-provision-scripts

# Android
ADD scripts/circle-android /usr/local/bin/circle-android
RUN circleci-install android_sdk platform-tools
RUN circleci-install android_sdk android-22
RUN circleci-install android_sdk android-23

## Databases

RUN circleci-install mysql_56

RUN circleci-install mongo
RUN circleci-install postgres

RUN circleci-install redis
RUN circleci-install memcached

# Install Docker
RUN circleci-install lxc_docker
RUN circleci-install docker_compose

# Browser
RUN circleci-install firefox
RUN circleci-install chrome

# Languages
RUN circleci-install oraclejdk8
RUN circleci-install golang

RUN circleci-install ruby 2.2.2

RUN circleci-install python 3.5.1

RUN circleci-install nodejs v5.1.1

#RUN circleci-install scala

# Qt5
RUN circleci-install qt

# Undivert upstart
RUN rm /usr/sbin/policy-rc.d && rm /sbin/initctl && dpkg-divert --rename --remove /sbin/initctl


LABEL circleci.user="ubuntu"
