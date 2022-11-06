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
  SERVICE_ID=$1
  DEPLOYMENT_ID=$2
  STATUS=$(deployment_status $SERVICE_ID $DEPLOYMENT_ID)
  echo "DEPLOYMENT STATUS $STATUS"

  if [ $STATUS == "live" ]; then
    exit 0;
  elif [ $STATUS == "build_failed" ]; then
    exit 1;
  elif [ $STATUS == "update_failed" ]; then
    exit 1;
  elif [ $STATUS == "canceled" ]; then
    exit 1
  elif [ $STATUS == "deactivated" ]; then
    exit 1;
  else
    return 0;
  fi
}

function watch_deployment() {
  SERVICE_ID=$1
  DEPLOYMENT_ID=$2

  COUNT=0
  while (true); do
    check_deployment_status $SERVICE_ID $DEPLOYMENT_ID
    COUNT=$[$COUNT+1]
    if [ $COUNT -gt 10 ]; then
      echo "timed out"
      exit 1
    fi
    sleep 10
  done
}

function run_deploy() {
  SERVICE_ID=$(service_id)
  DEPLOYMENT_ID=$(deploy $SERVICE_ID | jq '.id' | sed -e 's/"//g')
  watch_deployment $SERVICE_ID $DEPLOYMENT_ID
}

function watch_last_deployment() {
  SERVICE_ID=$(service_id)
  DEPLOYMENT_ID=$(last_deployment $SERVICE_ID | jq '.deploy.id' | sed -e 's/"//g')
  watch_deployment $SERVICE_ID $DEPLOYMENT_ID
}

ACTION=$1

checkLastVersion

case $ACTION in
  "deploy")
    run_deploy
    ;;
  "watch")
    watch_last_deployment
    ;;
  *)
    $ACTION
    ;;
esac
