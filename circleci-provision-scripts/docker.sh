#!/bin/bash

function docker() {
    echo '>>>> Installing Docker'

    # Install Docker
    curl -L -s https://get.docker.io/ | sh

    # Devicemapper files are huge if got created - we don't use device mapper anyway
    rm -rf /var/lib/docker/devicemapper/devicemapper/data
    rm -rf /var/lib/docker/devicemapper/devicemapper/metadata

    # CirclecI Docker customizations
    sed -i 's|^limit|#limit|g' /etc/init/docker.conf
    usermod -a -G docker ${CIRCLECI_USER}

    echo manual >> /etc/init/docker.conf
    echo 'env container=yes' >> /etc/init/docker.conf
}

function docker_compose() {
    echo '>>>> Installing Docker compose'

    curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
}
