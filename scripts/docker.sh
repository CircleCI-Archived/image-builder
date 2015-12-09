#!/bin/bash

set -ex

echo '>>>> Installing Docker'

DEBIAN_FRONTEND=noninteractive apt-get install -qq lxc btrfs-tools libcgmanager0
service lxc stop
sed -i 's|10\.0\.3|10.0.4|g' /etc/default/lxc

# Install Docker
curl -L -s https://get.docker.com | sh
service docker stop

# Devicemapper files are huge if got created - we don't use device mapper anyway
rm -rf /var/lib/docker/devicemapper/devicemapper/data
rm -rf /var/lib/docker/devicemapper/devicemapper/metadata

# Prepare our Docker fork
mv /usr/bin/docker /usr/bin/docker-original
curl -L -o /usr/bin/docker https://s3.amazonaws.com/circle-downloads/docker-1.7.1-circleci
chmod 0755 /usr/bin/docker

# CirclecI Docker customizations
echo 'DOCKER_OPTS="-s btrfs -e lxc"' >> /etc/default/docker
sed -i 's|^limit|#limit|g' /etc/init/docker.conf
usermod -a -G docker ${CIRCLECI_USER}

echo manual >> /etc/init/docker.conf
