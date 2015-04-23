# browserify-cache-api

api for caching and reusing discovered dependencies for browserify

used by [browserify-incremental](https://github.com/jsdf/browserify-incremental)
and [browserify-assets](https://github.com/jsdf/browserify-assets)

```js
  var b = browserify(browserifyCache.args);
  browserifyCache(b, opts);
  // browserify dependency discovery and loading is now cached
```

![under construction](http://jamesfriend.com.au/files/under-construction.gif)
