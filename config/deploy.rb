# config valid for current version and patch releases of Capistrano
lock "~> 3.17.0"

#set :application, "my_app_name"
#set :repo_url, "git@example.com:me/my_repo.git"

set :application, "jenkact"
set :repo_url, "git@github.com:Romok1/jenkact.git"

set :deploy_user, 'wcmc'

set :scm_username, "Romok1"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

set :deploy_to, "/home/#{fetch(:deploy_user)}/#{fetch(:application)}"
set :backup_path, "/home/#{fetch(:deploy_user)}/Backup"

set :deploy_via, :remote_cache

set :rvm_type, :user
set :rvm_ruby_version, '3.1.0'

set :ssh_options, {
  forward_agent: true,
}

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'
set :linked_files, %w{config/database.yml config/master.key}
# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "tmp/webpacker", "public/system", "vendor", "storage"

set :linked_dirs, fetch(:linked_dirs, []).push("log", "tmp/pids", "tmp/cache", "tmp/sockets", "tmp/webpacker", "public/system", "vendor/bundle", "storage", "node_modules", "client/node_modules")

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

after 'deploy:check:make_linked_dirs', 'configkey:setupkey'

after 'deploy:check:make_linked_dirs', 'configdb:setupdb'

set :passenger_restart_with_touch, false
