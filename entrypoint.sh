#!/bin/bash

set -e

rm -f /jenkact-docker-atm/tmp/pids/server.pid

rm -r tmp/

exec "$@"
