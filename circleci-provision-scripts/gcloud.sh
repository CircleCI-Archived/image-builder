#!/bin/bash

function install_gcloud() {
        # Using sudo inside `as_user bash` is confusing but this is needed becase
        # gcloud installation script needs to instal .config/gcloud dir under user's $HOME directory.
        (cat <<'EOF'
sudo bash -c 'curl "https://sdk.cloud.google.com" | CLOUDSDK_CORE_DISABLE_PROMPTS=1 CLOUDSDK_INSTALL_DIR=/opt bash'
EOF
	) | as_user bash
  chown -R $CIRCLECI_USER:$CIRCLECI_USER "/opt/google-cloud-sdk"
	chown -R $CIRCLECI_USER:$CIRCLECI_USER ${CIRCLECI_HOME}/.config

  echo 'export PATH=/opt/google-cloud-sdk/bin:$PATH' >> ${CIRCLECI_HOME}/.circlerc

  if [ -e /home/ubuntu/.config ]; then
      chown -R ubuntu /home/ubuntu/.config
  fi
}
