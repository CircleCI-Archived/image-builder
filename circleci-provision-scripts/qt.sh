#!/bin/bash

function install_qt() {
    apt-get -y install qt5-default qt5-qmake qtbase5-dev libqt5webkit5-dev

    # Installing Qt 5.5 under /opt/qt55 to coexist with previous version
    # To use qt 55, run
    #
    #    source /opt/qt55/bin/qt55-env.sh
    #
    # To persist the version, run
    #
    #    echo 'source /opt/qt55/bin/qt55-env.sh' >> ${CIRCLECI_HOME}/.circlerc
    add-apt-repository -y ppa:beineri/opt-qt551-trusty
    apt-get update
    apt-get install qt55base qt55webkit
}
