#!/bin/bash

for I in {1..30}; do
  if ( echo "" | telnet $PLAGUE_INC_MYSQL_HOST $PLAGUE_INC_MYSQL_PORT | grep Escape ); then
    echo done;
    exit 0;
  fi
  sleep 1;
done

exit 1;
