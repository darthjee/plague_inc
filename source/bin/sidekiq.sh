#!/usr/bin/bash

bin/wait_for_db.sh
bundle exec sidekiq -C config/sidekiq.yml
