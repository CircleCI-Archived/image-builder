#!/usr/bin/env bats

# GOPATH is /home/ubuntu/.go_workspace on CircleCI
go_workspace () {
   echo "/home/ubuntu/.go_workspace"
}

go_test_repo () {
   echo $BATS_TEST_DIRNAME/data/go-example-repo
}

go_test_version () {
    local version=$1

    go version | grep "$version"
}

# I'm not a huge fan of doing anything that requires network connection
# inside unit tests, but Go's convetion/expectation is bit weird, so
# it's worth actually installing dependencies.
go_test_get () {
    local test_repo=$BATS_TEST_DIRNAME/data/go-example-repo

    mkdir -p $(go_workspace)

    go get -t -d -v ./...
    ls $(go_workspace)/src/github.com/golang/example/hello
}

go_test_build () {
    cd $(go_test_repo)/hello
    go build -v
}

@test "go: 1.6.2 works" {
    run go_test_version 1.6.2

    [ "$status" -eq 0 ]
}

@test "go: go get works" {
    run go_test_get

    [ "$status" -eq 0 ]
}

@test "go: go build works" {
    run go_test_build

    [ "$status" -eq 0 ]
}
