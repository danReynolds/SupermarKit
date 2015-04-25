console.time('total')
console.time('startup')
var browserify = require('browserify')
var browserifyCache = require('../')
var fs = require('fs')
var makeMetricsStream = require('./metrics')
console.timeEnd('startup')

var cache = true

if (cache) {
  var opts = {cacheFile: __dirname+'/output/cache.json'}
} else {
  var opts = {}
}

console.time('cache fill')
var b = browserify(browserifyCache.args)
browserifyCache(b, opts)
console.timeEnd('cache fill')

b.on('changedDeps', function(updated) { console.log(['changed files:'].concat(updated||[]).join('\n')) })
b.add(__dirname + '/test-module')

process.on('exit', function () { console.timeEnd('total') })

run() // start test

function run() {
  console.time('bundle')
  b.bundle()
    .on('end', function(){ console.timeEnd('bundle') })
    .pipe(makeMetricsStream())
    .pipe(fs.createWriteStream(__dirname+'/output/bundle.js'))
}

