#!/bin/bash

help() {
    cat << EOF
trigger-job: triggering an image-builder job

Usage:
  trigger-job [-n] <job> <branch>

-n: Using no cache in docker build

Example:
  trigger-job ubuntu-14.04 test-branch
EOF
}

trigger-job() {
    local job=$1
    local branch=$2
    local no_cache=$3
    local no_cache_docker_opt=""

    if [[ $no_cache = "true" ]]; then
       no_cache_docker_opt="--no-cache"
    fi

    if [[ $no_cache = "true" ]]; then
        echo "Triggering $job with no cache..."
    else
        echo "Triggering $job..."
    fi

    curl -u ${CIRCLE_TOKEN}: \
         -d build_parameters[CIRCLE_JOB]=$job \
         -d build_parameters[NO_CACHE]=$no_cache_docker_opt \
         https://circleci.com/api/v1.1/project/github/circleci/image-builder/tree/$branch
}

while getopts n:h OPT
do
    case $OPT in
        n)  no_cache="true"
            shift
            ;;
        h)  help
            exit 0
            ;;
        \?) help
            exit 0
            ;;
    esac
done

job=$1
branch=$2

if [[ -z $CIRCLE_TOKEN ]]; then
    echo "You must set CIRCLE_TOKEN env var"
    exit 1
fi

if [[ -z $job ]]; then
    echo "Error: You must specify at least one job"
    echo ""
    help
    exit 1
fi

if [[ -z $branch ]]; then
    echo "Error: You must specify at least one branch"
    echo ""
    help
    exit 1
fi

trigger-job $job $branch $no_cache
