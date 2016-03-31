#!/usr/bin/env bats

setup () {
    source /opt/circleci/.rvm/scripts/rvm
}

machine () {
    rvm use 2.1.3
}

dependencies () {
    export RAILS_ENV=test
    export RACK_ENV=test

    for g in growl_notify autotest-fsevent rb-appscript rb-fsevent; do
	sed -i.bak "/gem ['\"]$g['\"].*, *$/ N; s/\n *//g; /gem ['\"]$g['\"]/ d" Gemfile
    done

    bundle check --path=vendor/bundle || bundle install --path=vendor/bundle --jobs=4 --retry=3
}

database () {
    mkdir -p config
    echo 'test:
  adapter: postgresql
  encoding: unicode
  database: circle_ruby_test
  pool: 5
  username: ubuntu
  host: localhost
' > config/database.yml
}

test () {
    bundle exec rspec --color --require spec_helper spec --format progress &>> bats.log
}

@test "rails4-starterkit: test passes" {
    cd tests/integration/rails4-starterkit

    machine
    dependencies
    database
    run test

    echo "---------------- output -----------------"
    echo $output
    echo "---------------- output -----------------"

    [ "$status" -eq 0 ]
}
