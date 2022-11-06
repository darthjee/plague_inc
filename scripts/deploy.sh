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

ACTION=$1

case $ACTION in
  "deploy")
    checkLastVersion
    deploy
    ;;
  "wait")
    deployment_status
    ;;
  *)
    $ACTION
    ;;
esac
