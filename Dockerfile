FROM circleci/ubuntu-server:trusty-latest
ARG use_precompile=false
ENV USE_PRECOMPILE $use_precompile

# Avoid any installation scripts interact with upstart
# So divert now, but undivert at the end
# You shouldn't change the line unless you understand the consequence
RUN echo 'exit 101' > /usr/sbin/policy-rc.d \
        && chmod +x /usr/sbin/policy-rc.d \
        && dpkg-divert --local --rename --add /sbin/initctl \
        && ln -s /bin/true /sbin/initctl

ADD circle-env /usr/local/bin/circle-env
ADD circleci-provision-scripts/base.sh /opt/circleci-provision-scripts/base.sh
ADD circleci-provision-scripts/circleci-specific.sh /opt/circleci-provision-scripts/circleci-specific.sh
RUN curl -s https://packagecloud.io/install/repositories/circleci/circleci/script.deb.sh | bash
RUN circle-env install base_requirements && circle-env install circleci_specific

ADD circleci-provision-scripts/helper.sh /opt/circleci-provision-scripts/helper.sh

# Databases
ADD circleci-provision-scripts/mysql.sh /opt/circleci-provision-scripts/mysql.sh
RUN circle-env install mysql_56

ADD circleci-provision-scripts/mongo.sh /opt/circleci-provision-scripts/mongo.sh
RUN circle-env install mongo

ADD circleci-provision-scripts/postgres.sh /opt/circleci-provision-scripts/postgres.sh
RUN circle-env install postgres
RUN circle-env install postgres_ext_postgis

ADD circleci-provision-scripts/misc.sh /opt/circleci-provision-scripts/misc.sh
RUN circle-env install sysadmin
RUN circle-env install devtools
RUN circle-env install redis
RUN circle-env install memcached
RUN circle-env install rabbitmq
RUN circle-env install neo4j
RUN circle-env install elasticsearch
RUN circle-env install beanstalkd

# Browsers
ADD circleci-provision-scripts/firefox.sh /opt/circleci-provision-scripts/firefox.sh
RUN circle-env install firefox

ADD circleci-provision-scripts/chrome.sh /opt/circleci-provision-scripts/chrome.sh
RUN circle-env install chrome

ADD circleci-provision-scripts/phantomjs.sh /opt/circleci-provision-scripts/phantomjs.sh
RUN circle-env install phantomjs

# Android
ADD circleci-provision-scripts/android-sdk.sh /opt/circleci-provision-scripts/android-sdk.sh
RUN circle-env install android_sdk platform-tools
RUN circle-env install android_sdk android-22
RUN circle-env install android_sdk android-23

# Qt
ADD circleci-provision-scripts/qt.sh /opt/circleci-provision-scripts/qt.sh
RUN circle-env install qt

# awscli
ADD circleci-provision-scripts/awscli.sh /opt/circleci-provision-scripts/awscli.sh
RUN circle-env install awscli

# Languages
ARG use_precompile=true
ENV USE_PRECOMPILE $use_precompile
RUN curl -s https://packagecloud.io/install/repositories/circleci/trusty/script.deb.sh | sudo bash

ADD circleci-provision-scripts/python.sh /opt/circleci-provision-scripts/python.sh
RUN circle-env install python 2.7.9
RUN circle-env install python 2.7.10
RUN circle-env install python 2.7.11
RUN circle-env install python 3.1.3
RUN circle-env install python 3.1.4
RUN circle-env install python 3.2.4
RUN circle-env install python 3.2.5
RUN circle-env install python 3.2.6
RUN circle-env install python 3.3.4
RUN circle-env install python 3.3.5
RUN circle-env install python 3.3.6
RUN circle-env install python 3.4.3
RUN circle-env install python 3.4.4
RUN circle-env install python 3.5.0
RUN circle-env install python 3.5.1
RUN circle-env install python pypy-1.9
RUN circle-env install python pypy-2.6.1
RUN circle-env install python pypy-4.0.1
# TODO: make this more robust
RUN sudo -H -u ubuntu bash -c "source ~/.circlerc; pyenv global 2.7.11"

ADD circleci-provision-scripts/nodejs.sh /opt/circleci-provision-scripts/nodejs.sh
RUN circle-env install nodejs 0.12.9
RUN circle-env install nodejs 4.0.0
RUN circle-env install nodejs 4.1.2
RUN circle-env install nodejs 4.2.6
RUN circle-env install nodejs 4.3.0
RUN circle-env install nodejs 5.0.0
RUN circle-env install nodejs 5.1.1
RUN circle-env install nodejs 5.2.0
RUN circle-env install nodejs 5.3.0
RUN circle-env install nodejs 5.4.1
RUN circle-env install nodejs 5.5.0
RUN circle-env install nodejs 5.6.0
RUN circle-env install nodejs 5.7.0


# TODO: make this more robust
RUN sudo -H -u ubuntu bash -c "source ~/.circlerc; nvm alias default 4.2.6"

ADD circleci-provision-scripts/java.sh /opt/circleci-provision-scripts/java.sh
RUN circle-env install java

ADD circleci-provision-scripts/go.sh /opt/circleci-provision-scripts/go.sh
RUN circle-env install golang 1.6

ADD circleci-provision-scripts/ruby.sh /opt/circleci-provision-scripts/ruby.sh
RUN circle-env install ruby 2.0.0-p647
RUN circle-env install ruby 2.1.6
RUN circle-env install ruby 2.1.7
RUN circle-env install ruby 2.1.8
RUN circle-env install ruby 2.2.2
RUN circle-env install ruby 2.2.3
RUN circle-env install ruby 2.2.4
RUN circle-env install ruby 2.3.0
# TODO: make this more robust
RUN sudo -H -u ubuntu bash -c "source ~/.circlerc; rvm use 2.2.4 --default"

ADD circleci-provision-scripts/php.sh /opt/circleci-provision-scripts/php.sh
RUN circle-env install php 5.5.31
RUN circle-env install php 5.5.32
RUN circle-env install php 5.6.16
RUN circle-env install php 5.6.17
RUN circle-env install php 5.6.18
RUN circle-env install php 7.0.1
RUN circle-env install php 7.0.2
RUN circle-env install php 7.0.3
# TODO: make this more robust
RUN sudo -H -u ubuntu bash -c "source ~/.circlerc; phpenv global 5.6.17"

ADD circleci-provision-scripts/clojure.sh /opt/circleci-provision-scripts/clojure.sh
RUN circle-env install clojure

ADD circleci-provision-scripts/scala.sh /opt/circleci-provision-scripts/scala.sh
RUN circle-env install scala

# Dislabe services by default
RUN sysv-rc-conf apache2 off
RUN sysv-rc-conf redis-server off
RUN sysv-rc-conf memcached off
RUN sysv-rc-conf rabbitmq-server off
RUN sysv-rc-conf neo4j off
RUN sysv-rc-conf neo4j-service off
RUN sysv-rc-conf elasticsearch off
RUN sysv-rc-conf beanstalkd off

# Docker have be last - to utilize cache better
ADD circleci-provision-scripts/docker.sh /opt/circleci-provision-scripts/docker.sh
RUN circle-env install docker
RUN circle-env install docker_compose

# When running in unprivileged containers, need to use CircleCI Docker fork
ARG TARGET_UNPRIVILEGED_LXC
RUN if [ "$TARGET_UNPRIVILEGED_LXC" = "true" ]; then circle-env install circleci_docker; fi

# Undivert upstart
# You shouldn't change the line unless you understad the consequence
RUN rm /usr/sbin/policy-rc.d && rm /sbin/initctl && dpkg-divert --rename --remove /sbin/initctl

# Add rest of provisioning files -- add at end to avoid cache invalidation
ADD circleci-provision-scripts /opt/circleci-provision-scripts

LABEL circleci.user="ubuntu"
