import QtQuick 2.0
import "underscore.js" as UnderscoreLib

QtObject
{
    function compact(arr) 				{ return UnderscoreLib._.compact(arr) }
    function optimizeCb(func, context, argCount) 	{ return UnderscoreLib._.optimizeCb(func,context,argCount) }

    function forEach(obj, iteratee, context) 	{ return UnderscoreLib._.forEach(obj,iteratee,context) }
    function each(obj, iteratee, context) 		{ return UnderscoreLib._.each(obj,iteratee,context) }

    function map(obj,iteratee,context)		{ return UnderscoreLib._.map(obj,iteratee,context) }
    function collect(obj,iteratee,context)		{ return UnderscoreLib._.collect(obj,iteratee,context) }

    function reduce(obj,iteratee,memo,context) 	{ return UnderscoreLib._.reduce(obj,iteratee,memo,context) }
    function foldl(obj,iteratee,memo,context) 	{ return UnderscoreLib._.foldl(obj,iteratee,memo,context) }
    function inject(obj,iteratee,memo,context) 	{ return UnderscoreLib._.inject(obj,iteratee,memo,context) }


    function reduceRight(obj,iteratee,memo,context) { return UnderscoreLib._.reduceRight(obj,iteratee,memo,context) }
    function foldr(obj,iteratee,memo,context)	      { return UnderscoreLib._.foldr(obj,iteratee,memo,context) }

    function find(obj,predicate,context) { return UnderscoreLib._.find(obj,predicate,context) }
    function detect(obj,predicate,context) { return UnderscoreLib._.detect(obj,predicate,context) }

    function filter(obj,predicate,context) { return UnderscoreLib._.filter(obj,predicate,context) }
    function select(obj,predicate,context) { return UnderscoreLib._.select(obj,predicate,context) }
    function reject(obj,predicate,context) { return UnderscoreLib._.reject(obj,predicate,context) }

    function every(obj,predicate,context) { return UnderscoreLib._.every(obj,predicate,context) }
    function all(obj,predicate,context) { return UnderscoreLib._.all(obj,predicate,context) }

    function some(obj,predicate,context) { return UnderscoreLib._.some(obj,predicate,context) }
    function any(obj,predicate,context) { return UnderscoreLib._.any(obj,predicate,context) }

    function contains(obj,target) { return UnderscoreLib._.contains(obj,target) }
    function include(obj,target)   { return UnderscoreLib._.include(obj,target) }

    function invoke(obj,method) { return UnderscoreLib._.invoke(obj,method) }
    function pluck(obj,key) { return UnderscoreLib._.pluck(obj,key) }

    function chain(obj)                  { return UnderscoreLib._.chain(obj) }
    function indexBy()                   { return UnderscoreLib._.indexBy.apply(this,arguments) }
    function groupBy()                   { return UnderscoreLib._.groupBy.apply(this,arguments) }
    function countBy(obj, func)          { return UnderscoreLib._.countBy.apply(this,arguments) }

    function where(obj,attrs) { return UnderscoreLib._.where(obj,attrs) }
    function findWhere(obj,attrs) { return UnderscoreLib._.findWhere(obj,attrs) }

    function max(obj,iteratee,context) { return UnderscoreLib._.max(obj,iteratee,context) }
    function min(obj,iteratee,context) { return UnderscoreLib._.min(obj,iteratee,context) }
    function shuffle(obj) { return UnderscoreLib._.shuffle(obj) }
    function sample(obj,n,guard) { return UnderscoreLib._.sample(obj,n,guard) }
    function sortBy(obj,iteratee,context) { return UnderscoreLib._.sortBy(obj,iteratee,context) }
    function sortedIndex(array,obj,iteratee,context) { return UnderscoreLib._.sortedIndex(array,obj,iteratee,context) }
    function toArray(obj) { return UnderscoreLib._.toArray(obj) }
    function size(obj) { return UnderscoreLib._.size(obj) }
    function partition(obj,predicate,context) { return UnderscoreLib._.partition(obj,predicate,context) }
    function first(array,n,guard) { return UnderscoreLib._.first(array,n,guard) }
    function head(array,n,guard) { return UnderscoreLib._.head(array,n,guard) }
    function take(array,n,guard) { return UnderscoreLib._.take(array,n,guard) }

    function initial(array,n,guard) { return UnderscoreLib._.initial(array,n,guard) }
    function last(array,n,guard) { return UnderscoreLib._.last(array,n,guard) }

    function rest(array,n,guard) { return UnderscoreLib._.rest(array,n,guard) }
    function tail(array,n,guard) { return UnderscoreLib._.tail(array,n,guard) }
    function drop(array,n,guard) { return UnderscoreLib._.drop(array,n,guard) }

    function flatten(array, shallow) { return UnderscoreLib._.flatten(array,shallow ) }
    function without(array) { return UnderscoreLib._.without(array) }
    function uniq(array, isSorted, iteratee, context) { return  UnderscoreLib._.uniq(array, isSorted, iteratee, context) }
    function unique(array, isSorted, iteratee, context) { return  UnderscoreLib._.unique(array, isSorted, iteratee, context) }
    function uniqueId(prefix,idCounter){return UnderscoreLib._.uniqueId(prefix,idCounter)}

    function isArray(obj) { return UnderscoreLib._.isArray(obj) }

    function union() { return UnderscoreLib._.union.apply(this,arguments) }
    function intersection(array) { return UnderscoreLib._.intersection.apply(this,arguments) }
    function difference(array) { return UnderscoreLib._.difference(array) }
    function zip(array) { return UnderscoreLib._.zip(array) }
    function unzip(array) { return UnderscoreLib._.unzip(array) }
    function object(list,values) { return UnderscoreLib._.object(list,values)  }
    function indexOf(array,item,isSorted) { return UnderscoreLib._.indexOf(array,item,isSorted) }
    function lastIndexOf(array,item,isSorted) { return UnderscoreLib._.lastIndexOf(array,item,isSorted) }
    function findIndex(array,item,isSorted) { return UnderscoreLib._.findIndex(array,item,isSorted) }
    function range(start,stop,stop) { return UnderscoreLib._.range(start,stop,stop)  }
    function executeBound(sourceFunc, boundFunc, context, callingContext, args) { return UnderscoreLib._.executeBound(sourceFunc, boundFunc, context, callingContext, args)  }

    function bind(func, context) { return UnderscoreLib._.bind(func,context) }
    function bindAll(obj) { return UnderscoreLib._.bindAll(obj) }
    function partial(func) { return UnderscoreLib._.partial(func) }

    function memoize(func, hasher) { return UnderscoreLib._.memoize(func, hasher) }
    function delay(func, wait) { return UnderscoreLib._.delay(func, wait) }
    function defer(func) { return UnderscoreLib._.defer(func) }
    function debounce(func,wait,immediate) { return UnderscoreLib._.debounce(func,wait,immediate) }
    function wrap(func, wrapper) { return UnderscoreLib._.wrap(func,wrapper) }

    function negate(predicate){return UnderscoreLib._.negate(predicate)}
    function compose(){return UnderscoreLib._.compose()}
    function after(times,func){return UnderscoreLib._.after(times,func)}
    function before(times,func){return UnderscoreLib._.before(times,func)}
    function collectNonEnumProps(obj,keys){return UnderscoreLib._.collectNonEnumProps(obj,keys)}
    function keys(obj) {return UnderscoreLib._.keys(obj)}
    function keysIn(obj) {return UnderscoreLib._.keysIn(obj)}
    function values(obj){return UnderscoreLib._.values(obj)}
    function pairs(obj){return UnderscoreLib,pairs(obj)}
    function invert(obj){return UnderscoreLib._.invert(obj)}
    function functions(obj) {return UnderscoreLib._.functions(obj)}
    function extend(obj){return UnderscoreLib._.extend(obj)}
    function findKey(obj,predicate,context){return UnderscoreLib._.findKey(obj,predicate,context)}
    function pick(obj,iteratee,context){return UnderscoreLib._.pick(obj,iteratee,context)}
    function omit(obj,iteratee,context){return UnderscoreLib._.omit(obj,iteratee,context)}
    function defaults(obj){return UnderscoreLib._.defaults(obj)}
    function clone(obj){return UnderscoreLib._.clone(obj)}
    function tap(obj,interceptor){return UnderscoreLib._.tap(obj,interceptor)}
    function eq(a,b,aStack,bStack){return UnderscoreLib._.eq(a,b,aStack,bStack)}
    function isEqual(a,b){return UnderscoreLib._.isEqual(a,b)}
    function isEmpty(obj) {return UnderscoreLib._.isEmpty(obj)}
    function isObj(obj){return UnderscoreLib._.isObject(obj)}
//    function isFinite(obj){return UnderscoreLib._.isFinite(obj)}
    function isNan(obj){return UnderscoreLib._.isNan(obj)}
    function isBoolean(obj){return UnderscoreLib._.isBoolean(obj) }
    function isNull(obj){return UnderscoreLib._.isNull(obj)}
    function isUndefined(obj){ return UnderscoreLib._.isUndefined(obj) }
    function has(obj,key){return UnderscoreLib._.has(obj,key)}
    function identity(value){return UnderscoreLib._.identity(value)}
    function constant(value){return UnderscoreLib._.constant(value)}
    function matches(attrs){return UnderscoreLib._.matches(attrs)}
    function times(n,iteratee,context){return UnderscoreLib._.times(n,iteratee,context)}
    function random(min,max){return UnderscoreLib._.random(min,max)}
    function now(){return UnderscoreLib._.now() }
    function result(object,property,fallback){return UnderscoreLib._.result(object, property, fallback)}




      /**
       * Gets the property value at `path` of `object`. If the resolved value is
       * `undefined` the `defaultValue` is used in its place.
       *
       * @static
       * @memberOf _
       * @category Object
       * @param {Object} object The object to query.
       * @param {Array|string} path The path of the property to get.
       * @param {*} [defaultValue] The value returned if the resolved value is `undefined`.
       * @returns {*} Returns the resolved value.
       * @example
       *
       * var object = { 'a': [{ 'b': { 'c': 3 } }] };
       *
       * _.get(object, 'a[0].b.c');
       * // => 3
       *
       * _.get(object, ['a', '0', 'b', 'c']);
       * // => 3
       *
       * _.get(object, 'a.b.c', 'default');
       * // => 'default'
       */
      function get(object, path, defaultValue) {
        var result = object == null ? undefined : baseGet(object, toPath(path), (path + ''));
        return result === undefined ? defaultValue : result;
      }

      /**
       * The base implementation of `get` without support for string paths
       * and default values.
       *
       * @private
       * @param {Object} object The object to query.
       * @param {Array} path The path of the property to get.
       * @param {string} [pathKey] The key representation of path.
       * @returns {*} Returns the resolved value.
       */
      function baseGet(object, path, pathKey) {
        if (object == null) {
          return;
        }
        object = toObject(object);
        if (pathKey !== undefined && pathKey in object) {
          path = [pathKey];
        }
        var index = 0,
            length = path.length;

        while (object != null && index < length) {
          object = toObject(object)[path[index++]];
        }
        return (index && index == length) ? object : undefined;
      }

        /**
             * Converts `value` to an object if it's not one.
             *
             * @private
             * @param {*} value The value to process.
             * @returns {Object} Returns the object.
             */
            function toObject(value) {
              if (unindexedChars && isString(value)) {
                var index = -1,
                    length = value.length,
                    result = Object(value);

                while (++index < length) {
                  result[index] = value.charAt(index);
                }
                return result;
              }
              return isObject(value) ? value : Object(value);
            }

            function isObject(value) {
                  // Avoid a V8 JIT bug in Chrome 19-20.
                  // See https://code.google.com/p/v8/issues/detail?id=2291 for more details.
                  var type = typeof value;
                  return !!value && (type == 'object' || type == 'function');
            }




      /**
           * Converts `value` to property path array if it's not one.
           *
           * @private
           * @param {*} value The value to process.
           * @returns {Array} Returns the property path array.
           */
      function toPath(value) {
        if (isArray(value)) {
          return value;
        }
        var result = [];
        baseToString(value).replace(rePropName, function(match, number, quote, string) {
          result.push(quote ? string.replace(reEscapeChar, '$1') : (number || match));
        });
        return result;
      }

      /**
       * Converts `value` to a string if it's not one. An empty string is returned
       * for `null` or `undefined` values.
       *
       * @private
       * @param {*} value The value to process.
       * @returns {string} Returns the string.
       */
      function baseToString(value) {
        return value == null ? '' : (value + '');
      }

      property var reIsDeepProp  : /\.|\[(?:[^[\]]*|(["'])(?:(?!\1)[^\n\\]|\\.)*?\1)\]/
      property var reIsPlainProp : /^\w*$/
      property var rePropName    : /[^.[\]]+|\[(?:(-?\d+(?:\.\d+)?)|(["'])((?:(?!\2)[^\n\\]|\\.)*?)\2)\]/g
      property var reEscapeChar  : /\\(\\)?/g
      property var unindexedChars : ('x'[0] + Object('x')[0]) != 'xx';
      function isString(value) {
            return typeof value === 'string';
      }
      function isObjectLike(value) {
         return !!value && typeof value == 'object';
      }



}
