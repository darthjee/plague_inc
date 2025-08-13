#!/bin/bash

source "scripts/render.sh"

IMAGE=plague_inc_production

function run() {
  SERVICE_ID=$(service_id)

  setup_env $SERVICE_ID
  clean_env & run_docker
}

function run_docker() {
  docker-compose run $IMAGE /bin/bash
}

function up() {
  SERVICE_ID=$(service_id)

  setup_env $SERVICE_ID
  clean_env & up_docker
}

function up_docker() {
  docker-compose up $IMAGE
}

function clean_env() {
  sleep 10
  echo "" > .env.production
}

function setup_env() {
  get_env_vars $1 | \
    jq 'map([.key, .value] | join("=")) | .[]' | \
    sed -e 's/^ *"//g' -e 's/" *$//g'  > .env.production
}

ACTION=$1

case $ACTION in
  "run")
    run
    ;;
  "up")
    up
    ;;
  *)
    $ACTION
    ;;
esac
