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

ACTION=$1

case $ACTION in
  "install")
    curl https://cli-assets.heroku.com/install.sh | sh
    ;;
  "set-app")
    heroku git:remote -a $HEROKU_APP_NAME
    ;;
  "signin")
    heroku container:login
    ;;
  "build")
    make PROJECT=production_plague_inc build
    ;;
  "build-heroku")
    make build-heroku
    ;;
  "release")
    make release
    ;;
  "migrate")
    heroku run rake db:migrate
    ;;
  *)
    echo Usage:
    echo "$0 build # builds gem"
    echo "$0 push # pushes gem"
    ;;
esac
