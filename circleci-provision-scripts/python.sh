#!/bin/bash

function install_pyenv() {
    echo '>>> Installing Python'

    # FROM https://github.com/yyuu/pyenv/wiki/Common-build-problems
    apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
	    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev

    # Installing system pip because sometimes our app uses `pyenv global system`. e.g. CodeDeploy
    apt-get install python-pip

    echo 'Installing pyenv'
    (cat <<'EOF'
git clone https://github.com/yyuu/pyenv.git $CIRCLECI_PKG_DIR/.pyenv
echo "export PYENV_ROOT=$CIRCLECI_PKG_DIR/.pyenv" >> ~/.circlerc
echo 'export PATH=$PYENV_ROOT/bin:$PATH' >> ~/.circlerc
echo 'eval "$(pyenv init -)"' >> ~/.circlerc
EOF
    ) | as_user CIRCLECI_PKG_DIR=$CIRCLECI_PKG_DIR bash

    if [ -n "$USE_PRECOMPILE" ]; then
    # Preparing for hooking up packaged Python into pyenv directories
        (cat <<'EOF'
mkdir $CIRCLECI_PKG_DIR/python
ln -s $CIRCLECI_PKG_DIR/python $CIRCLECI_PKG_DIR/.pyenv/versions
EOF
        ) | as_user CIRCLECI_PKG_DIR=$CIRCLECI_PKG_DIR bash
    fi
}

function install_python_version_pyenv() {
    PYTHON_VERSION=$1
    (cat <<'EOF'
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

function install_python_version_precompile() {
    local PYTHON_VERSION=$1

    maybe_run_apt_update
    apt-get install circleci-python-$PYTHON_VERSION
    chown -R $CIRCLECI_USER:$CIRCLECI_USER $CIRCLECI_PKG_DIR/python/$PYTHON_VERSION
}

function set_python_default() {
    local PYTHON_VERSION=$1
    (cat <<'EOF'
source ~/.circlerc
pyenv global $PYTHON_VERSION
pyenv rehash
EOF
    ) | as_user PYTHON_VERSION=$PYTHON_VERSION bash
}

function install_python_version() {
    local VERSION=$1

    if [ -n "$USE_PRECOMPILE" ]; then
        install_python_version_precompile $VERSION
    else
        install_python_version_pyenv $VERSION
    fi
}

function install_python() {
    local VERSION=$1
    [[ -e $CIRCLECI_PKG_DIR/.pyenv ]] || install_pyenv
    install_python_version $1
}
