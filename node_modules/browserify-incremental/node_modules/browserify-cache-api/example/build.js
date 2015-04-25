var browserify = require('browserify')
var browserifyCache = require('../')
var fs = require('fs')

var makeMetricsStream = require('./metrics')

var counter = 5
var testTimeout = 1000

var b = browserify(browserifyCache.args)

browserifyCache(b)

b.add(__dirname + '/test-module')

run() // start test

function run() {
  b.bundle()
    .on('end', next)
    .pipe(makeMetricsStream())
    .pipe(fs.createWriteStream(__dirname + '/output/bundle.js'))
}

function next() {
  if (counter-- > 0) setTimeout(run, testTimeout)
  else console.log('done')
}
