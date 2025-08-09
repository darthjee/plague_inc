#!/usr/bin/bash

# Tempo máximo de espera (em segundos)
MAX_RETRIES=${MAX_RETRIES:-30}
RETRY_INTERVAL=${RETRY_INTERVAL:-2}

echo "Waiting for database in $PLAGUE_INC_MYSQL_HOST:$PLAGUE_INC_MYSQL_PORT ..."

for ((i=1; i<=MAX_RETRIES; i++)); do
  if echo "" | telnet $PLAGUE_INC_MYSQL_HOST $PLAGUE_INC_MYSQL_PORT; then
    exit 0
  fi

  sleep "$RETRY_INTERVAL"
done

echo "Database inaccessible after $MAX_RETRIES attempts."
exit 1
