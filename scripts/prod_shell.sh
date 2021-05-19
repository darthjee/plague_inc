#!/bin/bash

function run() {
  get_image
  heroku config -s > .env.production
  clean_env & \
    PRODUCTION_IMAGE=$(docker_url) \
    docker-compose run plague_inc_production /bin/bash
}

function clean_env() {
  sleep 5
  echo "" > .env.production
}

function app_name(){
  echo $(heroku info -s | grep git_url | sed -e "s/.*\///g" | sed -e "s/\.git.*//g")
}

function get_image() {
  URL=$(docker_url)
  if ! (docker images | grep "$URL" > /dev/null); then
    download
  fi
}


function download() {
  docker pull $(docker_url)
}

function docker_url() {
  echo registry.heroku.com/$(app_name)/web
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
