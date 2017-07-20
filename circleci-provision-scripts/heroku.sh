#!/bin/bash

function install_heroku() {
    echo '>>> Installing heroku'

    wget -qO- https://cli-assets.heroku.com/install-ubuntu.sh  | sh

    chown -R $CIRCLECI_USER:$CIRCLECI_USER ${CIRCLECI_HOME}/.config

    # Run once to bootstrap heroku cli
    (cat <<'EOF'
heroku --version
EOF
    ) | as_user bash
}
