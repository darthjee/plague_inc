#!/bin/bash

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

RENDER_SERVICE_NAME="plague-inc"

function request() {
  METHOD=$1
  URL=$2

  curl --request $METHOD \
    --url $URL \
    --header 'Accept: application/json' \
    --header "Authorization: Bearer $RENDER_API_KEY"
  }

function services() {
  request GET 'https://api.render.com/v1/services'
}

function deploy() {
  SERVICE_ID=$(service_id)
  request POST "https://api.render.com/v1/services/$SERVICE_ID/deploys"
}

function service_id() {
  services | jq \
    ".[] | select(.service.name == \"$RENDER_SERVICE_NAME\") | .service.id" \
    | sed -e 's/"//g'
  }

checkLastVersion
deploy
