FROM circleci/ubuntu-server:trusty-latest

# Avoid any installation scripts interact with upstart
# So divert now, but undivert at the end
# You shouldn't change the line unless you understand the consequence
RUN echo 'exit 101' > /usr/sbin/policy-rc.d \
	&& chmod +x /usr/sbin/policy-rc.d \
        && dpkg-divert --local --rename --add /sbin/initctl \
        && ln -s /bin/true /sbin/initctl

ADD circleci-install /usr/local/bin/circleci-install

ADD circleci-provision-scripts/base.sh /opt/circleci-provision-scripts/base.sh
ADD circleci-provision-scripts/circleci-specific.sh /opt/circleci-provision-scripts/circleci-specific.sh
RUN circleci-install base_requirements  && circleci-install circleci_specific

# Databases
ADD circleci-provision-scripts/mysql.sh /opt/circleci-provision-scripts/mysql.sh
RUN circleci-install mysql_56

ADD circleci-provision-scripts/mongo.sh /opt/circleci-provision-scripts/mongo.sh
RUN circleci-install mongo

ADD circleci-provision-scripts/postgres.sh /opt/circleci-provision-scripts/postgres.sh
RUN circleci-install postgres
RUN circleci-install postgres_ext_postgis

ADD circleci-provision-scripts/misc.sh /opt/circleci-provision-scripts/misc.sh
RUN circleci-install sysadmin
RUN circleci-install devtools
RUN circleci-install redis
RUN circleci-install memcached
RUN circleci-install rabbitmq
RUN circleci-install neo4j
RUN circleci-install elasticsearch
RUN circleci-install beanstalkd

# Browsers
ADD circleci-provision-scripts/firefox.sh /opt/circleci-provision-scripts/firefox.sh
RUN circleci-install firefox

ADD circleci-provision-scripts/chrome.sh /opt/circleci-provision-scripts/chrome.sh
RUN circleci-install chrome

ADD circleci-provision-scripts/phantomjs.sh /opt/circleci-provision-scripts/phantomjs.sh
RUN circleci-install phantomjs

# Android
ADD circleci-provision-scripts/android-sdk.sh /opt/circleci-provision-scripts/android-sdk.sh
RUN circleci-install android_sdk platform-tools
RUN circleci-install android_sdk android-22
RUN circleci-install android_sdk android-23

# Qt
ADD circleci-provision-scripts/qt.sh /opt/circleci-provision-scripts/qt.sh
RUN circleci-install qt

# awscli
ADD circleci-provision-scripts/awscli.sh /opt/circleci-provision-scripts/awscli.sh
RUN circleci-install awscli

# Languages
ARG use_precompile=true
ENV USE_PRECOMPILE $use_precompile
RUN curl -s https://packagecloud.io/install/repositories/circleci/trusty/script.deb.sh | sudo bash

ADD circleci-provision-scripts/python.sh /opt/circleci-provision-scripts/python.sh
RUN circleci-install python 2.7.10
RUN circleci-install python 2.7.11
RUN circleci-install python 3.1.3
RUN circleci-install python 3.1.4
RUN circleci-install python 3.2.5
RUN circleci-install python 3.2.6
RUN circleci-install python 3.3.5
RUN circleci-install python 3.3.6
RUN circleci-install python 3.4.3
RUN circleci-install python 3.4.4
RUN circleci-install python 3.5.0
RUN circleci-install python 3.5.1
RUN circleci-install python pypy-1.9
RUN circleci-install python pypy-2.6.1
RUN circleci-install python pypy-4.0.1
# TODO: make this more robust
RUN sudo -H -u ubuntu bash -c "source ~/.circlerc; pyenv global 2.7.11"

ADD circleci-provision-scripts/nodejs.sh /opt/circleci-provision-scripts/nodejs.sh
RUN circleci-install nodejs 0.12.9
RUN circleci-install nodejs 4.0.0
RUN circleci-install nodejs 4.1.2
RUN circleci-install nodejs 4.2.6
RUN circleci-install nodejs 4.3.0
RUN circleci-install nodejs 5.0.0
RUN circleci-install nodejs 5.1.1
RUN circleci-install nodejs 5.2.0
RUN circleci-install nodejs 5.3.0
RUN circleci-install nodejs 5.4.1
RUN circleci-install nodejs 5.5.0
RUN circleci-install nodejs 5.6.0
RUN circleci-install nodejs 5.7.0

# TODO: make this more robust
RUN sudo -H -u ubuntu bash -c "source ~/.circlerc; nvm alias default 4.2.6"

ADD circleci-provision-scripts/java.sh /opt/circleci-provision-scripts/java.sh
RUN circleci-install java

ADD circleci-provision-scripts/go.sh /opt/circleci-provision-scripts/go.sh
RUN circleci-install golang 1.6

ADD circleci-provision-scripts/ruby.sh /opt/circleci-provision-scripts/ruby.sh
RUN circleci-install ruby 2.0.0-p647
RUN circleci-install ruby 2.1.7
RUN circleci-install ruby 2.1.8
RUN circleci-install ruby 2.2.3
RUN circleci-install ruby 2.2.4
RUN circleci-install ruby 2.3.0
# TODO: make this more robust
RUN sudo -H -u ubuntu bash -c "source ~/.circlerc; rvm use 2.2.4 --default"

ADD circleci-provision-scripts/php.sh /opt/circleci-provision-scripts/php.sh
RUN circleci-install php 5.5.31
RUN circleci-install php 5.5.32
RUN circleci-install php 5.6.17
RUN circleci-install php 5.6.18
RUN circleci-install php 7.0.2
RUN circleci-install php 7.0.3
# TODO: make this more robust
RUN sudo -H -u ubuntu bash -c "source ~/.circlerc; phpenv global 5.6.17"

ADD circleci-provision-scripts/clojure.sh /opt/circleci-provision-scripts/clojure.sh
RUN circleci-install clojure

ADD circleci-provision-scripts/scala.sh /opt/circleci-provision-scripts/scala.sh
RUN circleci-install scala

# Dislabe services by default
RUN for s in apache2 redis-server memcached rabbitmq-server neo4j neo4j-service elasticsearch beanstalkd; do sysv-rc-conf $s off; done

# Docker have be last - to utilize cache better
ADD circleci-provision-scripts/docker.sh /opt/circleci-provision-scripts/docker.sh
RUN circleci-install docker
RUN circleci-install docker_compose

# When running in unprivileged containers, need to use CircleCI Docker fork
ARG TARGET_UNPRIVILEGED_LXC
RUN if [ "$TARGET_UNPRIVILEGED_LXC" = "true" ]; then circleci-install circleci_docker; fi

# Undivert upstart
# You shouldn't change the line unless you understad the consequence
RUN rm /usr/sbin/policy-rc.d && rm /sbin/initctl && dpkg-divert --rename --remove /sbin/initctl

# Add rest of provisioning files -- add at end to avoid cache invalidation
ADD circleci-provision-scripts /opt/circleci-provision-scripts

LABEL circleci.user="ubuntu"
