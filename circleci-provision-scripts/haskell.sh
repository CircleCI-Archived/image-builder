#!/bin/bash

function install_ghc() {
    local version=$1
    local install_path="/opt/ghc/$version"

    local ppa="ppa:hvr/ghc"
    local ppa_file="/etc/apt/sources.list.d/hvr-ghc-trusty.list"

    local happy_version="1.19.5"
    local alex_version="3.1.7"
    local cabal_version="1.24"

    if ! [ -e $ppa_file ]; then
	apt-add-repository $ppa
	apt-get update
    fi

    install_ghc_tool happy $happy_version
    install_ghc_tool alex $alex_version
    install_cabal $cabal_version

    apt-get install ghc-$version

    echo "export PATH=$install_path/bin"':$PATH' >> ${CIRCLECI_HOME}/.circlerc
}

function install_stack() {
    curl -sSL https://get.haskellstack.org/ | sh
    echo "export PATH=~/.local/bin"':$PATH' >> ${CIRCLECI_HOME}/.circlerc
}

function install_ghc_tool() {
    local name=$1
    local version=$2
    local install_path="/opt/$name/$version"

    if ! [ -e $install_path ]; then
	apt-get install $name-$version
	echo "export PATH=$install_path/bin"':$PATH' >> ${CIRCLECI_HOME}/.circlerc
    fi
}

function install_cabal() {
    local version=$1
    local install_path="/opt/cabal/$version"
    local cabal_config="${CIRCLECI_HOME}/.cabal/config"

    if ! [ -e $install_path ]; then
	apt-get install cabal-install-$version
	echo "export PATH=$install_path/bin"':$PATH' >> ${CIRCLECI_HOME}/.circlerc

	$install_path/bin/cabal update

	(cat <<'EOF'
$install_path/bin/cabal update
EOF
	) | as_user install_path=$install_path bash

	sed -i 's/jobs: $ncpus/-- jobs:$ncpus/' $cabal_config
	echo 'jobs: 2' >> $cabal_config
    fi
}
