#!/bin/bash

set -e

trigger-job() {
    local job
    curl -X POST --header "Content-Type: application/json" -d '{}' "http://dev.circlehost:8080/api/v1.1/project/github/$repo/tree/$branch?circle-token=$CIRCLE_TOKEN"
}
