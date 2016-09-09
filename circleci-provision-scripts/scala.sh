function install_scala() {

    wget https://dl.bintray.com/sbt/debian/sbt-0.13.9.deb
    dpkg -i sbt-0.13.9.deb
    rm sbt-0.13.9.deb

    (cat <<'EOF'
# Run sbt once to download dependencies.
# SBT_OPTS="-XX:MaxMetaspaceSize=384M" sbt -v
SBT_LAUNCH_VERSIONS="0.13.5 0.13.6 0.13.7 0.13.8 0.13.9 0.13.10 0.13.11 0.13.12"
for VER in $(echo $SBT_LAUNCH_VERSIONS); do

SBT_DIR=~/.sbt/.lib/${VER}
SBT_JAR=$SBT_DIR/sbt-launch.jar
SBT_URL="http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/${VER}/sbt-launch.jar"

mkdir -p $SBT_DIR
curl -L -o $SBT_JAR $SBT_URL

done
EOF
    ) | as_user bash
}

## TODO
#     ) | as_user SBT_LAUNCH_VERSIONS="${SBT_LAUNCH_VERSIONS}" bash
