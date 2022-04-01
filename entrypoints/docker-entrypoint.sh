#!/bin/sh

set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# mv /app/apimaxia/database.yml.example /app/apimaxia/config/database.yml

#sleep infinity
# tail -f /dev/null
bundle exec rails s -b 0.0.0.0 -p ${PORT}

