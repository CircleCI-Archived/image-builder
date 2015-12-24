function install_lxc_docker() {
    echo '>>>> Installing Docker'

    apt-get install -y lxc btrfs-tools

    curl -L -s https://get.docker.io/ | sh
    service docker stop || true

    usermod -a -G docker ${CIRCLECI_USER}

    # Devicemapper files are huge if got created - we don't use device mapper anyway
    rm -rf /var/lib/docker/devicemapper/devicemapper/data
    rm -rf /var/lib/docker/devicemapper/devicemapper/metadata

    sed -i 's|^limit|#limit|g' /etc/init/docker.conf
    echo manual >> /etc/init/docker.conf

    echo 'DOCKER_OPTS="-s btrfs -e lxc -D --userland-proxy=false"' > /etc/default/docker

    # Replace with CircleCI's patched docker
    sudo curl -L -o /usr/bin/docker 'https://s3-external-1.amazonaws.com/circle-downloads/docker-1.9.1-circleci'
    sudo chmod 0755 /usr/bin/docker
}
