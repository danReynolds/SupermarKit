cd /vagrant
cp config/database.yml.sample config/database.yml
LOCAL_ENVIRONMENT=development bin/bundle install
rake db:create
rake db:migrate
rails server -p 4000 -b 0.0.0.0
