#!/usr/bin/env bats

load ../test_helper_python

@test "python: all versions are installed" {
    python_test_all_installed
}

# Run this test first before version is changed by subsequent tests
@test "python: default is 2.7.11" {
    run python_test_version 2.7.11

    [ "$status" -eq 0 ]
}

@test "python: 2.7.10 works" {
    test_python 2.7.10
}

@test "python: 2.7.11 works" {
    test_python 2.7.11
}

@test "python: 2.7.12 works" {
    test_python 2.7.12
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

@test "python: 3.5.1 works" {
    test_python 3.5.1
}

@test "python: 3.5.2 works" {
    test_python 3.5.2
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

# We had a regression that changing python version with 'pyenv global' is broken
# because we accidentally run 'pyenv local' during image build.
# This breaks the version switching because CircleCI use 'pyenv global' but global
# doesn't override version set with local.
@test "python: switching version with 'pyenv global' works" {
    run python_test_pyenv_global

    [ "$status" -eq 0 ]
}
