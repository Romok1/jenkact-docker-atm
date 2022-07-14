#!/bin/bash

set -e

rm -f /jenkact/tmp/pids/server.pid

exec "$@"
