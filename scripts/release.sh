#!/bin/bash

function isLatestCommit() {
  VERSION=$(git tag | grep $(git describe  --tags))

  if [[ $VERSION ]]; then
    return 0
  else
    return 0
  fi
}

if $(isLatestCommit); then
  echo "latest commit";
else
  echo "Not last commit"
  exit 0
fi

ACTION=$1

case $ACTION in
  "build")
    make PROJECT=production_plague_inc build
    ;;
  "build-web")
    make PROJECT=production_plague_inc build-web
    ;;
  *)
    echo Usage:
    echo "$0 build # builds gem"
    echo "$0 push # pushes gem"
    ;;
esac
