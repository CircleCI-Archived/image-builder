test_ruby () {
    local version=$1

    # Don't use rvm!!
    # Using 'rvm use ...' requires you to source /opt/circleci/.rvm/scripts/rvm
    # and this makes bats extremely slow for some reasons. (probably same as https://github.com/sstephenson/bats/issues/107)
    # So just load only env vars
    . /opt/circleci/.rvm/environments/ruby-$version

    run ruby_test_version $version
    [ "$status" -eq 0 ]

    run ruby_test_gem
    [ "$status" -eq 0 ]

    run ruby_test_bundler
    [ "$status" -eq 0 ]

    run ruby_test_gem_version_fixed 2.6
    [ "$status" -eq 0 ]

    run ruby_test_bundler_version_fixed 1.14
    [ "$status" -eq 0 ]
}

ruby_test_version () {
    local version=$1

    ruby -e 'puts RUBY_VERSION' | grep "$version"
}

ruby_test_gem () {
    gem --version
}

ruby_test_gem_version_fixed () {
    local version=$1
    gem --version | grep $version
}

ruby_test_bundler () {
    bundler --version
}

ruby_test_bundler_version_fixed () {
    local version=$1
    bundler --version | grep $version
}

ruby_test_all_installed () {
    local expected=$(grep "circleci-install ruby" /opt/circleci/Dockerfile | awk '{print "ruby-" $4}' | sort)
    local actual=$(ls /opt/circleci/ruby/ | grep -v default | sort)

    run test "$expected" = "$actual"

    [ "$status" -eq 0 ]
}
