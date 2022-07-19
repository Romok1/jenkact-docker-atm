#!/bin/bash +x
docker-compose --project-name=${JOB_NAME} stop &> /dev/null || true &> /dev/null
docker-compose --project-name=${JOB_NAME} rm --force &> /dev/null || true &> /dev/null
docker stop `docker ps -a -q -f status=exited` &> /dev/null || true &> /dev/null
docker rm -v `docker ps -a -q -f status=exited` &> /dev/null || true &> /dev/null
docker rmi `docker images --filter 'dangling=true' -q --no-trunc` &> /dev/null || true &> /dev/null
