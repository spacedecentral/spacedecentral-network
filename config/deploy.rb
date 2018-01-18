# config valid only for current version of Capistrano
lock "3.10.1"

set :application, "spacedecentral"
set :repo_url, "git@github.com:spacedecentral/spacedecentral-network.git"


set :assets_roles, [:web, :app]

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/rails_prod/spacedecentral"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :passenger_in_gemfile, true

namespace :figaro do
  desc "Symlink application.yml to the release path"
  task :symlink do
    on roles :all do
      execute :ln, "-sf #{shared_path}/application.yml #{release_path}/config/application.yml"
    end
  end
end
namespace :googleoauth do
  task :symlink do
    on roles :all do
      execute :ln, "-sf #{shared_path}/client_secrets.json #{release_path}/client_secrets.json"
    end
  end
end
namespace :googlesvca do
  task :symlink do
    on roles :all do
      execute :ln, "-sf #{shared_path}/spacedecentral-creds.json #{release_path}/spacedecentral-creds.json"
    end
  end
end
namespace :copyerrorpages do
  task :copypages do
    on roles :all do
      execute :cp, "#{release_path}/public/assets/*.html #{release_path}/public/"
    end
  end
end

before 'deploy:updating', "figaro:symlink"
after 'deploy', "googlesvca:symlink"
after 'deploy', "googleoauth:symlink"
after 'deploy', "copyerrorpages:copypages"
