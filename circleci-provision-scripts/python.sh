#!/bin/bash

function install_python() {
    VERSION=$1

    sudo apt-get install circleci-python${VERSION}=0.0.1
    
    chown -R $CIRCLECI_USER:$CIRCLECI_USER /opt/circleci/python/$VERSION
    
    (cat <<'EOF'

echo "export PATH=/opt/circleci/python/${VERSION}/bin:$PATH" >> ~/.circlerc

source  ~/.circlerc
pip install -U virtualenv
pip install -U nose
pip install -U pep8
EOF
    ) | as_user VERSION=$VERSION bash    
}
