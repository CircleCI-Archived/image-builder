#!/bin/bash

set -ex

echo '>>> Installing Go'


GO_VERSION=1.4

URL=http://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz

curl -sSL -o /tmp/go.tar.gz $URL
tar -xz -f /tmp/go.tar.gz -C /usr/local

# Workaround an issue with go install wanting to write to goroot
# in old versions
chown ${CIRCLECI_USER}:${CIRCLECI_USER} /usr/local/go

echo '>> Setting up gopath'

$USER_STEP mkdir -p ${CIRCLECI_HOME}/.go_workspace

echo 'export PATH=~/.go_workspace/bin:/usr/local/go/bin:$PATH' >> ${CIRCLECI_HOME}/.circlerc
echo 'export GOPATH=~/.go_workspace:$GOPATH' >> ${CIRCLECI_HOME}/.circlerc


