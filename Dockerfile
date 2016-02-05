FROM circleci/ubuntu-server:trusty-latest

# Avoid any installation scripts interact with upstart
# So divert now, but undivert at the end
# You shouldn't change the line unless you understad the consequence
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

ADD circleci-provision-scripts/misc.sh /opt/circleci-provision-scripts/misc.sh
RUN circleci-install sysadmin
RUN circleci-install devtools
RUN circleci-install redis

# Browsers
ADD circleci-provision-scripts/firefox.sh /opt/circleci-provision-scripts/firefox.sh
RUN circleci-install firefox_version 42.0

ADD circleci-provision-scripts/chrome.sh /opt/circleci-provision-scripts/chrome.sh
RUN circleci-install chrome

# Languages
ADD circleci-provision-scripts/python.sh /opt/circleci-provision-scripts/python.sh
RUN circleci-install python 2.7.6

ADD circleci-provision-scripts/java.sh /opt/circleci-provision-scripts/java.sh
RUN circleci-install java

ADD circleci-provision-scripts/nodejs.sh /opt/circleci-provision-scripts/nodejs.sh
RUN circleci-install nodejs v0.12.7
RUN su ubuntu -c 'source ~/.circlerc && npm install -g npm@2.11.3'

# awscli
ADD circleci-provision-scripts/awscli.sh /opt/circleci-provision-scripts/awscli.sh
RUN circleci-install awscli

# Docker have be last - to utilize cache better
ADD circleci-provision-scripts/docker.sh /opt/circleci-provision-scripts/docker.sh
RUN circleci-install docker
RUN circleci-install docker_compose
RUN circleci-install circleci_docker

# Undivert upstart
# You shouldn't change the line unless you understad the consequence
RUN rm /usr/sbin/policy-rc.d && rm /sbin/initctl && dpkg-divert --rename --remove /sbin/initctl

LABEL circleci.user="ubuntu"
