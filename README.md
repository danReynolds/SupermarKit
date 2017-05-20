[![Build Status](https://circleci.com/gh/danReynolds/SupermarKit.svg?style=svg)](https://circleci.com/gh/danReynolds/SupermarKit)
[![Code Climate](https://codeclimate.com/github/danReynolds/SupermarKit/badges/gpa.svg)](https://codeclimate.com/github/danReynolds/SupermarKit)
[![Coverage Status](https://coveralls.io/repos/github/danReynolds/SupermarKit/badge.svg?branch=master)](https://coveralls.io/github/danReynolds/SupermarKit?branch=master)
# SupermarKit.

SupermarKit helps you maintain grocery lists with features including:

1. Isolated shopping groups called kits
2. Support for searching and adding recipes to lists
3. Making payments between kit members and maintaining kit balances
4. Estimated pricing based on past grocery list item price information
5. Receipt tracking
6. Cooking units

Feel free to try it out at [SupermarKit](http://supermarkit.org).

## Installation

Additionally, you can install pretty simply after installing docker and docker-compose.

Navigate to the cloned directory and run:

```
docker-compose up
docker-compose run app rake:db setup
```
And visit localhost:3000 in your browser.

Let us know how we can make grocery shopping better.
