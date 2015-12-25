#!/bin/bash

function install_lxc_docker() {
    echo '>>>> Installing Docker'

    # Install LXC and btrfs-tools
    apt-get -y install lxc btrfs-tools

    # DNS forwarding doesn't work without this line which causes container unable to resolve DNS
    sed -i 's|10.0.3|10.0.4|g' /etc/default/lxc-net

    # Install Docker
    curl -L -s https://get.docker.io/ | sh

    # Devicemapper files are huge if got created - we don't use device mapper anyway
    rm -rf /var/lib/docker/devicemapper/devicemapper/data
    rm -rf /var/lib/docker/devicemapper/devicemapper/metadata

    # CirclecI Docker customizations
    sed -i 's|^limit|#limit|g' /etc/init/docker.conf
    usermod -a -G docker ${CIRCLECI_USER}

    # Docker will be running inside a container (lxc or privileged docker)
    # Internally, docker checks container env-var to condition some apparmor profile activities that don't work within lxc
    echo 'env container=yes' >> /etc/init/docker.conf

    # Don't start Docker by default
    echo manual >> /etc/init/docker.conf

    # --userland-proxy=false: Docker's userland proxy is broken. Don't use it.
    echo 'DOCKER_OPTS="-s btrfs -e lxc -D --userland-proxy=false"' > /etc/default/docker

    # Replace with CircleCI's patched docker
    sudo curl -L -o /usr/bin/docker 'https://s3-external-1.amazonaws.com/circle-downloads/docker-1.9.1-circleci'
    sudo chmod 0755 /usr/bin/docker
}
