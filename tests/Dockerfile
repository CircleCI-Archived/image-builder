FROM circleci/build-image:scratch-unprivileged

ADD insecure-ssh-key.pub /home/ubuntu/.ssh/authorized_keys
RUN chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys && git clone https://github.com/sstephenson/bats.git && cd bats && ./install.sh /usr/local
