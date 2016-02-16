[![Build Status](https://travis-ci.org/danReynolds/SupermarKit.svg?branch=master)](https://travis-ci.org/danReynolds/SupermarKit)
[![Code Climate](https://codeclimate.com/github/danReynolds/SupermarKit/badges/gpa.svg)](https://codeclimate.com/github/danReynolds/SupermarKit)
[![Stories in Ready](https://badge.waffle.io/danReynolds/SupermarKit.svg?label=ready&title=Ready)](http://waffle.io/danReynolds/SupermarKit)
[![Coverage Status](https://coveralls.io/repos/danReynolds/SupermarKit/badge.svg?branch=master)](https://coveralls.io/r/danReynolds/SupermarKit?branch=master)
# SupermarKit.
SupermarKit is a free grocery-tracking application born out of the need for a better solution to get food from the store to our mouths. If you also struggle with this issue, or just want to see what we're all about, make an account and try us out.

Need groceries? We have plenty of details about how we can help at [SupermarKit](http://supermarkit.ca).

## Installation

To run the app, you can do so natively or use vagrant. The following steps are for running the app under Vagrant on Ubuntu, but are easy to change for other distros.

Note: the vagrant version on Ubuntu 14.04 was too old for me using the official repositories, so if that one doesn't work, it can be downloaded from the vagrant site.

```
sudo apt-get install virtualbox vagrant
vagrant plugin install vagrant-librarian-chef-nochef vagrant-vbguest
vagrant up
vagrant ssh
cd /vagrant
bundle
rake db:create
rake db:migrate
```

Then to run the app, start the server on the forwarded port 4000:

```
rails server -p 4000 -b 0.0.0.0
```

Happy developing!
