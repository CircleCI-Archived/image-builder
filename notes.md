
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt-get update
sudo apt-get install lxc docker-engine git make
sudo usermod -aG docker ubuntu
# restart server

git clone https://github.com/circleci/image-builder.git
git clone https://github.com/kimh/docker-cache-shim.git
cd docker-cache-shim
sudo ./install.sh
cd ../image-builder

Ensure you remove all images if you stop/cancel a build to ensure they are all current:

    docker images
    docker rmi -f <imageid>

we also use https://github.com/spotify/docker-gc to do a full cleanup
