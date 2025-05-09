#!/bin/bash

# docker-entrypoint.sh
echo "run nginx!!!"

if [ "$1" = "nginx" ]; then
    nginx -s stop
fi

echo "$@"

exec "$@"
