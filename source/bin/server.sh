#!/usr/bin/env bash

# install dependencies and clean old ones at the same time
# rake bower:install

rm -f  /home/app/app/tmp/pids/server.pid
bundle exec rake db:create db:migrate db:seed

bundle exec rails s -b 0.0.0.0
