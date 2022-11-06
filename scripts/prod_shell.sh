#!/bin/bash

source "scripts/render.sh"

function run() {
  setup_env
  clean_env & run_docker
}

function run_docker() {
  docker-compose run plague_inc_production /bin/bash
}

function clean_env() {
  sleep 10
  echo "" > .env.production
}

function setup_env() {
  get_env_vars | \
    jq 'map([.key, .value] | join("=")) | .[]' | \
    sed -e 's/^ *"//g' -e 's/" *$//g'  > .env.production
}

ACTION=$1

case $ACTION in
  "run")
    run
    ;;
  *)
    $ACTION
    ;;
esac
