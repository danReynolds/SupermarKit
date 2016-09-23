require 'capistrano/datadog'
require 'dotenv'
Dotenv.load

set :datadog_api_key, ENV['DATA_DOG_KEY']
set :console_user,    :deploy
set :app_user,    :deploy

# Load DSL and Setup Up Stages
require 'capistrano/setup'
require 'capistrano/deploy'

require 'capistrano/rails'
require 'capistrano/bundler'
require 'capistrano/rvm'
require 'capistrano/puma'
require 'capistrano/rails/console'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
