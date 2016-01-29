#!/bin/bash

set -e

OUTPUT_FILE=${1:-provision.sh}


MODULES=(
    # Basic things to get going
    base_requirements
    circleci_specific

    # Languages
    # no go in lev's provision.sh from the last image
    # p.s., go is broken somehow, version or url might be wrong
    # "golang 1.5"
    # last zenefits image had java 8 but in the wrong place.
    java
    # last zenefits image had node 0.12.7
    # todo: there's some problem with it
    # "nodejs 5.5.0"
    # no scala in lev's provision.sh from the last image
    # todo: there's some problem with it
    # scala
    # only system python in lev's provision.sh from the last image
    # todo: there's some problem with it
    # "python 2.7.11"
    # no ruby in lev's provision.sh from the last image
    # todo: there's some problem with it
    # "ruby 2.3.0"

    # Browsers
    chrome
    firefox

    # DBs
    # no mongo, postgres in lev's provision.sh from the last image
    # mongo
    # postgres
    mysql_56

    # Misc
    # no casperjs, heroku in lev's provision.sh from the last image
    # casperjs
    # todo: maybe heroku needs a version? hard to tell
    # heroku
    docker
    redis
    # no memcached in lev's provision.sh from the last image
    # memcached
    sysadmin
    devtools
)

cat helper.sh > $OUTPUT_FILE
cat circleci-provision-scripts/* >> $OUTPUT_FILE
for n in ${MODULES[*]}
do
    echo "install_$n" >> $OUTPUT_FILE
done

chmod +x $OUTPUT_FILE
