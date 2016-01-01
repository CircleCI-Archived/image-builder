#!/bin/bash

function install_base_requirements() {
    echo "Setting Timezone & Locale to $3 & C.UTF-8"

    ln -sf /usr/share/zoneinfo/$3 /etc/localtime
    locale-gen C.UTF-8 || true
    update-locale LANG=en_US.UTF-8
    export LANG=C.UTF-8

    echo "export LANG=C.UTF-8" > ${CIRCLECI_HOME}/.bashrc

    echo ">>> Make Apt non interactive"

    echo 'force-confnew' >> /etc/dpkg/dpkg.cfg

    (cat <<'EOF'
// the /etc/apt/apt.conf file for the slave AMI

// Auto "-y" for apt-get
APT {
  Get {
    Assume-Yes "true";
    force-yes "true";
  };
};

// Disable HTTP pipelining, S3 doesn't support it properly.
Acquire {
  http {
    Pipeline-Depth 0;
  }
}

// Don't ask to update
DPkg {
  Options {
    "--force-confnew";
  };
};
EOF
) > /etc/apt/apt.conf

    echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep
    export DEBIAN_FRONTEND=noninteractive

    apt-get update -y

    # Install base packages
    apt-get install \
        build-essential cmake git-core mercurial zip gdb \
        htop emacs vim nano lsof vnc4server tmux lzop \
        build-essential htop emacs vim nano lsof tmux zip vnc4server \
        curl unzip git-core ack-grep software-properties-common build-essential \
        parallel libav-tools make autoconf liblapack-dev gfortran
}
