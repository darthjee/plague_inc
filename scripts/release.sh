#!/bin/bash

function isLatestCommit() {
  VERSION=$(git tag | tail -n 1)
  DIFF=$(git diff HEAD $VERSION)

  if [[ $DIFF ]]; then
    return 1
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

echo execute
