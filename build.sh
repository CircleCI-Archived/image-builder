#!/bin/bash

set -e

OUTPUT_FILE=${1:-provision.sh}


MODULES=(
	# Basic things to get going
	base
	circle-specific


	# Languages
	go
	java
	nodejs
	scala
	python
	ruby

	# Browsers
	chrome
	firefox

	# DBs
	mongo
	pgsql
	mysql

	# Misc
	casperjs
	misc
	heroku
	docker
)

cat helper.sh > $OUTPUT_FILE
for n in ${MODULES[*]}
do
	cat scripts/${n}.sh >> $OUTPUT_FILE
done

chmod +x $OUTPUT_FILE
