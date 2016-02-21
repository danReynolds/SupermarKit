cd /vagrant
bin/bundle install
npm install
mv config/database.yml.sample config/database.yml
rake db:create
rake db:migrate
