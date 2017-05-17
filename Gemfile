source 'https://rubygems.org'

gem 'active_model_serializers'
gem 'active_record_union'
gem 'amatch'
gem 'aws-sdk'
gem 'bourbon'
gem 'canard', '0.4.2.pre'
gem 'capistrano-rails',   require: false
gem 'capistrano-bundler', require: false
gem 'capistrano-rails-console', require: false
gem 'capistrano-rvm',     require: false
gem 'capistrano',         require: false
gem 'capistrano3-puma',   require: false
gem 'codeclimate-test-reporter', group: :test, require: nil
gem 'coffee-rails'
gem 'coveralls', require: false
gem 'dogapi', '>=1.3.0'
gem 'dotenv-rails'
gem 'dropzonejs-rails'
gem 'font-awesome-sass', '~> 4.5.0'
gem 'fractional'
gem 'geokit-rails'
gem 'haml-rails'
gem 'happy_path'
gem 'ingreedy', git: 'https://github.com/danReynolds/ingreedy.git'
gem 'inline_svg'
gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'linguistics'
gem 'maildown'
gem 'materialize-sass', git: 'https://github.com/danReynolds/materialize-sass.git'
gem 'momentjs-rails'
gem 'money-rails'
gem 'mysql2'
gem 'neat'
gem 'newrelic_rpm'
gem 'nokogiri'
gem 'paperclip'
gem 'puma'
gem 'rails', '~> 5.0.0'
gem 'react-rails'
gem 'rollbar'
gem 'ruby-units'
gem 'sass-rails'
gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'sentry-raven'
gem 'simple_form'
gem 'slack-ruby-client'
gem 'sorcery', git: 'https://github.com/danReynolds/sorcery.git'
gem 'turbolinks', '~> 5.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'underscore-rails'

if ENV["LOCAL_ENVIRONMENT"] == "development"
	TESSERACT_GEM = 'git@github.com:danReynolds/ruby-tesseract-ocr.git'
else
	TESSERACT_GEM = 'https://github.com/meh/ruby-tesseract-ocr.git'
end

gem 'tesseract-ocr', git: TESSERACT_GEM

group :test do
	gem 'webmock'
end

group :development, :test do
	gem 'better_errors'
	gem 'binding_of_caller'
	gem 'stackprof'
  gem 'pry'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'spring-commands-rspec'
  gem 'spring'
	gem 'bullet'
	gem 'gemsurance'
	gem 'rack-mini-profiler'
	gem 'rubocop'
end
