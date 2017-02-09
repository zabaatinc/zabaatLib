var PENDING   = 0;
var FULFILLED = 1;
var REJECTED  = 2;
var ADOPTED   = 3;  //adopted the state of another promise, _value
var setTimeout


//Promise.all waits for all fulfillments (or the first rejection).
function All(promiseArray) {
    return new Promise(function(resolve,reject) {
        var args = Array.prototype.slice.call(promiseArray);
        var results = []
        if(args.length === 0)
            return resolve(results);

        var remaining = args.length;

        function res(i,val) {
            if(val && (typeof val === 'object' || typeof val === 'function') )  {
                var then = getThen(val);
                if(typeof then === 'function') {
//                    console.log("then is a function", val.state)
//                    while(val.state === PENDING) {
////                        console.log("waiting")
//                        //wait
//                    }
                    //hey already fulfilled, yowzers. no need to call then
                    if(val.state === FULFILLED) {
//                        console.log("case 1")
                        args[i] = val.value;
                        if (--remaining === 0) {
                          resolve(args);
                        }
                        return;
                    }
                    if(val.state === REJECTED) {
//                        console.log("case 2")
                        reject(val.value);
                    }

                    //if promise succeeded, add its value to args , otherwise call the main reject
                    val.then(function(val) {
//                        console.log("calling then success", val)
                        args[i] = val;

                        //succeed makes remaining go down by 1. if we hit 0, we have resolved the main promise!!
                        if (--remaining === 0) {
                          resolve(args);
                        }
//                        res(i,val.value);
                    } , reject)
                }
                else {
                    args[i] = val.value;
                    if (--remaining === 0) {
                      resolve(args);
                    }
                    return;
                }
            }

        }

        for(var i = 0; i < args.length; ++i){
            res(i, args[i])
        }
    })

}

//Promise.prototype.state = PENDING;
function Promise(fn) {
  // store state which can be PENDING, FULFILLED or REJECTED
  var self  = this;
  this.state = PENDING;

  // store value once FULFILLED or REJECTED
  this.value = null;

  // store sucess & failure handlers
  var handlers = [];

  this.fulfill = function(result) {
    self.state = FULFILLED;
    self.value = result;
    handlers.forEach(handle);
    handlers = null;
  }

  this.reject = function(error) {
    self.state = REJECTED;
    self.value = error;
    handlers.forEach(handle);
    handlers = null;
  }

  this.resolve = function(result) {
    try {
      var then = getThen(result);
      if (then) {
        doResolve(then.bind(result), self.resolve, self.reject)
        return
      }
      self.fulfill(result);
    } catch (e) {
      self.reject(e);
    }
  }

  function handle(handler) {
    //console.log("handled", handler)
    if (self.state === PENDING) {
      handlers.push(handler);
    } else {
      if (self.state === FULFILLED &&
        typeof handler.onFulfilled === 'function') {
        handler.onFulfilled(self.value);
      }
      if (self.state === REJECTED &&
        typeof handler.onRejected === 'function') {
        handler.onRejected(self.value);
      }
    }
  }

  this.done = function (onFulfilled, onRejected) {
    // ensure we are always asynchronous
    setTimeout(function () {
      handle({
        onFulfilled: onFulfilled,
        onRejected: onRejected
      });
    }, 0);
  }

  this.then = function (onFulfilled, onRejected) {
    var self = this;
    return new Promise(function (resolve, reject) {

      function fulfillFunc(result) {
          if (typeof onFulfilled === 'function') {
            try {
              return resolve(onFulfilled(result));
            } catch (ex) {
              return reject(ex);
            }
          } else {
            return resolve(result);
          }
      }

      function rejectFunc(error){
          if (typeof onRejected === 'function') {
            try {
              return resolve(onRejected(error));
            } catch (ex) {
              return reject(ex);
            }
          } else {
            return reject(error);
          }
      }

      return self.done(fulfillFunc, rejectFunc);
    });
  }

  this.catch = function(onRejected) {
//      console.log("CALLING .catch", onRejected)
      return this.then(undefined, onRejected);
  }

  this.finally = function (f) {
        var fulfill = function(value) {
            return new Promise(f).then(function() { return value })
        }
        var reject = function(err) {
            return new Promise(f).then(function() {  throw err })
        }

        return this.then(fulfill, reject);
//      return this.then(onFulfilled, onRejected);
//          function (value) {
//                return Promise.resolve(f()).then(function () {
//                  return value;
//                });
//          }
//          ,
//          function (err) {
//                return Promise.resolve(f()).then(function () {
//                    throw err;
//                });
//          }
//      );
  };

  doResolve(fn, self.resolve, self.reject);
}

function Race(promiseArray) {
    return new Promise(function(resolve,reject) {
        if(!promiseArray || toString.call(promiseArray) !== '[object Array]' || promiseArray.length === 0) {
            return resolve();
        }

        function res(val) {
            if(val && (typeof val === 'object' || typeof val === 'function') )  {
                var then = getThen(val);
                if(typeof then === 'function') {
                    //hey already fulfilled, yowzers. no need to call then
                    if(val.state === FULFILLED) {
                        return resolve(val.value);
                    }
                    if(val.state === REJECTED) {
                        for(var k in val.value)
                            console.log(k,typeof val.value[k])
                        return reject(val.value);
                    }

                    //if promise succeeded, add its value to args , otherwise call the main reject
                    val.then(resolve , reject)
                }
                else {
                    return resolve(val.value);
                }
            }
        }

        for(var i = 0; i < promiseArray.length; ++i){
            res(promiseArray[i])
        }
    })
}



/**
 * Check if a value is a Promise and, if it is,
 * return the `then` method of that promise.
 *
 * @param {Promise|Any} value
 * @return {Function|Null}
 */
function getThen(value) {
  var t = typeof value;
  if (value && (t === 'object' || t === 'function')) {
    var then = value.then;
    if (typeof then === 'function') {
      return then;
    }
  }
  return null;
}

/**
 * Take a potentially misbehaving resolver function and make sure
 * onFulfilled and onRejected are only called once.
 *
 * Makes no guarantees about asynchrony.
 *
 * @param {Function} fn A resolver function that may not be trusted
 * @param {Function} onFulfilled
 * @param {Function} onRejected
 */
function doResolve(fn, onFulfilled, onRejected) {
  var done = false;
  try {
    fn(function (value) {
      if (done) return
      done = true
      onFulfilled(value)
    }, function (reason) {
      if (done) return
      done = true
      onRejected(reason)
    })
  } catch (ex) {
    if (done) return
    done = true
    onRejected(ex)
  }
}
