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
RUN circleci-install base_requirements && circleci-install circleci_specific

# Installing java early beacuse a few things have the dependency to java (i.g. cassandra)
ADD circleci-provision-scripts/java.sh /opt/circleci-provision-scripts/java.sh
RUN circleci-install java oraclejdk8 && circleci-install java openjdk8

# Android
ADD circleci-provision-scripts/android-sdk.sh /opt/circleci-provision-scripts/android-sdk.sh
RUN circleci-install android_sdk platform-tools
RUN circleci-install android_sdk extra-android-support
RUN circleci-install android_sdk android-23
RUN circleci-install android_sdk android-22
RUN circleci-install android_sdk build-tools-23.0.3
RUN circleci-install android_sdk build-tools-23.0.2
RUN circleci-install android_sdk build-tools-22.0.1
RUN circleci-install android_sdk extra-android-m2repository
RUN circleci-install android_sdk extra-google-m2repository
RUN circleci-install android_sdk extra-google-google_play_services
RUN circleci-install android_sdk addon-google_apis-google-23
RUN circleci-install android_sdk addon-google_apis-google-22

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
RUN sudo -H -i -u ubuntu bash -c "/opt/circleci/bin/pkg-versions.sh | jq . > /opt/circleci/versions.json"

LABEL circleci.user="ubuntu"
