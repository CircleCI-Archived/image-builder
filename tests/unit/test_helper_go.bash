# GOPATH is /home/ubuntu/.go_workspace on CircleCI
go_workspace () {
   echo "/home/ubuntu/.go_workspace"
}

go_test_repo () {
   echo $BATS_TEST_DIRNAME/../data/go-example-repo
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
    # Writing to /tmp because there is a permission issue with mounted volume.
    # /home/ubuntu/tests is a volume directory and `go build` trying to write to
    # the directory gets a permission issue
    go build -v -o /tmp/hello
}
