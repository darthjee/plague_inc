#!/bin/bash

RENDER_SERVICE_NAME="plague-inc"

function request() {
  METHOD=$1
  URL=$2

  curl --request $METHOD \
    --url $URL \
    --header 'Accept: application/json' \
    --header "Authorization: Bearer $RENDER_API_KEY"
}

function request_for_service() {
  SERVICE_ID=$(service_id)

  METHOD=$1
  BASE_URL=$2
  URL=$(echo $BASE_URL | sed -e "s/{{service_id}}/$SERVICE_ID/g")

  request $METHOD $URL
}

function services() {
  request GET 'https://api.render.com/v1/services'
}

function deploy() {
  request_for_service POST "https://api.render.com/v1/services/{{service_id}}/deploys"
}

function get_env_vars() {
  request_for_service \
    GET "https://api.render.com/v1/services/{{service_id}}/env-vars" | \
    jq 'map(.envVar)'
}

function service_id() {
  services | jq \
    ".[] | select(.service.name == \"$RENDER_SERVICE_NAME\") | .service.id" \
    | sed -e 's/"//g'
}

function last_deployment() {
  request_for_service \
    GET "https://api.render.com/v1/services/{{service_id}}/deploys?limit=1"
}
