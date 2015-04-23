var through = require('through2')

function makeMetricsStream() {
  var time = Date.now()
  var bytes = 0

  return through(function write (buf, enc, next) {
    bytes += buf.length
    this.push(buf)
    next()
  }, function end () {
    var delta = Date.now() - time
    console.log(bytes + ' bytes written ('
        + (delta / 1000).toFixed(2) + ' seconds)'
    )
    this.push(null)
  })
}

module.exports = makeMetricsStream