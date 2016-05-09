#!/usr/bin/env bats

test_enabled_default () {
    local service=$1

    sudo service $service status | grep "start/running"
}

wait_service () {
    local port=$1
    local sleep_time=3

    for i in 1 2 3 4 5; do
      if curl --silent localhost:$port > /dev/null; then
        return 0
      else
        sleep $sleep_time
      fi
    done

    exit 1
}

@test "mysql is enabled by default" {
    run test_enabled_default "mysql"

    [ "$status" -eq 0 ]
}

@test "mysql works" {
    run mysql -e "STATUS;"

    [ "$status" -eq 0 ]
}

@test "postgresql is enabled by default" {
    run sudo service postgresql status

    [ "$status" -eq 0 ]
}

@test "postgresql works" {
    run psql -c "SELECT version();"

    [ "$status" -eq 0 ]
}

@test "mongodb is enabled by default" {
    run test_enabled_default "mongod"

    [ "$status" -eq 0 ]
}

@test "mongodb works" {
    run bash -c "echo 'show dbs;' | mongo"

    [ "$status" -eq 0 ]
}

@test "redis works" {
    sudo service redis-server start

    run bash -c "echo 'SET hoge bar' | redis-cli"

    [ "$status" -eq 0 ]
}

@test "memcached works" {
    sudo service memcached start

    run bash -c "echo stats | nc localhost 11211"

    [ "$status" -eq 0 ]
}

@test "neo4j works" {
    sudo service neo4j-service start

    run neo4j-shell -c "mknode --cd"

    [ "$status" -eq 0 ]
}

@test "rabbitmq works" {
    sudo service rabbitmq-server start

    run sudo rabbitmqctl cluster_status

    [ "$status" -eq 0 ]
}

@test "elasticsearch works" {
    local port=9200

    sudo service elasticsearch start

    wait_service $port

    run curl http://localhost:$port

    [ "$status" -eq 0 ]
}

@test "beanstalkd works" {
    sudo service beanstalkd start

    run bash -c "echo -e 'stats\r\n' | nc localhost 11300"

    [ "$status" -eq 0 ]
}

# We just run `docker version` without running actual daemon
# because docker can't run inside docker (DIND)
@test "circleci docker is installed" {
    run bash -c 'docker version | grep Version | grep circleci'

    [ "$status" -eq 0 ]
}
