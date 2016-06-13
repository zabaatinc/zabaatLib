import QtQuick 2.5
import "lodash.js" as L

//r end = Moment.moment({month : endMonth, year : endYear})

pragma Singleton
QtObject {
    id : rootObject
    objectName : "Lodash.qml"

    //ARRAY
    function chunk				(array,opt_size)                    { return L._[arguments.callee.name].apply(this,arguments)  }
    function compact            (array)                             { return L._[arguments.callee.name].apply(this,arguments)  }
    function concat             (array,opt_values)                  { return L._[arguments.callee.name].apply(this,arguments)  }
    function difference         (array,opt_values)                  { return L._[arguments.callee.name].apply(this,arguments)  }
    function differenceBy       (array,opt_values,opt_iteratee)     { return L._[arguments.callee.name].apply(this,arguments)  }
    function differenceWith     (array,opt_values,opt_comparator)   { return L._[arguments.callee.name].apply(this,arguments)  }
    function drop               (array,opt_n)                       { return L._[arguments.callee.name].apply(this,arguments)  }
    function dropRight          (array,opt_n)                       { return L._[arguments.callee.name].apply(this,arguments)  }
    function dropRightWhile     (array,opt_predicate)               { return L._[arguments.callee.name].apply(this,arguments)  }
    function dropWhile          (array,opt_predicate)               { return L._[arguments.callee.name].apply(this,arguments)  }
    function fill               (array, value, opt_start, opt_end)  { return L._[arguments.callee.name].apply(this,arguments)  }
    function findIndex          (array,predicate)            { return L._[arguments.callee.name].apply(this,arguments)  }
    function findLastIndex      (array,predicate)            { return L._[arguments.callee.name].apply(this,arguments)  }
    function first              (array)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function flatten            (array)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function flattenDeep        (array)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function flattenDepth       (array,opt_depth)            { return L._[arguments.callee.name].apply(this,arguments)  }
    function fromPairs          (pairs)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function head               (array)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function indexOf            (array,value,opt_fromIndex)  { return L._[arguments.callee.name].apply(this,arguments)  }
    function initial            (array)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function intersection       (args)                       { return L._[arguments.callee.name].apply(this,arguments)  }
    function intersectionBy     (args,opt_iteratee)          { return L._[arguments.callee.name].apply(this,arguments)  }
    function intersectionWith   (args,comparator)            { return L._[arguments.callee.name].apply(this,arguments)  }
    function join               (array,separator)            { return L._[arguments.callee.name].apply(this,arguments)  }
    function last               (array)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function lastIndexOf        (array,value,opt_fromIndex)  { return L._[arguments.callee.name].apply(this,arguments)  }
    function nth                (array,opt_n)                { return L._[arguments.callee.name].apply(this,arguments)  }
    function pull               (array,opt_values)           { return L._[arguments.callee.name].apply(this,arguments)  }
    function pullAll            (array,values)               { return L._[arguments.callee.name].apply(this,arguments)  }
    function pullAllBy          (array,values,opt_iteratee)  { return L._[arguments.callee.name].apply(this,arguments)  }
    function pullAllWith        (array,values,comparator)    { return L._[arguments.callee.name].apply(this,arguments)  }
    function pullAt             (array,opt_indexes)          { return L._[arguments.callee.name].apply(this,arguments)  }
    function remove             (array,opt_predicate)        { return L._[arguments.callee.name].apply(this,arguments)  }
    function reverse            (array)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function slice              (array,opt_start,opt_end)    { return L._[arguments.callee.name].apply(this,arguments)  }
    function sortedIndex        (array,value)                { return L._[arguments.callee.name].apply(this,arguments)  }
    function sortedIndexBy      (array,value,opt_iteratee)   { return L._[arguments.callee.name].apply(this,arguments)  }
    function sortedIndexOf      (array,value)                { return L._[arguments.callee.name].apply(this,arguments)  }
    function sortedLastIndex    (array,value)                { return L._[arguments.callee.name].apply(this,arguments)  }
    function sortedLastIndexBy  (array,value,opt_iteratee)   { return L._[arguments.callee.name].apply(this,arguments)  }
    function sortedLastIndexOf  (array,value)                { return L._[arguments.callee.name].apply(this,arguments)  }
    function sortedUniq         (array)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function sortedUniqBy       (array,opt_iteratee)         { return L._[arguments.callee.name].apply(this,arguments)  }
    function tail               (array)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function take               (array,opt_n)                { return L._[arguments.callee.name].apply(this,arguments)  }
    function takeRight          (array,opt_n)                { return L._[arguments.callee.name].apply(this,arguments)  }
    function takeRightWhile     (array,opt_predicate)        { return L._[arguments.callee.name].apply(this,arguments)  }
    function takeWhile          (array,opt_predicate)        { return L._[arguments.callee.name].apply(this,arguments)  }
    function union              (args)                       { return L._[arguments.callee.name].apply(this,arguments)  }
    function unionBy            (args,opt_iteratee )         { return L._[arguments.callee.name].apply(this,arguments)  }
    function unionWith          (args,opt_comparator)        { return L._[arguments.callee.name].apply(this,arguments)  }
    function uniq               (array)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function uniqBy             (array,opt_iteratee)         { return L._[arguments.callee.name].apply(this,arguments)  }
    function uniqWith           (array,opt_comparator)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function unzip              (array)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function unzipWith          (array,opt_comparator)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function without            (array)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function xor                (args)                       { return L._[arguments.callee.name].apply(this,arguments)  }
    function xorBy              (args,opt_iteratee)          { return L._[arguments.callee.name].apply(this,arguments)  }
    function xorWith            (args,opt_comparator)        { return L._[arguments.callee.name].apply(this,arguments)  }
    function zip                (args)                       { return L._[arguments.callee.name].apply(this,arguments)  }
    function zipObject          (props,values)               { return L._[arguments.callee.name].apply(this,arguments)  }
    function zipObjectDeep      (props,values)               { return L._[arguments.callee.name].apply(this,arguments)  }
    function zipWith            (args, opt_iteratee)         { return L._[arguments.callee.name].apply(this,arguments)  }

    //COLLECTION
    function countBy            (collection,opt_iteratee)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function each               (collection,opt_iteratee)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function eachRight          (collection,opt_iteratee)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function every              (collection,opt_predicate)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function filter             (collection,opt_predicate)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function find               (collection,opt_predicate)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function findLast           (collection,opt_predicate)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function flatMap            (collection,opt_iteratee)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function flatMapDeep        (collection,opt_iteratee)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function flatMapDepth       (collection,opt_iteratee,opt_depth)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function forEach            (collection,opt_iteratee)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function forEachRight       (collection,opt_iteratee)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function groupBy            (collection,opt_iteratee)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function includes           (collection,value,opt_fromIndex){ return L._[arguments.callee.name].apply(this,arguments)  }
    function invokeMap          (collection,path,args)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function keyBy              (collection,opt_iteratee)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function map                (collection,opt_iteratee)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function orderBy            (collection,opt_iteratee, opt_orders)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function partition          (collection,opt_iteratee)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function reduce             (collection,opt_iteratee, opt_accumulator)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function reduceRight        (collection,opt_iteratee, opt_accumulator)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function reject             (collection,opt_iteratee)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function sample             (collection)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function sampleSize         (collection,opt_n)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function shuffle            (collection)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function size               (collection)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function some               (collection,opt_iteratee)       { return L._[arguments.callee.name].apply(this,arguments)  }
    function sortBy             (collection,opt_iteratees)       { return L._[arguments.callee.name].apply(this,arguments)  }

    //Date
    function now                ()                      { return L._[arguments.callee.name].apply(this,arguments)  }

    //Function
    function after              (n,func)                { return L._[arguments.callee.name].apply(this,arguments)  }
    function ary                (n,opt_func)            { return L._[arguments.callee.name].apply(this,arguments)  }
    function before             (n,func)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function bind               (func,thisArg,opt_partials)   { return L._[arguments.callee.name].apply(this,arguments)  }
    function bindKey            (object,key,opt_partials)     { return L._[arguments.callee.name].apply(this,arguments)  }
    function curry              (func,opt_arity)        { return L._[arguments.callee.name].apply(this,arguments)  }
    function curryRight         (func,opt_arity)        { return L._[arguments.callee.name].apply(this,arguments)  }
    function debounce           (func,opt_options)      { return L._[arguments.callee.name].apply(this,arguments)  }
    function defer              (func,opt_args)         { return L._[arguments.callee.name].apply(this,arguments)  }
    function delay              (func,wait,opt_args)    { return L._[arguments.callee.name].apply(this,arguments)  }
    function flip               (func)                  { return L._[arguments.callee.name].apply(this,arguments)  }
    function memoize            (func,opt_resolver)     { return L._[arguments.callee.name].apply(this,arguments)  }
    function negate             (predicate)             { return L._[arguments.callee.name].apply(this,arguments)  }
    function once               (func)                  { return L._[arguments.callee.name].apply(this,arguments)  }
    function overArgs           (func)                  { return L._[arguments.callee.name].apply(this,arguments)  }
    function partial            (func,opt_partials)     { return L._[arguments.callee.name].apply(this,arguments)  }
    function partialRight       (func,opt_partials)     { return L._[arguments.callee.name].apply(this,arguments)  }
    function rearg              (func,indexes)          { return L._[arguments.callee.name].apply(this,arguments)  }
    function rest               (func,opt_start)        { return L._[arguments.callee.name].apply(this,arguments)  }
    function spread             (func,opt_start)        { return L._[arguments.callee.name].apply(this,arguments)  }
    function throttle           (func, opt_options)     { return L._[arguments.callee.name].apply(this,arguments)  }
    function unary              (func)                  { return L._[arguments.callee.name].apply(this,arguments)  }
    function wrap               (value,opt_identity)    { return L._[arguments.callee.name].apply(this,arguments)  }

    //LANG
    function castArray          (value)                 { return L._[arguments.callee.name].apply(this,arguments)  }
    function clone              (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function cloneDeep          (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function cloneDeepWith      (value,opt_customizer)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function cloneWith          (value,opt_customizer)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function eq                 (value,other)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function gt                 (value,other)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function gte                (value,other)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isArguments        (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isArray            (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isArrayBuffer      (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isArrayLike        (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isArrayLikeObject  (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isBoolean          (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isBuffer           (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isDate             (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isElement          (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isEmpty            (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isEqual            (value,other)                { return L._[arguments.callee.name].apply(this,arguments)  }
    function isEqualWith        (value,other,opt_customizer) { return L._[arguments.callee.name].apply(this,arguments)  }
    function isError            (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function _isFinite          (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isFunction         (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isInteger          (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isLength           (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isMap              (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isMatch            (object,source)              { return L._[arguments.callee.name].apply(this,arguments)  }
    function isMatchWith        (object,source,opt_customizer)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function _isNaN             (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isNative           (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isNil              (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isNull             (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isNumber           (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isObject           (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isObjectLike       (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isPlainObject      (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isRegExp           (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isSafeInteger      (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isSet              (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isString           (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isSymbol           (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isTypedArray       (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isUndefined        (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isWeakMap          (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function isWeakSet          (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function lt                 (value,other)                { return L._[arguments.callee.name].apply(this,arguments)  }
    function lte                (value,other)                { return L._[arguments.callee.name].apply(this,arguments)  }
    function toArray            (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function toInteger          (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function toLength           (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function toNumber           (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function toPlainObject      (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function toSafeInteger      (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function toString           (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }

    //Math
    function add                (augend,addend)         { return L._[arguments.callee.name].apply(this,arguments)  }
    function ceil               (number,opt_precision)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function divide             (dividend,divisor)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function floor              (number,opt_precision)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function max                (array)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function maxBy              (array,opt_iteratee)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function mean               (array)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function meanBy             (array,opt_iteratee)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function min                (array)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function minBy              (array,opt_iteratee)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function multiply           (multiplier,multiplicand)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function round              (number,opt_precision)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function subtract           (minuend,subtrahend)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function sum                (array)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function sumBy              (array,opt_iteratee)                      { return L._[arguments.callee.name].apply(this,arguments)  }

    //NUMBER
    function clamp              (number,opt_lower,upper)             { return L._[arguments.callee.name].apply(this,arguments)  }
    function inRange            (number,opt_start,end)               { return L._[arguments.callee.name].apply(this,arguments)  }
    function random             (opt_lower,opt_upper,opt_floating)   { return L._[arguments.callee.name].apply(this,arguments)  }

    //OBJECT                                            { ret
    function assign             (object,opt_sources)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function assignIn           (object,opt_sources)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function assignInWith       (object,sources,opt_customizer)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function assignWith         (object,sources,opt_customizer)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function at                 (object,paths)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function create             (prototype,opt_properties)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function defaults           (object,opt_sources)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function defaultsDeep       (object,opt_sources)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function entries            (object)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function entriesIn          (object)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function extend             (object,opt_sources)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function extendWith         (object,sources,opt_customizer)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function findKey            (object,opt_predicate)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function findLastKey        (object,opt_predicate)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function forIn              (object,opt_iteratee)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function forInRight         (object,opt_iteratee)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function forOwn             (object,opt_iteratee)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function forOwnRight        (object,opt_iteratee)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function functions          (object)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function functionsIn        (object)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function get                (object,path,opt_defaultValue)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function has                (object,path)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function hasIn              (object,path)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function invert             (object)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function invertBy           (object,opt_iteratee)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function invoke             (object,path,opt_args)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function keys               (object)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function keysIn             (object)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function mapKeys            (object,opt_iteratee)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function mapValues          (object,opt_iteratee)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function merge              (object,opt_sources)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function mergeWith          (object,sources,customizer)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function omit               (object,opt_props)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function omitBy             (object,opt_predicate)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function pick               (object,opt_props)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function pickBy             (object,opt_predicate)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function result             (object,path,opt_defaultValue)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function set                (object,path,value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function setWith            (object,path,value,opt_customizer)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function toPairs            (object)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function toPairsIn          (object)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function transform          (object,opt_iteratee, opt_accumulator)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function unset              (object,path)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function update             (object,path,updater)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function updateWith         (object,path,updater,opt_customizer)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function values             (object)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function valuesIn           (object)                      { return L._[arguments.callee.name].apply(this,arguments)  }

    //SEQ                                               { ret
//    function prototype_chain              ()            { return L._["chain"].apply(this,arguments)  }
//    function prototype_tap                ()            { return L._["tap"].apply(this,arguments)  }
//    function prototype_thru               ()            { return L._["thru"].apply(this,arguments)  }
//    function prototype_iterator           ()            { return L._["iterator"].apply(this,arguments)  }
//    function prototype_at                 ()            { return L._["at"].apply(this,arguments)  }
//    function prototype_chain              ()            { return L._["chain"].apply(this,arguments)  }
//    function prototype_commit             ()            { return L._["commit"].apply(this,arguments)  }
//    function prototype_next               ()            { return L._["next"].apply(this,arguments)  }
//    function prototype_plant              ()            { return L._["plant"].apply(this,arguments)  }
//    function prototype_reverse            ()            { return L._["reverse"].apply(this,arguments)  }
//    function prototype_toJSON             ()            { return L._["toJSON"].apply(this,arguments)  }
//    function prototype_value              ()            { return L._["value"].apply(this,arguments)  }
//    function prototype_valueOf            ()            { return L._["valueOf"].apply(this,arguments)  }

    //STRING                                            { ret
    function camelCase          (string)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function capitalize         (string)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function deburr             (string)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function endsWith           (string,opt_target,opt_position)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function _escape            (string)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function escapeRegExp       (string)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function kebabCase          (string)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function lowerCase          (string)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function lowerFirst         (string)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function pad                (string,opt_length,opt_chars)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function padEnd             (string,opt_length,opt_chars)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function padStart           (string,opt_length,opt_chars)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function _parseInt          (string,opt_radix)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function repeat             (string,opt_n)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function replace            (string,pattern,replacement)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function snakeCase          (string)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function split              (string,separator,opt_limit)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function startCase          (string)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function startsWith         (string,opt_target,opt_position)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function template           (string, options)    { return L._[arguments.callee.name].apply(this,arguments)  }
    function toLower            (string)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function toUpper            (string)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function trim               (string,opt_chars)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function trimEnd            (string,opt_chars)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function trimStart          (string,opt_chars)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function truncate           (string,options)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function _unescape          (string,options)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function upperCase          (string)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function upperFirst         (string)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function words              (string,pattern)                      { return L._[arguments.callee.name].apply(this,arguments)  }

    //UTIL                                              { ret
    function attempt            (func,opt_args)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function bindAll            (object,methodNames)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function cond               (pairs)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function conforms           (source)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function constant           (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function flow               (funcs)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function flowRight          (funcs)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function identity           (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function iteratee           (opt_func)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function matches            (source)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function matchesProperty    (path,srcValue)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function method             (path,opt_args)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function methodOf           (object,opt_args)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function mixin              (opt_lodash,source,opt_options)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function noConflict         ()                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function noop               ()                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function nthArg             (opt_n)                 { return L._[arguments.callee.name].apply(this,arguments)  }
    function over               (opt_iteratee)          { return L._[arguments.callee.name].apply(this,arguments)  }
    function overEvery          (opt_predicates)        { return L._[arguments.callee.name].apply(this,arguments)  }
    function overSome           (opt_predicates)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function property           (path)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function propertyOf         (object)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function range              (opt_start,end,opt_step)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function rangeRight         (opt_start,end,opt_step)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function runInContext       (opt_context)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function times              (n,opt_iteratee)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function toPath             (value)                      { return L._[arguments.callee.name].apply(this,arguments)  }
    function uniqueId           (prefix)                      { return L._[arguments.callee.name].apply(this,arguments)  }




}
