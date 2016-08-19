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
ADD circleci-provision-scripts/postgres.sh /opt/circleci-provision-scripts/
RUN for package in postgres postgres_ext_postgis; do circleci-install $package; done

# Installing java early beacuse a few things have the dependency to java (i.g. cassandra)
ADD circleci-provision-scripts/java.sh /opt/circleci-provision-scripts/java.sh
RUN circleci-install java oraclejdk8 && circleci-install java openjdk8

ADD circleci-provision-scripts/misc.sh /opt/circleci-provision-scripts/misc.sh
RUN for package in sysadmin devtools jq redis memcached rabbitmq elasticsearch beanstalkd; do circleci-install $package; done

# Dislabe services by default
RUN for s in apache2 memcached rabbitmq-server elasticsearch beanstalkd; do sysv-rc-conf $s off; done

# Browsers
ADD circleci-provision-scripts/firefox.sh circleci-provision-scripts/chrome.sh circleci-provision-scripts/phantomjs.sh /opt/circleci-provision-scripts/
RUN circleci-install firefox && circleci-install chrome && circleci-install phantomjs

# Install deployment tools
ADD circleci-provision-scripts/awscli.sh circleci-provision-scripts/gcloud.sh circleci-provision-scripts/heroku.sh /opt/circleci-provision-scripts/
RUN for package in awscli gcloud heroku; do circleci-install $package; done

# Languages
ARG use_precompile=true
ENV USE_PRECOMPILE=$use_precompile RUN_APT_UPDATE=true
RUN curl -s https://packagecloud.io/install/repositories/circleci/trusty/script.deb.sh | sudo bash

ADD circleci-provision-scripts/nodejs.sh /opt/circleci-provision-scripts/nodejs.sh
RUN circleci-install nodejs 0.10.28
RUN circleci-install nodejs 6.1.0
RUN sudo -H -i -u ubuntu nvm alias default 0.10.28

ADD circleci-provision-scripts/ruby.sh /opt/circleci-provision-scripts/ruby.sh
RUN circleci-install ruby 2.3.1
RUN sudo -H -i -u ubuntu rvm use 2.3.1 --default

# Install and use our (GoCardless) version of elasticsearch :(
RUN curl -o elasticsearch-1.1.1.tar.gz 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.1.tar.gz' \
  && tar zxf elasticsearch-1.1.1.tar.gz \
  && nohup bash -c "./elasticsearch-1.1.1/bin/elasticsearch &"

# Docker have be last - to utilize cache better
ADD circleci-provision-scripts/docker.sh /opt/circleci-provision-scripts/docker.sh
RUN circleci-install docker && circleci-install docker_compose

# When running in unprivileged containers, need to use CircleCI Docker fork
ARG TARGET_UNPRIVILEGED_LXC
RUN if [ "$TARGET_UNPRIVILEGED_LXC" = "true" ]; then circleci-install circleci_docker; fi

# Undivert upstart
# You shouldn't change the line unless you understad the consequence
RUN rm /usr/sbin/policy-rc.d && rm /sbin/initctl && dpkg-divert --rename --remove /sbin/initctl

# Add rest of provisioning files -- add at end to avoid cache invalidation
ADD circleci-provision-scripts /opt/circleci-provision-scripts

# We need Dockerfile because unit test parses Dockerfile to make sure all versions are installed
ADD Dockerfile /opt/circleci/Dockerfile

ARG IMAGE_TAG
RUN echo $IMAGE_TAG > /opt/circleci/image_version

ADD pkg-versions.sh /opt/circleci/bin/pkg-versions.sh

LABEL circleci.user="ubuntu"
