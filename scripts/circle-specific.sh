#!/bin/bash

# CircleCI specific commands

echo '>>> Installing CircleCI Specific things'

echo 'source ~/.circlerc &>/dev/null' > ${CIRCLECI_HOME}/.bashrc
echo 'source ~/.circlerc &>/dev/null' > ${CIRCLECI_HOME}/.bash_login

(cat <<'EOF'
export GIT_ASKPASS=echo
export SSH_ASKPASS=false
export PATH=~/bin:$PATH
EOF
) | $USER_STEP tee ${CIRCLECI_HOME}/.circlerc

$USER_STEP mkdir -p ${CIRCLECI_HOME}/bin


# Setup xvfb

apt-get install -qq xvfb xfwm4

sed -i 's/^exit 0/nohup Xvfb :99 -screen 0 1280x1024x24 &\nsleep 2\nDISPLAY=:99.0 xfwm4 --daemon\nexit 0/g' /etc/rc.local

echo 'export DISPLAY=:99' >> $CIRCLECI_HOME/.circlerc

