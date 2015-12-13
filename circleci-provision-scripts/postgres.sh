#!/bin/bash

function postgres() {
    POSTGRES_VERSION=9.4

    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

    echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list

    apt-get update
    apt-get install -y postgresql-$POSTGRES_VERSION postgresql-contrib-$POSTGRES_VERSION

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
    ) >> /etc/postgresql/$POSTGRES_VERSION/main/pg_hba.conf

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
}
