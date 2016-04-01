#!/bin/bash

col() {
    c=$1
    cut -d ' ' -f ${c}
}

quotify() {
    cat - | sed -e s/^/\"/ | sed s/$/\"/
}

commatize() {
    cat - | sed -e s/$/\,/
}

flatten() {
    cat - | tr "\n" " "
}

trailing_last_comma() {
    cat - | sed -e '$ s/,\s*$//g'
}

all_ruby() {
    ls /opt/circleci/ruby/ | grep -v default | quotify | commatize | flatten | trailing_last_comma
}

all_python() {
    ls /opt/circleci/python/ | quotify | commatize | flatten | trailing_last_comma
}

all_nodejs() {
    ls /opt/circleci/nodejs/ | quotify | commatize | flatten | trailing_last_comma
}

all_php() {
    ls /opt/circleci/php/ | quotify | commatize | flatten | trailing_last_comma
}

cat<<EOF
{
  "summary": {
    "build-image": "$(cat /opt/circleci/image_version)",
    "google-chrome": "$(google-chrome --version | col 3)",
    "chromedriver": "$(chromedriver --version | col 2)",
    "firefox": "$(firefox --version | col 3)",
    "mongod": "$(mongod --version | grep 'db version' | col 3 | sed 's/^v//')",
    "psql": "$(psql --version | grep psql | col 3)",
    "mysqld": "$(mysql --version | col 6 | sed 's/,//')",
    "ruby:": {
      "default": "$(ruby --version | cut -d " " -f 2)",
      "all": [
        $(all_ruby)
      ],
      "gem": "$(gem --version)",
      "rvm": "$(rvm --version | grep rvm.io | col 2,3)",
      "bundler": "$(bundle --version | col 3)"
    },
    "python:": {
      "default": "$(python --version 2>&1 | col 2)",
      "all": [
        $(all_python)
      ],
      "pip": "$(pip --version | col 2)",
      "virtualenv": "$(virtualenv --version)"
    },
    "nodejs:": {
      "default": "$(node --version | head -1 | sed 's/^v//')",
      "all": [
        $(all_nodejs)
      ],
      "npm": "$(npm --version)",
      "nvm": "$(. /opt/circleci/.nvm/nvm.sh && nvm --version)"
    },
    "php": {
      "default": "$(php --version | head -1 | col 2)",
      "all": [
        $(all_nodejs)
      ]
    },
    "redis": "$(redis-server --version | col 3 | sed 's/^v=//')",
    "memcached": "$(memcached -h | head -1 | col 2)",
    "git": "$(git --version | col 3)",
    "cc": "$(cc --version | head -1 | col 4)",
    "c++": "$(c++ --version | head -1 | col 4)",
    "make": "$(make --version | head -1 | col 3)",
    "lein": "$(lein --version | col 2)",
    "java": "$(java -version 2>&1 | head -1 | col 3 | sed 's/"//g')",
    "maven": "$(mvn --version | head -1 | col 3)",
    "ant": "$(ant -version | col 4)",
    "apache2": "$(apache2 -version | grep 'Server version' | col 3 | cut -d '/' -f 2)",
    "beanstalkd": "$(beanstalkd -v | col 2)",
    "cassandra": "$(cassandra -v | tail -1)",
    "elasticsearch": "$(/usr/share/elasticsearch/bin/elasticsearch -v | col 2 | sed 's/,//g')",
    "geos": "$(geos-config --version)",
    "go": "$(go version | col 3 | sed 's/^go//')",
    "gradle": "$(gradle --version | grep Gradle | col 2)",
    "phantomjs": "$(phantomjs --version)",
    "docker": "$(docker --version | col 3)",
    "docker-compose": "$(docker-compose --version | col 3 | sed 's/,//g')",
    "heroku-toolbelt": "$(heroku version | grep toolbelt | col 1 | sed 's|.*/||')",
    "gcloud": "$(pyenv local 2.7.11 && gcloud version  | grep "Google Cloud SDK" | col 4)",
    "aws-cli": "$(aws --version 2>&1  | col 1 | sed 's|.*/||')"
  },
  "all": {
    $(dpkg -l | grep -e '^ii' | awk '{printf "\"%s\": \"%s\",\n", $2,$3}' | trailing_last_comma)
  }
}
EOF
