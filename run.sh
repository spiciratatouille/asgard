#!/usr/bin/env sh

set -eu

docker-compose -f $1 up -d
