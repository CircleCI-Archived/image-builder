FROM circleci/build-image:ubuntu-14.04-XXL-1167-271bbe4

ARG IMAGE_TAG

RUN echo 'source /home/ubuntu/.circlerc &>/dev/null' >> /root/.bashrc

RUN echo $IMAGE_TAG > /opt/circleci/image_version

ADD targets/ubuntu-14.04-XXL-upstart/pkg-versions.sh /opt/circleci/bin/pkg-versions.sh

# Workaround for https://github.com/nimiq/docker-postgresql93/issues/2
RUN mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R postgres /etc/ssl/private

USER root

CMD ["/sbin/init"]

LABEL com.circleci.user="ubuntu"
