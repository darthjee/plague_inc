#!/usr/bin/bash

# install dependencies and clean old ones at the same time
# rake bower:install

rm -f  /home/app/app/tmp/pids/server.pid
if [ "$RACK_ENV" != "production" ]; then
  bundle exec rake db:create
fi

bundle exec rake db:migrate db:seed

# bundle exec rails s -b 0.0.0.0
bundle exec puma -C config/puma.rb
