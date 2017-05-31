#!/bin/bash

function install_clojure() {
    LEIN_VERSION=2.7.1
    LEIN_URL=https://raw.github.com/technomancy/leiningen/${LEIN_VERSION}/bin/lein
    LEIN_BIN=/usr/local/bin/lein

    curl -L -o $LEIN_BIN $LEIN_URL
    chmod +x $LEIN_BIN

    (cat <<'EOF'
# Force dependencies to download
lein -v
EOF
    ) | as_user bash
}
