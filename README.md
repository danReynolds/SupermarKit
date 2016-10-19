[![Build Status](https://circleci.com/gh/danReynolds/SupermarKit.svg?style=svg)](https://circleci.com/gh/danReynolds/SupermarKit)
[![Code Climate](https://codeclimate.com/github/danReynolds/SupermarKit/badges/gpa.svg)](https://codeclimate.com/github/danReynolds/SupermarKit)
[![Coverage Status](https://coveralls.io/repos/github/danReynolds/SupermarKit/badge.svg?branch=master)](https://coveralls.io/github/danReynolds/SupermarKit?branch=master)
# SupermarKit.
SupermarKit is a free grocery-tracking application born out of the need for a better solution to get food from the store to our mouths. If you also struggle with this issue, or just want to see what we're all about, make an account and try us out.

Need groceries? We have plenty of details about how we can help at [SupermarKit](http://supermarkit.io).
Want to contact us? Email team@supermarkit.io to let us know about suggestions or concerns.
## Installation

To run the app, you can do so natively or use vagrant. The following steps are for running the app under Vagrant on Ubuntu, but are easy to change for other distros.

Note: the vagrant version on Ubuntu 14.04 was too old for me using the official repositories, so if that one doesn't work, it can be downloaded from the vagrant site.

Clone and navigate to the repository and run:

```
sudo apt-get install virtualbox vagrant
vagrant plugin install vagrant-librarian-chef-nochef vagrant-vbguest vagrant-omnibus
vagrant up
```
And visit localhost:4000 in your browser.

Happy developing!

