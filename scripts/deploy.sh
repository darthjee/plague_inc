#!/bin/bash

source "scripts/render.sh"

function isLatestCommit() {
  VERSION=$(git tag | grep $(git describe  --tags))

  if [[ $VERSION ]]; then
    return 0
  else
    return 1
  fi
}

function checkLastVersion() {
  if $(isLatestCommit); then
    echo "latest commit";
  else
    echo "Not last commit"
    #exit 0
  fi
}

function check_deployment_status() {
  DEPLOYMENT_ID=$1
  STATUS=$(deployment_status $DEPLOYMENT_ID)

  if [ $STATUS == "live" ]; then
    exit 0
  elif [ $STATUS == "build_failed"]; then
    exit 1
  elif [ $STATUS == "update_failed"]; then
    exit 1
  elif [ $STATUS == "canceled"]; then
    exit 1
  elif [ $STATUS == "deactivated"]; then
    exit 1
  else
    echo "WAITING, current status: $STATUS"
    return 0
  fi
}

checkLastVersion
DEPLOYMENT_ID=$(deploy | jq '.id')
COUNT=0
while (true); do
  check_deployment_status $DEPLOYMENT_ID
  COUNT=$[$COUNT+1]
  if [ $COUNT -gt 10 ]; then
    echo "timed out"
    exit 1
  fi
  sleep 10
done
