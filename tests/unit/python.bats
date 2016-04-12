#!/usr/bin/env bats

test_python () {
    local version=$1

    pyenv local $version

    if echo $version | grep pypy; then
	run pypy_test_version $version
	[ "$status" -eq 0 ]
    else
	run python_test_version $version
	[ "$status" -eq 0 ]
    fi

    run python_test_pip
    [ "$status" -eq 0 ]
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

@test "python: all versions are installed" {
    local expected=$(grep "circleci-install python" /opt/circleci/Dockerfile | awk '{print $4}' | sort)
    local actual=$(ls /opt/circleci/python/ | sort)

    run test "$expected" = "$actual"

    [ "$status" -eq 0 ]
}

@test "python: 2.7.10 works" {
    test_python 2.7.10
}

@test "python: 2.7.11 works" {
    test_python 2.7.11
}

@test "python: 3.1.4 works" {
    test_python 3.1.4
}

@test "python: 3.1.5 works" {
    test_python 3.1.5
}

@test "python: 3.2.5 works" {
    test_python 3.2.5
}

@test "python: 3.2.6 works" {
    test_python 3.2.6
}

@test "python: 3.3.5 works" {
    test_python 3.3.5
}

@test "python: 3.3.6 works" {
    test_python 3.3.6
}

@test "python: 3.4.3 works" {
    test_python 3.4.3
}

@test "python: 3.4.4 works" {
    test_python 3.4.4
}

@test "python: 3.5.0 works" {
    test_python 3.5.0
}

@test "python: 3.5.1 works" {
    test_python 3.5.1
}

@test "python: pypy-1.9 works" {
    test_python pypy-1.9
}

@test "python: pypy-2.6.1 works" {
    test_python pypy-2.6.1
}

@test "python: pypy-4.0.1 works" {
    test_python pypy-4.0.1
}
