#!/bin/bash

function services() {
  curl --request GET \
    --url 'https://api.render.com/v1/services' \
    --header 'Accept: application/json' \
    --header "Authorization: Bearer $RENDER_API_KEY"
}

ACTION=$1

case $ACTION in
  "services")
    services
    ;;
  *)
    echo Usage:
    echo "$0 services # list services"
    ;;
esac
