test_nodejs () {
    local version=$1

    # Loading nvm.sh makes bats very slow but getting
    # 'nvm command not found' error otherwise, so no choise :(
    . /opt/circleci/.nvm/nvm.sh

    nvm use $version

    run nodejs_test_version $version
    [[ "$status" -eq 0 ]]

    run nodejs_test_npm
    [[ "$status" -eq 0 ]]
}

nodejs_test_version () {
    local version=$1

    node -e "console.log(process.version);" | grep "$version"
}

nodejs_test_npm () {
    npm --version
}

test_yarn_version () {
    local expected=$1
    local actual=$(yarn --version)

    run test "$expected" = "$actual"

    [ "$status" -eq 0 ]
}

nodejs_test_all_installed (){
    local expected=$(grep "circleci-install nodejs" /opt/circleci/Dockerfile | awk '{print "v" $4}' | sort)
    local actual=$(ls /opt/circleci/nodejs/ | sort)

    run test "$expected" = "$actual"

    [ "$status" -eq 0 ]
}
