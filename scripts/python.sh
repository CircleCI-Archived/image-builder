#!/bin/bash

set -ex

echo '>>> Installing Python'

function install_pyenv() {
	echo 'Installing pyenv'
	(cat <<'EOF'
set -e
cd ~
[[ -e .pyenv ]] || git clone https://github.com/yyuu/pyenv.git .pyenv
echo 'export PATH=~/.pyenv/bin:$PATH' >> ~/.circlerc
echo 'eval "$(pyenv init -)"' >> ~/.circlerc
EOF
	) | $USER_STEP bash
}

function install_python() {
	PYTHON_VERSION=$1
	(cat <<'EOF'
set -e
source ~/.circlerc
pyenv install $PYTHON_VERSION
pyenv global $PYTHON_VERSION
pyenv rehash

pip install -U virtualenv
pip install -U nose
pip install -U pep8

EOF
	) | $USER_STEP PYTHON_VERSION=$PYTHON_VERSION bash
}

function set_python_default() {
	PYTHON_VERSION=$1
	(cat <<'EOF'
set -ex
source ~/.circlerc
pyenv global $PYTHON_VERSION
pyenv rehash
EOF
	) | $USER_STEP PYTHON_VERSION=$PYTHON_VERSION bash
}

install_pyenv

install_python "2.7.9"
install_python "3.4.2"

set_python_default "2.7.9"
