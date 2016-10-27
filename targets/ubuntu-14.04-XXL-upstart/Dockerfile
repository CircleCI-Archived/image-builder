FROM circleci/build-image:ubuntu-14.04-XXL-756-60ebe77

ARG IMAGE_TAG

RUN echo 'source /home/ubuntu/.circlerc &>/dev/null' >> /root/.bashrc

RUN echo $IMAGE_TAG > /opt/circleci/image_version

ADD targets/ubuntu-14.04-XXL-upstart/pkg-versions.sh /opt/circleci/bin/pkg-versions.sh

USER root

CMD ["/sbin/init"]
