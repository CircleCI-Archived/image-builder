#!/bin/bash

function install_docker() {
    echo '>>>> Installing Docker'

    curl https://get.docker.com/ | sh
    useradd -m -s /bin/bash circleci
    sudo usermod -aG docker circleci
}

function install_circleci_docker() {
    echo '>>> Install CircleCI Docker fork that runs on user namespaces'

    # Install LXC and btrfs-tools
    apt-get -y install lxc btrfs-tools

    # DNS forwarding doesn't work without this line which causes container unable to resolve DNS
    sed -i 's|10.0.3|10.0.4|g' /etc/default/lxc-net

    # Divert plain docker
    sudo dpkg-divert --add --rename --divert /usr/bin/docker.plain /usr/bin/docker

    # Replace with CircleCI's patched docker
    sudo curl -L -o /usr/bin/docker.circleci 'https://s3.amazonaws.com/circle-downloads/docker-1.9.1-circleci'
    sudo chmod 0755 /usr/bin/docker.circleci

    # --userland-proxy=false: Docker's userland proxy is broken. Don't use it.
    echo 'DOCKER_OPTS="-s btrfs -e lxc -D --userland-proxy=false"' > /etc/default/docker

    sudo ln -s /usr/bin/docker.circleci /usr/bin/docker
}

function install_docker_compose() {
    echo '>>>> Installing Docker compose'

    VERSION=1.9.0
    CHECKSUM=eeca988428d29534fecdff2768fa2e8c293b812b1c77da8ab5daf7f441c92e5b

    curl -L -o /tmp/docker-compose https://github.com/docker/compose/releases/download/${VERSION}/docker-compose-Linux-x86_64
    echo "$CHECKSUM /tmp/docker-compose" | sha256sum -c
    chmod +x /tmp/docker-compose
    sudo mv /tmp/docker-compose /usr/local/bin/docker-compose
}
