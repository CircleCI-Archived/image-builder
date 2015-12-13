#!/bin/bash

function install_chrome_browser() {
    echo '>>> Installing Chrome'
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list

    apt-get update
    apt-get install google-chrome-stable

    # Disable sandboxing - it conflicts with unprivileged lxc containers
    sed -i 's|HERE/chrome"|HERE/chrome" --disable-setuid-sandbox --enable-logging --no-sandbox|g' \
               "/opt/google/chrome/google-chrome"
}


# Chrome Driver

function install_chromedriver() {
    CHROME_DRIVER_VERSION=2.12
    curl -L -o /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/${CHROME_DRIVER_VERSION}/chromedriver_linux64.zip
    unzip -p /tmp/chromedriver.zip > /usr/local/bin/chromedriver
    chmod +x /usr/local/bin/chromedriver
    rm -rf /tmp/chromedriver.zip
}

function install_chrome() {
    install_chrome_browser
    install_chromedriver
}
