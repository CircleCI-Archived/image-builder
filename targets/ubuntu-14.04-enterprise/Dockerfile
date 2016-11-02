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
ADD circleci-provision-scripts/ /opt/circleci-provision-scripts/
Add targets/ubuntu-14.04-enterprise/install /usr/local/bin/install-base-image

ARG use_precompile=true
ENV USE_PRECOMPILE=$use_precompile RUN_APT_UPDATE=true
RUN install-base-image

# We need Dockerfile because unit test parses Dockerfile to make sure all versions are installed
ADD targets/ubuntu-14.04-enterprise/Dockerfile /opt/circleci/Dockerfile

ARG IMAGE_TAG
RUN echo $IMAGE_TAG > /opt/circleci/image_version

ADD targets/ubuntu-14.04-enterprise/pkg-versions.sh /opt/circleci/bin/pkg-versions.sh

LABEL circleci.user="ubuntu"
