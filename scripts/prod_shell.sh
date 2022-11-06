#!/bin/bash

source "scripts/render.sh"

function run() {
  get_image
  heroku config -s > .env.production
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
  get_env_vars
}

ACTION=$1

case $ACTION in
  "test")
    setup_env
    ;;
  "run")
    run
    ;;
  *)
    $ACTION
    ;;
esac
