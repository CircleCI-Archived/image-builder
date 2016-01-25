FROM circleci/ubuntu-server:trusty-latest
ARG use_precompile=false
ENV USE_PRECOMPILE $use_precompile

# Avoid any installation scripts interact with upstart
# So divert now, but undivert at the end
# You shouldn't change the line unless you understad the consequence
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

ADD circleci-provision-scripts/misc.sh /opt/circleci-provision-scripts/misc.sh
RUN circle-env install sysadmin
RUN circle-env install devtools
RUN circle-env install redis
RUN circle-env install memcached

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

# Languages
ADD circleci-provision-scripts/python.sh /opt/circleci-provision-scripts/python.sh
RUN circle-env install python 3.5.1

ADD circleci-provision-scripts/nodejs.sh /opt/circleci-provision-scripts/nodejs.sh
RUN circle-env install nodejs v5.1.1

ADD circleci-provision-scripts/java.sh /opt/circleci-provision-scripts/java.sh
RUN circle-env install java

ADD circleci-provision-scripts/go.sh /opt/circleci-provision-scripts/go.sh
RUN circle-env install golang 1.5.2

ADD circleci-provision-scripts/ruby.sh /opt/circleci-provision-scripts/ruby.sh
RUN circle-env install ruby 2.2.2

ADD circleci-provision-scripts/php.sh /opt/circleci-provision-scripts/php.sh
RUN circle-env install php 5.6.16
RUN circle-env install php 7.0.0

ADD circleci-provision-scripts/clojure.sh /opt/circleci-provision-scripts/clojure.sh
RUN circle-env install clojure

ADD circleci-provision-scripts/scala.sh /opt/circleci-provision-scripts/scala.sh
RUN circle-env install scala

# Qt
ADD circleci-provision-scripts/qt.sh /opt/circleci-provision-scripts/qt.sh
RUN circle-env install qt

# awscli
ADD circleci-provision-scripts/awscli.sh /opt/circleci-provision-scripts/awscli.sh
RUN circleci-install awscli

# Docker have be last - to utilize cache better
ADD circleci-provision-scripts/docker.sh /opt/circleci-provision-scripts/docker.sh
RUN circle-env install docker
RUN circle-env install docker_compose

# When running in unprivileged containers, need to use CircleCI Docker fork
ARG TARGET_UNPRIVILEGED_LXC
RUN if [ "$TARGET_UNPRIVILEGED_LXC" = "true" ]; then circleci-install circleci_docker; fi

# Undivert upstart
# You shouldn't change the line unless you understad the consequence
RUN rm /usr/sbin/policy-rc.d && rm /sbin/initctl && dpkg-divert --rename --remove /sbin/initctl

LABEL circleci.user="ubuntu"
