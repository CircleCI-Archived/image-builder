#!/bin/bash

function install_git-lfs() {
    local version=$1

    add-apt-repository ppa:git-core/ppa -y
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash

    apt-get install git-lfs=$version

    # Disable git-lfs pulling lfs files automatically
    echo 'GIT_LFS_SKIP_SMUDGE=1' >> /etc/environment
}
