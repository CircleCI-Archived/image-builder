FROM circleci/ubuntu-server:trusty-latest

ENV VERBOSE true

# Avoid any installation scripts interact with upstart
# So divert now, but undivert at the end
# You shouldn't change the line unless you understand the consequence
RUN echo 'exit 101' > /usr/sbin/policy-rc.d \
	&& chmod +x /usr/sbin/policy-rc.d \
        && dpkg-divert --local --rename --add /sbin/initctl \
        && ln -s /bin/true /sbin/initctl

ADD circleci-install /usr/local/bin/circleci-install
ADD circleci-provision-scripts/base.sh circleci-provision-scripts/circleci-specific.sh /opt/circleci-provision-scripts/
RUN circleci-install base_requirements && circleci-install circleci_specific

# Databases
ADD circleci-provision-scripts/mysql.sh circleci-provision-scripts/mongo.sh circleci-provision-scripts/postgres.sh /opt/circleci-provision-scripts/
RUN for package in mysql_57 mongo postgres postgres_ext_postgis; do circleci-install $package; done

# Installing java early beacuse a few things have the dependency to java (i.g. cassandra)
ADD circleci-provision-scripts/java.sh /opt/circleci-provision-scripts/java.sh
RUN circleci-install java oraclejdk8 && circleci-install java openjdk8

ADD circleci-provision-scripts/misc.sh /opt/circleci-provision-scripts/misc.sh
RUN for package in sysadmin devtools jq redis memcached rabbitmq neo4j elasticsearch beanstalkd cassandra riak couchdb; do circleci-install $package; done

# Dislabe services by default
RUN for s in apache2 memcached rabbitmq-server neo4j neo4j-service elasticsearch beanstalkd cassandra riak couchdb; do sysv-rc-conf $s off; done

# Browsers
ADD circleci-provision-scripts/firefox.sh circleci-provision-scripts/chrome.sh circleci-provision-scripts/phantomjs.sh /opt/circleci-provision-scripts/
RUN circleci-install firefox && circleci-install chrome && circleci-install phantomjs

# Android
ADD circleci-provision-scripts/android-sdk.sh /opt/circleci-provision-scripts/android-sdk.sh
RUN circleci-install android_sdk platform-tools
RUN circleci-install android_sdk extra-android-support
RUN for package in android-25 android-24 android-23 android-22; do circleci-install android_sdk $package; done
RUN for package in sys-img-armeabi-v7a-android-24 sys-img-armeabi-v7a-android-22; do circleci-install android_sdk $package; done
RUN for package in build-tools-25.0.1 build-tools-25.0.0 build-tools-24.0.3 build-tools-24.0.2 build-tools-24.0.1 build-tools-24.0.0 build-tools-23.0.3 build-tools-23.0.2 build-tools-22.0.1; do circleci-install android_sdk $package; done
RUN for package in android_sdk extra-android-m2repository android_sdk extra-google-m2repository android_sdk extra-google-google_play_services android_sdk addon-google_apis-google-23 android_sdk addon-google_apis-google-22; do circleci-install android_sdk $package; done

# Qt
ADD circleci-provision-scripts/qt.sh /opt/circleci-provision-scripts/qt.sh
RUN circleci-install qt

# Install deployment tools
ADD circleci-provision-scripts/awscli.sh circleci-provision-scripts/gcloud.sh circleci-provision-scripts/heroku.sh /opt/circleci-provision-scripts/
RUN for package in awscli gcloud heroku; do circleci-install $package; done

# Languages
ARG use_precompile=true
ENV USE_PRECOMPILE=$use_precompile RUN_APT_UPDATE=true
RUN curl -s https://packagecloud.io/install/repositories/circleci/trusty/script.deb.sh | sudo bash
ADD circleci-provision-scripts/python.sh /opt/circleci-provision-scripts/python.sh
RUN circleci-install python 2.7.10
RUN circleci-install python 2.7.11
RUN circleci-install python 2.7.12
RUN circleci-install python 3.1.4
RUN circleci-install python 3.1.5
RUN circleci-install python 3.2.5
RUN circleci-install python 3.2.6
RUN circleci-install python 3.3.5
RUN circleci-install python 3.3.6
RUN circleci-install python 3.4.3
RUN circleci-install python 3.4.4
RUN circleci-install python 3.5.1
RUN circleci-install python 3.5.2
RUN circleci-install python pypy-1.9
RUN circleci-install python pypy-2.6.1
RUN circleci-install python pypy-4.0.1
RUN sudo -H -i -u ubuntu pyenv global 2.7.11

ADD circleci-provision-scripts/nodejs.sh /opt/circleci-provision-scripts/nodejs.sh
RUN circleci-install nodejs 0.12.9
RUN circleci-install nodejs 4.0.0
RUN circleci-install nodejs 4.1.2
RUN circleci-install nodejs 4.2.6
RUN circleci-install nodejs 4.3.0
RUN circleci-install nodejs 4.5.0
RUN circleci-install nodejs 5.0.0
RUN circleci-install nodejs 5.1.1
RUN circleci-install nodejs 5.2.0
RUN circleci-install nodejs 5.3.0
RUN circleci-install nodejs 5.4.1
RUN circleci-install nodejs 5.5.0
RUN circleci-install nodejs 5.6.0
RUN circleci-install nodejs 5.7.0
RUN circleci-install nodejs 6.1.0
RUN sudo -H -i -u ubuntu nvm alias default 4.2.6

ADD circleci-provision-scripts/go.sh /opt/circleci-provision-scripts/go.sh
RUN circleci-install golang 1.6.2

ADD circleci-provision-scripts/ruby.sh /opt/circleci-provision-scripts/ruby.sh
RUN circleci-install ruby 2.1.8
RUN circleci-install ruby 2.1.9
RUN circleci-install ruby 2.2.4
RUN circleci-install ruby 2.2.5
RUN circleci-install ruby 2.3.0
RUN circleci-install ruby 2.3.1
RUN sudo -H -i -u ubuntu rvm use 2.2.4 --default

ADD circleci-provision-scripts/php.sh /opt/circleci-provision-scripts/php.sh
RUN circleci-install php 5.5.31
RUN circleci-install php 5.5.32
RUN circleci-install php 5.5.36
RUN circleci-install php 5.6.17
RUN circleci-install php 5.6.18
RUN circleci-install php 5.6.22
RUN circleci-install php 7.0.4
RUN circleci-install php 7.0.7
RUN circleci-install php 7.0.11
RUN sudo -H -i -u ubuntu phpenv global 5.6.17

ADD circleci-provision-scripts/clojure.sh /opt/circleci-provision-scripts/clojure.sh
RUN circleci-install clojure

ADD circleci-provision-scripts/scala.sh /opt/circleci-provision-scripts/scala.sh
RUN circleci-install scala

ADD circleci-provision-scripts/haskell.sh /opt/circleci-provision-scripts/haskell.sh
RUN circleci-install ghc 8.0.1

# Docker have be last - to utilize cache better
ADD circleci-provision-scripts/docker.sh /opt/circleci-provision-scripts/docker.sh
RUN circleci-install docker && circleci-install docker_compose

# Install CircleCI patched Docker that runs in unpriv container
RUN circleci-install circleci_docker

# Undivert upstart
# You shouldn't change the line unless you understad the consequence
RUN rm /usr/sbin/policy-rc.d && rm /sbin/initctl && dpkg-divert --rename --remove /sbin/initctl

# Add rest of provisioning files -- add at end to avoid cache invalidation
ADD circleci-provision-scripts /opt/circleci-provision-scripts

# We need Dockerfile because unit test parses Dockerfile to make sure all versions are installed
ADD targets/ubuntu-14.04-XXL/Dockerfile /opt/circleci/Dockerfile

ARG IMAGE_TAG
RUN echo $IMAGE_TAG > /opt/circleci/image_version

ADD targets/ubuntu-14.04-XXL/pkg-versions.sh /opt/circleci/bin/pkg-versions.sh

LABEL circleci.user="ubuntu"
