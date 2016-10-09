source 'https://rubygems.org'

gem 'active_record_union'
gem 'bourbon'
gem 'canard', '0.4.2.pre'
gem 'capistrano-bundler', require: false
gem 'capistrano-rails-console', require: false
gem 'capistrano-rails',   require: false
gem 'capistrano-rvm',     require: false
gem 'capistrano',         require: false
gem 'capistrano3-puma',   require: false
gem 'underscore-rails'
gem 'codeclimate-test-reporter', group: :test, require: nil
gem 'coffee-rails', '~> 4.0.0'
gem 'coveralls', require: false
gem 'dropzonejs-rails'
gem 'dotenv-rails'
gem 'haml-rails'
gem 'inline_svg'
gem 'premailer-rails'
gem 'font-awesome-sass', '~> 4.5.0'
gem 'happy_path'
gem 'jbuilder', '~> 2.0'
gem 'jquery-datatables-rails', '~> 3.1.1'
gem 'jquery-rails'
gem 'maildown'
gem 'materialize-sass', git: 'https://github.com/danReynolds/materialize-sass.git'
gem 'money-rails'
gem 'mysql2'
gem 'neat'
gem 'nokogiri'
gem 'puma'
gem 'rails', '4.2.3'
gem 'react-rails', '~> 1.5.0'
gem 'sass-rails'
gem 'sdoc', '~> 0.4.0',          group: :doc
gem 'simple_form'
gem 'sorcery'
gem 'uglifier', '>= 1.3.0'
gem 'paperclip'
gem 'aws-sdk', '< 2.0'
gem 'linguistics'
gem 'geokit-rails'
gem 'rollbar'
gem 'dogapi', '>=1.3.0'
gem 'newrelic_rpm'
gem 'sentry-raven'
gem 'amatch'
gem 'ruby-units'
gem 'fractional'
gem 'ingreedy', git: 'https://github.com/danReynolds/ingreedy.git'
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
	gem 'meta_request'
	gem 'stackprof'
  gem 'pry'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'spring-commands-rspec'
  gem 'spring'
	gem 'quiet_assets'
	gem 'bullet'
	gem 'gemsurance'
	gem 'rack-mini-profiler'
end
