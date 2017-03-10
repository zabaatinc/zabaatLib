import QtQuick 2.5
import "lodash.js" as L

//r end = Moment.moment({month : endMonth, year : endYear})

pragma Singleton
QtObject {
    id : rootObject
    objectName : "Lodash.qml"

    //ARRAY
    function chunk				(array,opt_size)                    { return L._[arguments.callee.name].apply({},arguments)  }
    function compact            (array)                             { return L._[arguments.callee.name].apply({},arguments)  }
    function concat             (array,opt_values)                  { return L._[arguments.callee.name].apply({},arguments)  }
    function difference         (array,opt_values)                  { return L._[arguments.callee.name].apply({},arguments)  }
    function differenceBy       (array,opt_values,opt_iteratee)     { return L._[arguments.callee.name].apply({},arguments)  }
    function differenceWith     (array,opt_values,opt_comparator)   { return L._[arguments.callee.name].apply({},arguments)  }
    function drop               (array,opt_n)                       { return L._[arguments.callee.name].apply({},arguments)  }
    function dropRight          (array,opt_n)                       { return L._[arguments.callee.name].apply({},arguments)  }
    function dropRightWhile     (array,opt_predicate)               { return L._[arguments.callee.name].apply({},arguments)  }
    function dropWhile          (array,opt_predicate)               { return L._[arguments.callee.name].apply({},arguments)  }
    function fill               (array, value, opt_start, opt_end)  { return L._[arguments.callee.name].apply({},arguments)  }
    function findIndex          (array,predicate)            { return L._[arguments.callee.name].apply({},arguments)  }
    function findLastIndex      (array,predicate)            { return L._[arguments.callee.name].apply({},arguments)  }
    function first              (array)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function flatten            (array)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function flattenDeep        (array)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function flattenDepth       (array,opt_depth)            { return L._[arguments.callee.name].apply({},arguments)  }
    function fromPairs          (pairs)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function head               (array)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function indexOf            (array,value,opt_fromIndex)  { return L._[arguments.callee.name].apply({},arguments)  }
    function initial            (array)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function intersection       (args)                       { return L._[arguments.callee.name].apply({},arguments)  }
    function intersectionBy     (args,opt_iteratee)          { return L._[arguments.callee.name].apply({},arguments)  }
    function intersectionWith   (args,comparator)            { return L._[arguments.callee.name].apply({},arguments)  }
    function join               (array,separator)            { return L._[arguments.callee.name].apply({},arguments)  }
    function last               (array)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function lastIndexOf        (array,value,opt_fromIndex)  { return L._[arguments.callee.name].apply({},arguments)  }
    function nth                (array,opt_n)                { return L._[arguments.callee.name].apply({},arguments)  }
    function pull               (array,opt_values)           { return L._[arguments.callee.name].apply({},arguments)  }
    function pullAll            (array,values)               { return L._[arguments.callee.name].apply({},arguments)  }
    function pullAllBy          (array,values,opt_iteratee)  { return L._[arguments.callee.name].apply({},arguments)  }
    function pullAllWith        (array,values,comparator)    { return L._[arguments.callee.name].apply({},arguments)  }
    function pullAt             (array,opt_indexes)          { return L._[arguments.callee.name].apply({},arguments)  }
    function remove             (array,opt_predicate)        { return L._[arguments.callee.name].apply({},arguments)  }
    function reverse            (array)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function slice              (array,opt_start,opt_end)    { return L._[arguments.callee.name].apply({},arguments)  }
    function sortedIndex        (array,value)                { return L._[arguments.callee.name].apply({},arguments)  }
    function sortedIndexBy      (array,value,opt_iteratee)   { return L._[arguments.callee.name].apply({},arguments)  }
    function sortedIndexOf      (array,value)                { return L._[arguments.callee.name].apply({},arguments)  }
    function sortedLastIndex    (array,value)                { return L._[arguments.callee.name].apply({},arguments)  }
    function sortedLastIndexBy  (array,value,opt_iteratee)   { return L._[arguments.callee.name].apply({},arguments)  }
    function sortedLastIndexOf  (array,value)                { return L._[arguments.callee.name].apply({},arguments)  }
    function sortedUniq         (array)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function sortedUniqBy       (array,opt_iteratee)         { return L._[arguments.callee.name].apply({},arguments)  }
    function tail               (array)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function take               (array,opt_n)                { return L._[arguments.callee.name].apply({},arguments)  }
    function takeRight          (array,opt_n)                { return L._[arguments.callee.name].apply({},arguments)  }
    function takeRightWhile     (array,opt_predicate)        { return L._[arguments.callee.name].apply({},arguments)  }
    function takeWhile          (array,opt_predicate)        { return L._[arguments.callee.name].apply({},arguments)  }
    function union              (args)                       { return L._[arguments.callee.name].apply({},arguments)  }
    function unionBy            (args,opt_iteratee )         { return L._[arguments.callee.name].apply({},arguments)  }
    function unionWith          (args,opt_comparator)        { return L._[arguments.callee.name].apply({},arguments)  }
    function uniq               (array)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function uniqBy             (array,opt_iteratee)         { return L._[arguments.callee.name].apply({},arguments)  }
    function uniqWith           (array,opt_comparator)       { return L._[arguments.callee.name].apply({},arguments)  }
    function unzip              (array)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function unzipWith          (array,opt_comparator)       { return L._[arguments.callee.name].apply({},arguments)  }
    function without            (array)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function xor                (args)                       { return L._[arguments.callee.name].apply({},arguments)  }
    function xorBy              (args,opt_iteratee)          { return L._[arguments.callee.name].apply({},arguments)  }
    function xorWith            (args,opt_comparator)        { return L._[arguments.callee.name].apply({},arguments)  }
    function zip                (args)                       { return L._[arguments.callee.name].apply({},arguments)  }
    function zipObject          (props,values)               { return L._[arguments.callee.name].apply({},arguments)  }
    function zipObjectDeep      (props,values)               { return L._[arguments.callee.name].apply({},arguments)  }
    function zipWith            (args, opt_iteratee)         { return L._[arguments.callee.name].apply({},arguments)  }

    //COLLECTION
    function countBy            (collection,opt_iteratee)       { return L._[arguments.callee.name].apply({},arguments)  }
    function each               (collection,opt_iteratee)       { return L._[arguments.callee.name].apply({},arguments)  }
    function eachRight          (collection,opt_iteratee)       { return L._[arguments.callee.name].apply({},arguments)  }
    function every              (collection,opt_predicate)       { return L._[arguments.callee.name].apply({},arguments)  }
    function filter             (collection,opt_predicate)       { return L._[arguments.callee.name].apply({},arguments)  }
    function find               (collection,opt_predicate)       { return L._[arguments.callee.name].apply({},arguments)  }
    function findLast           (collection,opt_predicate)       { return L._[arguments.callee.name].apply({},arguments)  }
    function flatMap            (collection,opt_iteratee)       { return L._[arguments.callee.name].apply({},arguments)  }
    function flatMapDeep        (collection,opt_iteratee)       { return L._[arguments.callee.name].apply({},arguments)  }
    function flatMapDepth       (collection,opt_iteratee,opt_depth)       { return L._[arguments.callee.name].apply({},arguments)  }
    function forEach            (collection,opt_iteratee)       { return L._[arguments.callee.name].apply({},arguments)  }
    function forEachRight       (collection,opt_iteratee)       { return L._[arguments.callee.name].apply({},arguments)  }
    function groupBy            (collection,opt_iteratee)       { return L._[arguments.callee.name].apply({},arguments)  }
    function includes           (collection,value,opt_fromIndex){ return L._[arguments.callee.name].apply({},arguments)  }
    function invokeMap          (collection,path,args)       { return L._[arguments.callee.name].apply({},arguments)  }
    function keyBy              (collection,opt_iteratee)       { return L._[arguments.callee.name].apply({},arguments)  }
    function map                (collection,opt_iteratee)       { return L._[arguments.callee.name].apply({},arguments)  }
    function orderBy            (collection,opt_iteratee, opt_orders)       { return L._[arguments.callee.name].apply({},arguments)  }
    function partition          (collection,opt_iteratee)       { return L._[arguments.callee.name].apply({},arguments)  }
    function reduce             (collection,opt_iteratee, opt_accumulator)       { return L._[arguments.callee.name].apply({},arguments)  }
    function reduceRight        (collection,opt_iteratee, opt_accumulator)       { return L._[arguments.callee.name].apply({},arguments)  }
    function reject             (collection,opt_iteratee)       { return L._[arguments.callee.name].apply({},arguments)  }
    function sample             (collection)       { return L._[arguments.callee.name].apply({},arguments)  }
    function sampleSize         (collection,opt_n)       { return L._[arguments.callee.name].apply({},arguments)  }
    function shuffle            (collection)       { return L._[arguments.callee.name].apply({},arguments)  }
    function size               (collection)       { return L._[arguments.callee.name].apply({},arguments)  }
    function some               (collection,opt_iteratee)       { return L._[arguments.callee.name].apply({},arguments)  }
    function sortBy             (collection,opt_iteratees)       { return L._[arguments.callee.name].apply({},arguments)  }

    //Date
    function now                ()                      { return L._[arguments.callee.name].apply({},arguments)  }

    //Function
    function after              (n,func)                { return L._[arguments.callee.name].apply({},arguments)  }
    function ary                (n,opt_func)            { return L._[arguments.callee.name].apply({},arguments)  }
    function before             (n,func)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function bind               (func,thisArg,opt_partials)   { return L._[arguments.callee.name].apply({},arguments)  }
    function bindKey            (object,key,opt_partials)     { return L._[arguments.callee.name].apply({},arguments)  }
    function curry              (func,opt_arity)        { return L._[arguments.callee.name].apply({},arguments)  }
    function curryRight         (func,opt_arity)        { return L._[arguments.callee.name].apply({},arguments)  }
    function debounce           (func,opt_options)      { return L._[arguments.callee.name].apply({},arguments)  }
    function defer              (func,opt_args)         { return L._[arguments.callee.name].apply({},arguments)  }
    function delay              (func,wait,opt_args)    { return L._[arguments.callee.name].apply({},arguments)  }
    function flip               (func)                  { return L._[arguments.callee.name].apply({},arguments)  }
    function memoize            (func,opt_resolver)     { return L._[arguments.callee.name].apply({},arguments)  }
    function negate             (predicate)             { return L._[arguments.callee.name].apply({},arguments)  }
    function once               (func)                  { return L._[arguments.callee.name].apply({},arguments)  }
    function overArgs           (func)                  { return L._[arguments.callee.name].apply({},arguments)  }
    function partial            (func,opt_partials)     { return L._[arguments.callee.name].apply({},arguments)  }
    function partialRight       (func,opt_partials)     { return L._[arguments.callee.name].apply({},arguments)  }
    function rearg              (func,indexes)          { return L._[arguments.callee.name].apply({},arguments)  }
    function rest               (func,opt_start)        { return L._[arguments.callee.name].apply({},arguments)  }
    function spread             (func,opt_start)        { return L._[arguments.callee.name].apply({},arguments)  }
    function throttle           (func, opt_options)     { return L._[arguments.callee.name].apply({},arguments)  }
    function unary              (func)                  { return L._[arguments.callee.name].apply({},arguments)  }
    function wrap               (value,opt_identity)    { return L._[arguments.callee.name].apply({},arguments)  }

    //LANG
    function castArray          (value)                 { return L._[arguments.callee.name].apply({},arguments)  }
    function clone              (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function cloneDeep          (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function cloneDeepWith      (value,opt_customizer)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function cloneWith          (value,opt_customizer)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function eq                 (value,other)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function gt                 (value,other)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function gte                (value,other)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isArguments        (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isArray            (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isArrayBuffer      (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isArrayLike        (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isArrayLikeObject  (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isBoolean          (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isBuffer           (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isDate             (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isElement          (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isEmpty            (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isEqual            (value,other)                { return L._[arguments.callee.name].apply({},arguments)  }
    function isEqualWith        (value,other,opt_customizer) { return L._[arguments.callee.name].apply({},arguments)  }
    function isError            (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function _isFinite          (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isFunction         (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isInteger          (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isLength           (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isMap              (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isMatch            (object,source)              { return L._[arguments.callee.name].apply({},arguments)  }
    function isMatchWith        (object,source,opt_customizer)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function _isNaN             (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isNative           (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isNil              (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isNull             (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isNumber           (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isObject           (value)                      { return toString.call(value) === '[object Object]';  }    //idiot lodash! Unintuitive name!!
    function isObjectLike       (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isPlainObject      (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isRegExp           (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isSafeInteger      (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isSet              (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isString           (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isSymbol           (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isTypedArray       (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isUndefined        (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isWeakMap          (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function isWeakSet          (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function lt                 (value,other)                { return L._[arguments.callee.name].apply({},arguments)  }
    function lte                (value,other)                { return L._[arguments.callee.name].apply({},arguments)  }
    function toArray            (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function toInteger          (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function toLength           (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function toNumber           (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function toPlainObject      (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function toSafeInteger      (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function toString           (value)                      { return L._[arguments.callee.name].apply({},arguments)  }

    //Math
    function add                (augend,addend)         { return L._[arguments.callee.name].apply({},arguments)  }
    function ceil               (number,opt_precision)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function divide             (dividend,divisor)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function floor              (number,opt_precision)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function max                (array)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function maxBy              (array,opt_iteratee)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function mean               (array)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function meanBy             (array,opt_iteratee)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function min                (array)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function minBy              (array,opt_iteratee)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function multiply           (multiplier,multiplicand)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function round              (number,opt_precision)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function subtract           (minuend,subtrahend)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function sum                (array)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function sumBy              (array,opt_iteratee)                      { return L._[arguments.callee.name].apply({},arguments)  }

    //NUMBER
    function clamp              (number,opt_lower,upper)             { return L._[arguments.callee.name].apply({},arguments)  }
    function inRange            (number,opt_start,end)               { return L._[arguments.callee.name].apply({},arguments)  }
    function random             (opt_lower,opt_upper,opt_floating)   { return L._[arguments.callee.name].apply({},arguments)  }

    //OBJECT                                            { ret
    function assign             (object,opt_sources)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function assignIn           (object,opt_sources)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function assignInWith       (object,sources,opt_customizer)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function assignWith         (object,sources,opt_customizer)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function at                 (object,paths)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function create             (prototype,opt_properties)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function defaults           (object,opt_sources)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function defaultsDeep       (object,opt_sources)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function entries            (object)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function entriesIn          (object)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function extend             (object,opt_sources)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function extendWith         (object,sources,opt_customizer)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function findKey            (object,opt_predicate)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function findLastKey        (object,opt_predicate)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function forIn              (object,opt_iteratee)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function forInRight         (object,opt_iteratee)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function forOwn             (object,opt_iteratee)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function forOwnRight        (object,opt_iteratee)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function functions          (object)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function functionsIn        (object)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function get                (object,path,opt_defaultValue)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function has                (object,path)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function hasIn              (object,path)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function invert             (object)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function invertBy           (object,opt_iteratee)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function invoke             (object,path,opt_args)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function keys               (object)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function keysIn             (object)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function mapKeys            (object,opt_iteratee)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function mapValues          (object,opt_iteratee)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function merge              (object,opt_sources)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function mergeWith          (object,sources,customizer)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function omit               (object,opt_props)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function omitBy             (object,opt_predicate)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function pick               (object,opt_props)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function pickBy             (object,opt_predicate)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function result             (object,path,opt_defaultValue)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function set                (object,path,value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function setWith            (object,path,value,opt_customizer)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function toPairs            (object)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function toPairsIn          (object)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function transform          (object,opt_iteratee, opt_accumulator)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function unset              (object,path)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function update             (object,path,updater)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function updateWith         (object,path,updater,opt_customizer)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function values             (object)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function valuesIn           (object)                      { return L._[arguments.callee.name].apply({},arguments)  }

    //SEQ                                               { ret
//    function prototype_chain              ()            { return L._["chain"].apply({},arguments)  }
//    function prototype_tap                ()            { return L._["tap"].apply({},arguments)  }
//    function prototype_thru               ()            { return L._["thru"].apply({},arguments)  }
//    function prototype_iterator           ()            { return L._["iterator"].apply({},arguments)  }
//    function prototype_at                 ()            { return L._["at"].apply({},arguments)  }
//    function prototype_chain              ()            { return L._["chain"].apply({},arguments)  }
//    function prototype_commit             ()            { return L._["commit"].apply({},arguments)  }
//    function prototype_next               ()            { return L._["next"].apply({},arguments)  }
//    function prototype_plant              ()            { return L._["plant"].apply({},arguments)  }
//    function prototype_reverse            ()            { return L._["reverse"].apply({},arguments)  }
//    function prototype_toJSON             ()            { return L._["toJSON"].apply({},arguments)  }
//    function prototype_value              ()            { return L._["value"].apply({},arguments)  }
//    function prototype_valueOf            ()            { return L._["valueOf"].apply({},arguments)  }

    //STRING                                            { ret
    function camelCase          (string)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function capitalize         (string)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function deburr             (string)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function endsWith           (string,opt_target,opt_position)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function _escape            (string)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function escapeRegExp       (string)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function kebabCase          (string)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function lowerCase          (string)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function lowerFirst         (string)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function pad                (string,opt_length,opt_chars)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function padEnd             (string,opt_length,opt_chars)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function padStart           (string,opt_length,opt_chars)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function _parseInt          (string,opt_radix)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function repeat             (string,opt_n)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function replace            (string,pattern,replacement)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function snakeCase          (string)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function split              (string,separator,opt_limit)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function startCase          (string)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function startsWith         (string,opt_target,opt_position)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function template           (string, options)    { return L._[arguments.callee.name].apply({},arguments)  }
    function toLower            (string)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function toUpper            (string)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function trim               (string,opt_chars)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function trimEnd            (string,opt_chars)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function trimStart          (string,opt_chars)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function truncate           (string,options)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function _unescape          (string,options)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function upperCase          (string)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function upperFirst         (string)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function words              (string,pattern)                      { return L._[arguments.callee.name].apply({},arguments)  }

    //UTIL                                              { ret
    function attempt            (func,opt_args)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function bindAll            (object,methodNames)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function cond               (pairs)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function conforms           (source)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function constant           (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function flow               (funcs)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function flowRight          (funcs)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function identity           (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function iteratee           (opt_func)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function matches            (source)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function matchesProperty    (path,srcValue)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function method             (path,opt_args)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function methodOf           (object,opt_args)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function mixin              (opt_lodash,source,opt_options)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function noConflict         ()                      { return L._[arguments.callee.name].apply({},arguments)  }
    function noop               ()                      { return L._[arguments.callee.name].apply({},arguments)  }
    function nthArg             (opt_n)                 { return L._[arguments.callee.name].apply({},arguments)  }
    function over               (opt_iteratee)          { return L._[arguments.callee.name].apply({},arguments)  }
    function overEvery          (opt_predicates)        { return L._[arguments.callee.name].apply({},arguments)  }
    function overSome           (opt_predicates)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function property           (path)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function propertyOf         (object)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function range              (opt_start,end,opt_step)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function rangeRight         (opt_start,end,opt_step)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function runInContext       (opt_context)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function times              (n,opt_iteratee)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function toPath             (value)                      { return L._[arguments.callee.name].apply({},arguments)  }
    function uniqueId           (prefix)                      { return L._[arguments.callee.name].apply({},arguments)  }




}
