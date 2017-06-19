#!/bin/bash

# Temporarly disable errexit to avoid a strange test error during make.
set +o errexit

function install_postgres_ext_postgis() {
    local VERSION=3.5.0
    local FILE=geos-${VERSION}.tar.bz2
    local DIR=geos-${VERSION}
    local URL=http://download.osgeo.org/geos/${FILE}

    apt-get install ruby-dev swig swig2.0 postgis postgresql-9.5-postgis-2.2

    # Install GEOS
    pushd /tmp
    wget $URL
    tar -jxf $FILE
    cd $DIR
    ./configure --enable-ruby "--prefix=/usr"

    make &> "/tmp/goes.log"
    make install

    popd

    rm -rf /tmp/$FILE /tmp/$DIR

    export VERSION=3.5.0
    export FILE=geos-${VERSION}.tar.bz2
    export DIR=geos-${VERSION}
    export URL=http://download.osgeo.org/geos/${FILE}

    disable_96
}

# symlinks the actual postgres directory to the directory where we keep our postgres installs
# this is similar to the nginx sites-available/sites-enabled construct
function enable_postgres_version() {
    ln -s /usr/lib/postgresql-versions/$1 /usr/lib/postgresql/$1
    ln -s /etc/postgresql-versions/$1 /etc/postgresql/$1
}

# we move all of our postgres installs to a separate directory so they can be intentionally enabled individually
# accepts arguments: DEFAULT_VERSION [OTHER_VERSION] [OTHER_VERSION...]
function install_postgres() {
    mkdir /usr/lib/postgresql-versions
    mkdir /etc/postgresql-versions
    for POSTGRES_VERSION in $@; do
        mkdir /usr/lib/postgresql-versions/$POSTGRES_VERSION
        mkdir /etc/postgresql-versions/$POSTGRES_VERSION
        wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

        echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list

        apt-get update
        apt-get install -y postgresql-$POSTGRES_VERSION postgresql-contrib-$POSTGRES_VERSION libpq-dev

        # Configure Postgres

        (cat <<'EOF'
listen_addresses = '*'

# Pstgres 9.4 introduced some dynamic shared memory changes that are incompatible with containers
# Let us disable it for now: https://github.com/aptible/docker-postgresql/issues/14
dynamic_shared_memory_type = none

# Add settings for extensions here
# optimizations from http://rhaas.blogspot.com/2010/06/postgresql-as-in-memory-only-database_24.html
fsync=off
synchronous_commit=off
full_page_writes=off
bgwriter_lru_maxpages=0

EOF
    ) >> /etc/postgresql/$POSTGRES_VERSION/main/postgresql.conf


        # Permissions
        (cat <<'EOF'
local   all     all                     trust
host    all     all             127.0.0.1/32    trust
host    all     all             ::1/128 trust

# To allow for Docker connections
host all all 0.0.0.0/0 trust

EOF
        ) > /etc/postgresql/$POSTGRES_VERSION/main/pg_hba.conf

        sudo service postgresql restart


        # Create databases
        sudo -u postgres psql -c "create role ${CIRCLECI_USER} with superuser login"
        sudo -u postgres psql -c "create role root with superuser login"
        sudo -u postgres createdb ${CIRCLECI_USER}
        sudo -u postgres createdb circle_test
        sudo -u postgres psql -c 'CREATE EXTENSION hstore;' ${CIRCLECI_USER}
        sudo -u postgres psql -c 'CREATE EXTENSION hstore;' circle_test


        # Allow password-less sudo to postgres user
        echo "${CIRCLECI_USER} ALL=(postgres) NOPASSWD:ALL" > /etc/sudoers.d/10-postgres
        mv /usr/lib/postgresql/$POSTGRES_VERSION /usr/lib/postgresql-versions/$POSTGRES_VERSION
        mv /etc/postgresql/$POSTGRES_VERSION /etc/postgresql-versions/$POSTGRES_VERSION
    done
    enable_postgres_version $1
}
