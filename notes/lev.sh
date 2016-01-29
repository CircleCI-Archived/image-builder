#!/bin/bash
# lev gave me this; it's the provision.sh from the last container image build for zeneifts
set -ex
export CIRCLECI_USER=$1
[ -n "$CIRCLECI_USER" ] || export CIRCLECI_USER=${SUDO_USER}
if [ -z "$CIRCLECI_USER" ]
then
    echo CIRCLECI_USER env-var is not defined
    exit 1
fi
export CIRCLECI_HOME=/home/${CIRCLECI_USER}
export USER_STEP="sudo -H -u ${CIRCLECI_USER}"
echo Using user ${CIRCLECI_USER}
#!/bin/bash
set -ex
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
apt-get update -q
# Install base packages
apt-get install -qq \
    build-essential cmake git-core mercurial zip gdb \
    htop emacs vim nano lsof vnc4server tmux lzop \
    build-essential htop emacs vim nano lsof tmux zip vnc4server \
    curl unzip git-core ack-grep software-properties-common build-essential \
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
apt-get install -qq xvfb xfwm4
sed -i 's/^exit 0/nohup Xvfb :99 -screen 0 1280x1024x24 &\nsleep 2\nDISPLAY=:99.0 xfwm4 --daemon\nexit 0/g' /etc/rc.local
echo 'export DISPLAY=:99' >> $CIRCLECI_HOME/.circlerc
#!/bin/bash
set -ex
echo '>>>> Installing Docker'
DEBIAN_FRONTEND=noninteractive apt-get install -qq lxc btrfs-tools libcgmanager0
service lxc stop
sed -i 's|10\.0\.3|10.0.4|g' /etc/default/lxc
# Install Docker
curl -L -s https://get.docker.io | sh
service docker stop
# Devicemapper files are huge if got created - we don't use device mapper anyway
rm -rf /var/lib/docker/devicemapper/devicemapper/data
rm -rf /var/lib/docker/devicemapper/devicemapper/metadata
# Prepare our Docker fork
mv /usr/bin/docker /usr/bin/docker-original
curl -L -o /usr/bin/docker https://s3.amazonaws.com/circle-downloads/docker-1.9.0-circleci
chmod 0755 /usr/bin/docker
# CirclecI Docker customizations
echo 'DOCKER_OPTS="-s btrfs -e lxc -D --userland-proxy=false"' >> /etc/default/docker
sed -i 's|^limit|#limit|g' /etc/init/docker.conf
usermod -a -G docker ${CIRCLECI_USER}
echo manual >> /etc/init/docker.conf
#!/bin/bash
set -ex
echo '>>> Installing Java 8'
# Install java
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
apt-get install -qq oracle-java8-installer
# Install Maven
MAVEN_VERSION=3.2.5
curl -sSL -o /tmp/maven.tar.gz http://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
tar -xz -C /usr/local -f /tmp/maven.tar.gz
ln -sf /usr/local/apache-maven-${MAVEN_VERSION} /usr/local/apache-maven
$USER_STEP mkdir -p ${CIRCLECI_HOME}/.m2
echo 'export M2_HOME=/usr/local/apache-maven' | $USER_STEP tee -a ${CIRCLECI_HOME}/.circlerc
echo 'export MAVEN_OPTS=-Xmx2048m' |  $USER_STEP tee -a ${CIRCLECI_HOME}/.circlerc
echo 'export PATH=$M2_HOME/bin:$PATH' | $USER_STEP tee -a ${CIRCLECI_HOME}/.circlerc
# Install Gradle
GRADLE_VERSION=1.10
URL=http://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
curl -sSL -o /tmp/gradle.zip $URL
unzip -d /usr/local /tmp/gradle.zip
echo 'export PATH=$PATH:/usr/local/gradle-1.10/bin' >> ${CIRCLECI_HOME}/.circlerc
rm -rf /tmp/gradle.zip
#!/bin/bash
# Package installation
bash -c 'echo "deb http://archive.ubuntu.com/ubuntu trusty universe" >> /etc/apt/sources.list'
apt-get update
apt-get install --no-install-recommends -y build-essential python \
  python-dev mysql-server mysql-client language-pack-en-base \
  libmysqlclient-dev python-virtualenv python-pip python-software-properties \
  software-properties-common chromium-chromedriver libxslt1-dev swig imagemagick \
  libmagickwand-dev libffi-dev liblua5.1 npm unzip libgif4 \
  git openjdk-7-jre-headless curl wget xvfb xfonts-cyrillic \
  xfonts-100dpi xfonts-75dpi xfonts-base xfonts-scalable libncurses5-dev \
  x11-xkb-utils poppler-utils libsqlite3-dev libfontconfig1-dev \
  libicu-dev libfreetype6 libssl-dev libpng-dev libjpeg-dev libx11-dev libxext-dev \
  sudo libncurses5-dev parallel ssh firefox
  # Configure git to use https:// instead of git://
 git config --global url."https://".insteadOf git://
 # Install prince
 wget http://www.princexml.com/download/prince_9.0-5_ubuntu14.04_amd64.deb
 dpkg -i prince_9.0-5_ubuntu14.04_amd64.deb
 ln -s /usr/bin/prince /usr/local/bin/prince
 # Download clojure compiler
 wget https://dl.google.com/closure-compiler/compiler-latest.zip
 unzip -n compiler-latest.zip
 # Add ubuntu user
 usermod -a -G sudo -s /bin/bash ubuntu
 bash -c 'echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'
 # Various symlinks
 ln -s /usr/lib/chromium-browser/chromedriver /usr/local/bin/chromedriver
 ln -s /usr/lib/x86_64-linux-gnu/liblua5.1.so /usr/lib/x86_64-linux-gnu/liblua51.so
 ln -s /usr/bin/nodejs /usr/bin/node
 # Install nvm
 npm install -g nvm
 # Install the right version of node
 node_version="0.12.7"
 for action in 'download' 'build' 'install'; do
   nvm "${action}" "${node_version}"
 done
 # Install bower, ember, ember-cli
 for package in 'bower' 'ember' 'ember-cli' 'phantomjs'; do
   npm install --verbose -g ${package}
 done
 # Install Redis
 add-apt-repository -y ppa:chris-lea/redis-server
 apt-get update
 apt-get install -y redis-server
 # Add 'ubuntu' user to MySQL
 mysqld &
 # Give server time to come up
 sleep 10
 # Add ubuntu user
 mysql -u root -e "create user 'ubuntu'@'localhost'"
 mysql -u root -e "grant all on *.* to 'ubuntu'@'localhost'"
 # Kill mysql daemon
 ps aux | grep mysql | grep -v grep | awk '{print $2}' | xargs kill -TERM
