#!/bin/bash +x
set -e

# Remove unnecessary files
echo -e "\033[34mRemoving unnecessary files - step 1 step 1...\033[0m"
rm -f log/*.log &> /dev/null || true &> /dev/null
rm -rf public/uploads/* &> /dev/null || true &> /dev/null

# Build Project
echo -e "\033[34mBuilding Project - step 2 step 2...\033[0m"
docker-compose --project-name=${JOB_NAME} build

# Prepare test database
COMMAND="bundle exec rake db:drop db:create db:migrate"
echo -e "\033[34mRunning - step 3 step 3: $COMMAND\033[0m"
docker-compose --project-name=${JOB_NAME} run  \
	-e RAILS_ENV=test web $COMMAND

# Run tests
COMMAND="bundle exec rspec spec"
echo -e "\033[34mRunning: $COMMAND\033[0m"
unbuffer docker-compose --project-name=${JOB_NAME} run web $COMMAND

# Run rubocop lint
COMMAND="bundle exec rubocop app spec -R --format simple"   
echo -e "\033[34mRunning: $COMMAND\033[0m"
unbuffer docker-compose --project-name=${JOB_NAME} run -e RUBYOPT="-Ku" web $COMMAND
