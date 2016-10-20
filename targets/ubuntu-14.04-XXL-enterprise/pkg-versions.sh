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
    ls $CIRCLECI_PKG_DIR/ruby/ | grep -v default | quotify | commatize | flatten | trailing_last_comma
}

all_python() {
    ls $CIRCLECI_PKG_DIR/python/ | quotify | commatize | flatten | trailing_last_comma
}

all_nodejs() {
    ls $CIRCLECI_PKG_DIR/nodejs/ | quotify | commatize | flatten | trailing_last_comma
}

all_php() {
    ls $CIRCLECI_PKG_DIR/php/ | quotify | commatize | flatten | trailing_last_comma
}

all_java() {
    # Exclude symbolic links
    ls -l /usr/lib/jvm | grep -v -- "->" | grep -v total | awk '{print $9}' | quotify | commatize | flatten | trailing_last_comma
}

all_ghc() {
     ls /opt/ghc/ | quotify | commatize | flatten | trailing_last_comma
}

all_sbt() {
    ls /home/ubuntu/.sbt/.lib/ | quotify | commatize | flatten | trailing_last_comma
}

cat<<EOF
{
  "summary": {
    "build-image": "$(cat $CIRCLECI_PKG_DIR/image_version)",
    "google-chrome": "$(google-chrome --version | col 3)",
    "chromedriver": "$(chromedriver --version | col 2)",
    "firefox": "$(firefox --version | col 3)",
    "mongod": "$(mongod --version | grep 'db version' | col 3 | sed 's/^v//')",
    "psql": "$(/usr/lib/postgresql/9.5/bin/postgres --version | col 3)",
    "mysqld": "$(mysql --version | col 6 | sed 's/,//')",
    "ruby": {
      "default": "$(ruby --version | cut -d " " -f 2)",
      "all": [
        $(all_ruby)
      ],
      "gem": "$(gem --version)",
      "rvm": "$(rvm --version | grep rvm.io | col 2,3)",
      "bundler": "$(bundle --version | col 3)"
    },
    "python": {
      "default": "$(python --version 2>&1 | col 2)",
      "all": [
        $(all_python)
      ],
      "pip": "$(pip --version | col 2)",
      "virtualenv": "$(virtualenv --version)"
    },
    "nodejs": {
      "default": "$(node --version | head -1 | sed 's/^v//')",
      "all": [
        $(all_nodejs)
      ],
      "npm": "$(npm --version)",
      "nvm": "$(. $CIRCLECI_PKG_DIR/.nvm/nvm.sh && nvm --version)"
    },
    "php": {
      "default": "$(php --version | head -1 | col 2)",
      "all": [
        $(all_php)
      ]
    },
    "java": {
      "default": "$(java -version 2>&1 | head -1 | col 3 | sed 's/"//g')",
      "all": [
        $(all_java)
      ]
    },
    "clojure": {
      "lein": "$(lein --version | col 2)"
    },
    "haskell": {
      "all": [
        $(all_ghc)
      ],
      "cabal": "$(cabal --version | head -1 | col 3)",
      "alex": "$(alex --version | col 3 | trailing_last_comma)",
      "happy": "$(happy --version | head -1 | col 3)"
    },
    "scala": {
      "all": [
        $(all_sbt)
      ]
    },
    "redis": "$(redis-server --version | col 3 | sed 's/^v=//')",
    "memcached": "$(memcached -h | head -1 | col 2)",
    "git": "$(git --version | col 3)",
    "gcc": "$(gcc --version | head -n1 | col 4)",
    "g++": "$(g++ --version | head -n1 | col 4)",
    "cc": "$(cc --version | head -1 | col 4)",
    "c++": "$(c++ --version | head -1 | col 4)",
    "make": "$(make --version | head -1 | col 3)",
    "maven": "$(mvn --version | head -1 | col 3)",
    "ant": "$(ant -version | col 4)",
    "apache2": "$(apache2 -version | grep 'Server version' | col 3 | cut -d '/' -f 2)",
    "beanstalkd": "$(beanstalkd -v | col 2)",
    "cassandra": "$(cassandra -v | tail -1)",
    "elasticsearch": "$(/usr/share/elasticsearch/bin/elasticsearch -v | col 2 | sed 's/,//g')",
    "neo4j": "$(neo4j-shell --version | col 4)",
    "riak": "$(riak version)",
    "memcached": "$(memcached -h | head -1 | col 2)",
    "couchdb": "$(couchdb -V | head -1 | col 5)",
    "geos": "$(geos-config --version)",
    "go": "$(go version | col 3 | sed 's/^go//')",
    "gradle": "$(gradle --version | grep Gradle | col 2)",
    "phantomjs": "$(phantomjs --version)",
    "docker": "$(docker --version | col 3 | sed 's/-circleci.*//')",
    "docker-compose": "$(docker-compose --version | col 3 | sed 's/,//g')",
    "heroku-toolbelt": "$(heroku version | grep toolbelt | col 1 | sed 's|.*/||')",
    "gcloud": "$(/opt/google-cloud-sdk/bin/gcloud version | grep "Google Cloud SDK" | col 4)",
    "aws-cli": "$(aws --version 2>&1  | col 1 | sed 's|.*/||')",
    "android": {
      "build-tool": "$(grep 'Pkg.Revision=' $ANDROID_HOME/tools/source.properties | sed 's/Pkg.Revision=//')",
      "build-tools": [
        $(ls $ANDROID_HOME/build-tools | quotify | commatize | trailing_last_comma)
      ],
      "platforms": [
        $(ls $ANDROID_HOME/platforms | quotify | commatize | trailing_last_comma)
      ],
      "emulator-images": [
        $(ls $ANDROID_HOME/system-images/ | sed 's/android/sys-img-armeabi-v7-android/g' | quotify | commatize | trailing_last_comma)
      ],
      "add-ons": [
        $(ls $ANDROID_HOME/add-ons | quotify | commatize | trailing_last_comma)
      ],
      "android-extra": [
        $(ls $ANDROID_HOME/extras/android | quotify | commatize | trailing_last_comma)
      ],
      "google-extra": [
        $(ls $ANDROID_HOME/extras/google | quotify | commatize | trailing_last_comma)
      ]
    }
  },
  "all": {
    $(dpkg -l | grep -e '^ii' | awk '{printf "\"%s\": \"%s\",\n", $2,$3}' | trailing_last_comma)
  }
}
EOF
