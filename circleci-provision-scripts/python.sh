#!/bin/bash

function install_pyenv() {
    echo '>>> Installing Python'

    # FROM https://github.com/yyuu/pyenv/wiki/Common-build-problems
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
	    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev

    echo 'Installing pyenv'
    (cat <<'EOF'
set -e
cd ~
[[ -e .pyenv ]] || git clone https://github.com/yyuu/pyenv.git .pyenv
echo 'export PATH=~/.pyenv/bin:$PATH' >> ~/.circlerc
echo 'eval "$(pyenv init -)"' >> ~/.circlerc
EOF
    ) | as_user bash
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
    ) | as_user PYTHON_VERSION=$PYTHON_VERSION bash
}

function set_python_default() {
    PYTHON_VERSION=$1
    (cat <<'EOF'
set -e
source ~/.circlerc
pyenv global $PYTHON_VERSION
pyenv rehash
EOF
    ) | as_user PYTHON_VERSION=$PYTHON_VERSION bash
}

function python() {
    VERSION=$1
    [[ -e $CIRCLECI_HOME/.pyenv ]] || install_pyenv
    install_python $1
}
