test_python () {
    local version=$1

    pyenv global $version

    if echo $version | grep pypy; then
        run pypy_test_version $version
        [ "$status" -eq 0 ]
    else
        run python_test_version $version
        [ "$status" -eq 0 ]
    fi

    run python_test_pip
    [ "$status" -eq 0 ]

    # kludge: I couldn't install curses only in pypy-1.9 for some reasons
    if ! [ "$version" = "pypy-1.9" ] ; then
        run python_test_curses
        [ "$status" -eq 0 ]
    fi
}

python_test_version () {
    local version=$1

    python --version 2>&1 | grep "$version"
}

pypy_test_version () {
    local version=$1
    local split=( `echo ${version} | tr -s '-' ' '` )
    local pypy=${split[0]}
    local ver=${split[1]}

    echo $split >> /tmp/debug

    python --version 2>&1 | grep -i $pypy | grep $ver
}

python_test_pip () {
    pip --version
}

python_test_pyenv_global () {
    local current_version=$(pyenv global)
    local new_version=3.5.3

    pyenv global $new_version
    python_test_version $new_version
}

python_test_all_installed () {
    local expected=$(grep "circleci-install python" /opt/circleci/Dockerfile | awk '{print $4}' | sort)
    local actual=$(ls /opt/circleci/python/ | sort)

    run test "$expected" = "$actual"

    [ "$status" -eq 0 ]
}

python_test_curses() {
    python -c 'import curses'
}
