#!/bin/bash

function install_circleci_specific() {
    # CircleCI specific commands

    echo '>>> Installing CircleCI Specific things'

    echo 'source ~/.bashrc &>/dev/null' >> ${CIRCLECI_HOME}/.bash_profile
    echo 'source ~/.circlerc &>/dev/null' > ${CIRCLECI_HOME}/.bashrc

    chown $CIRCLECI_USER:$CIRCLECI_USER ${CIRCLECI_HOME}/.bash_profile
    chown $CIRCLECI_USER:$CIRCLECI_USER ${CIRCLECI_HOME}/.bashrc

    (cat <<'EOF'
export GIT_ASKPASS=echo
export SSH_ASKPASS=false
export PATH=~/bin:$PATH
export CIRCLECI_PKG_DIR="/opt/circleci"
EOF
) | as_user tee ${CIRCLECI_HOME}/.circlerc

    as_user mkdir -p ${CIRCLECI_HOME}/bin

    # Configure SSH so it can talk to servers OK

    cat <<'EOF' > /etc/ssh/ssh_config
Host *
  StrictHostKeyChecking no
  HashKnownHosts no
  SendEnv LANG LC_*
EOF

    # Some optimizations for the sshd daemon
    sed -i 's/PasswordAuthentication yes/PasswordAuthoentication no/g' /etc/ssh/sshd_config

    cat <<'EOF' >> /etc/ssh/sshd_config
UseDns no
MaxStartups 1000
MaxSessions 1000
PermitTunnel yes
AddressFamily inet
EOF

    # Setup xvfb

    apt-get install xvfb xfwm4

    sed -i 's/^exit 0/nohup Xvfb :99 -screen 0 1280x1024x24 \&\nsleep 2\nDISPLAY=:99.0 xfwm4 --daemon\nexit 0/g' /etc/rc.local

    echo 'export DISPLAY=:99' >> $CIRCLECI_HOME/.circlerc
}
