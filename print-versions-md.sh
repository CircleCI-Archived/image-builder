#/bin/bash

function language-versions() {
  ls -l /opt/circleci/$1 |grep -v total | awk '{print $9}'
}

function dpkg-version() {
  dpkg -l | grep $1 | awk '{print $3}'
}

function pv() {
  echo '```'
  $@
  echo '```'
  echo ""
}

function ruby-default() {
  ruby -v | awk '{print $2}' | sed 's/p.*//'
}

function python-default() {
  python --version 2>&1 | awk '{print $2}'
}

function php-default() {
  php -r 'print phpversion(); print(PHP_EOL);'
}

function nodejs-default() {
  node --version | sed 's/v//'
}

function java-version() {
  java -version
}

function go-version() {
  go version | awk '{print $3}' | sed 's/go//'
}

function mysql-version() {
  mysql --version | awk '{print $5}' | sed 's/,//'
}

function postgresql-version() {
  psql --version | awk '{print $3}'
}

function mongodb-version() {
  dpkg-version mongodb-org-server
}

function elasticsearch-version() {
  dpkg-version elasticsearch
}

function neo4j-version() {
  dpkg-version neo4j
}

function redis-version() {
  dpkg-version redis-server
}

function memcached-version() {
  dpkg-version memcached | grep -v libmemcache
}

function rabbitmq-version() {
  dpkg-version rabbitmq-server
}

function firefox-version() {
  firefox --version | awk '{print $3}'
}

function chrome-version() {
  google-chrome --version | awk '{print $3}'
}

function phantomjs-version() {
  phantomjs --version
}

function qt-version() {
  qmake -query QT_VERSION
}

function docker-version() {
  docker --version | awk '{print $3}' | sed 's/-circleci\,//'
}

function docker-compose-version() {
  docker-compose --version | awk '{print $3}' | sed 's/,//'
}

echo '## Programming Languages'
echo "Python"
echo "Default: $(python-default)"
echo ""
echo "Available versions"
pv language-versions python

echo "PHP"
echo "Default: $(php-default)"
echo ""
echo "Available versions"
pv language-versions php

echo "Ruby"
echo "Default: $(ruby-default)"
echo ""
echo "Available versions"
pv language-versions ruby

echo "Nodejs"
echo "Default: $(nodejs-default)"
echo ""
echo "Available versions"
pv language-versions nodejs

echo "Java"
pv java-version

echo "Go"
pv go-version

echo '## Databases'
echo "MySQL"
pv mysql-version

echo "PostgreSQL"
pv postgresql-version

echo "MongoDB"
pv mongodb-version

echo "Redis"
pv redis-version

echo "Elasticsearch"
pv elasticsearch-version

echo '## Docker'
echo "Docker"
pv docker-version

echo "Docker Compose"
pv docker-compose-version

echo '## Browsers'
echo "Firefox"
pv firefox-version

echo "Chrome"
pv chrome-version

echo "PhantomJS"
pv phantomjs-version

echo '## Misc'
echo "Qt"
pv qt-version

echo "Memcached"
pv memcached-version

echo "RabbitMQ"
pv rabbitmq-version

