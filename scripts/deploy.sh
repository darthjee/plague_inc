#!/bin/bash

RENDER_SERVICE_NAME="plague-inc"

function services() {
  curl --request GET \
    --url 'https://api.render.com/v1/services' \
    --header 'Accept: application/json' \
    --header "Authorization: Bearer $RENDER_API_KEY"
}

function deploy() {
  SERVICE_ID=$(service_id)
  curl --request GET \
    --url "https://api.render.com/v1/services/$SERVICE_ID/deploys" \
    --header 'Accept: application/json' \
    --header "Authorization: Bearer $RENDER_API_KEY"
}

function service_id() {
  services | jq \
    ".[] | select(.service.name == \"$RENDER_SERVICE_NAME\") | .service.id" \
    | sed -e 's/"//g' 
}

deploy
