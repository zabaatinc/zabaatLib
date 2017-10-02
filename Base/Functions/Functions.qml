import QtQuick 2.0
pragma Singleton
QtObject {
    property MathFunctions   math   : MathFunctions   {}
    property StringFunctions string : StringFunctions {}
    property LogicFunctions  logic  : LogicFunctions  {}
    property TimeFunctions   time   : TimeFunctions   {}
    property ObjectFunctions object : ObjectFunctions {}
    property FileFunctions   file   : FileFunctions   {}
    property ListFunctions   list   : ListFunctions   {}
    property XHRFunctions    xhr    : XHRFunctions    {}
    property QMLFunctions    qml    : QMLFunctions    {}
    property LogStorage      logs   : LogStorage      {}

    property bool storeLogs     : false
    property bool storeWarnings : false
    property bool storeErrors   : false

    function copyToClipboard(text){
        textedit.text = text;
        textedit.selectAll()
        textedit.copy()
        textedit.text = ""
    }

    function log(){
        var args        = Array.prototype.slice.call(arguments);
        var fileAndLine = string.currentFileAndLineNum(2)
        var arr = [fileAndLine].concat(args);
        console.log.apply({},arr);
        if(storeLogs) {
            logs.add("log", fileAndLine, args.join(" "));
        }
    }

    function warning() {
        var args        = Array.prototype.slice.call(arguments);
        var fileAndLine = string.currentFileAndLineNum(2)
        var arr = [fileAndLine].concat(args);
        console.warn.apply({},arr);
        if(storeWarnings) {
            logs.add("warning", fileAndLine, args.join(" "));
        }
    }

    function error() {
        var args        = Array.prototype.slice.call(arguments);
        var fileAndLine = string.currentFileAndLineNum(2)
        var arr = [fileAndLine].concat(args);
        console.error.apply({},arr);
        if(storeErrors) {
            logs.add("error", fileAndLine, args.join(" "));
        }
    }




    function logJs() {
        var params    = Array.prototype.slice.call(arguments);
        var outparams = [];
        for(var p in params) {
            var param = params[p]
            if(typeof param === 'object') {
                try {
                    outparams.push(JSON.stringify(param,null,2))
                }catch(e) {
                    outparams.push(toString.call(param));
                }
            }
            else
                outparams.push(toString.call(param));
        }
        var fileAndLine = string.currentFileAndLineNum(2)
        var arr = [fileAndLine].concat(outparams);
        console.log.apply({},arr);
        if(storeLogs) {
            logs.add("log", fileAndLine, outparams.join(" "));
        }
    }

    //Generates & returns a new function that calls fn with arguments provided here.
    function generate(fn) {
        var args = Array.prototype.slice.call(arguments,1);
        //"this" from when generate() starts is likely to be long dead when this new function is called.
        //so we create an empty object as the "this" parameter for the apply call.
        return function() {
            return fn.apply({},args);
        }
    }

    function connectOnce(sig, fn) {
        return connectUntil(sig,fn, function() { return false })
    }

    function connectUntilTruthy(sig, fn) {
        if(typeof sig !== 'function' || typeof fn !== 'function')
            return;

        var connector = function() {
            var args = Array.prototype.slice.call(arguments);
            if(fn.apply({},args))
                sig.disconnect(connector);
        }

        try { sig.connect(connector) } catch(e) { console.error(e) }
    }

    function connectUntil(sig, fn, untilFn) {
        if(typeof sig !== 'function' || typeof fn !== 'function' || typeof untilFn !== 'function') {
            return;
        }

        var connector = function() {
            var args = Array.prototype.slice.call(arguments);

            fn.apply({},args);
            if(!untilFn.apply({},args))
                sig.disconnect(connector);
        }

        try {
            sig.connect(connector);
        } catch(e) {
            console.error(e);
        }
    }

    function chainableFunctionFactory() {
        var args = Array.prototype.slice.call(arguments);

        function cleanup(arr) {
            var seenBefore = {}
            for(var i = arr.length-1; i >= 0; i--){
                var v = arr[i];
                if(!v)
                    continue;

                if(typeof v !== 'object') {

                    var key = v.toString();
                    if(seenBefore[key]) {
                        arr.splice(i,1);
                        continue;
                    }

                    arr[i] = key;
                    seenBefore[key] = true;
                    continue;
                }

                //otherwise, it is an object. we must remove it before proceeding!
                if(toString.call(v) === '[object Array]') {
                    v.forEach(function(vin) {
                        var type = typeof vin
                        if(type === 'string' || type === 'number') {
                            var key = vin.toString();
                            if(!seenBefore[key]) {
                                arr.push(key);
                                seenBefore[key] = true;
                            }
                        }
                    })
                }
                arr.splice(i,1);
            }
        }


        function capitalizeFirst(str) {
            return str.charAt(0).toUpperCase() + str.slice(1)
        }

        var obj = { _fnStore : {} }

        cleanup(args);
        args.forEach(function(v) {
            v = v.toString();

            var onName = "on" + capitalizeFirst(v);
            obj[onName] = function(fn) {
                var myName = v;
                if(typeof fn === 'function')
                    obj._fnStore[myName] = fn;
                return obj;
            }

            obj[v] = function() {
                var myName = v;
                var fn = obj._fnStore[myName];
                if(typeof fn === 'function')
                    return fn.apply({},Array.prototype.slice.call(arguments));
            }

        })
        return obj;
    }

    function chainableFunctionFactory_nonenumerable() {
        var args = Array.prototype.slice.call(arguments);

        function cleanup(arr) {
            var seenBefore = {}
            for(var i = arr.length-1; i >= 0; i--){
                var v = arr[i];
                if(!v)
                    continue;

                if(typeof v !== 'object') {

                    var key = v.toString();
                    if(seenBefore[key]) {
                        arr.splice(i,1);
                        continue;
                    }

                    arr[i] = key;
                    seenBefore[key] = true;
                    continue;
                }

                //otherwise, it is an object. we must remove it before proceeding!
                if(toString.call(v) === '[object Array]') {
                    v.forEach(function(vin) {
                        var type = typeof vin
                        if(type === 'string' || type === 'number') {
                            var key = vin.toString();
                            if(!seenBefore[key]) {
                                arr.push(key);
                                seenBefore[key] = true;
                            }
                        }
                    })
                }
                arr.splice(i,1);
            }
        }

        function capitalizeFirst(str) {
            return str.charAt(0).toUpperCase() + str.slice(1)
        }

        function nonenumerableDescriptor(val) {
            return { configurable : false, enumerable : false, value : val }
        }


        var obj = {}
        Object.defineProperty(obj,"_fnStore", nonenumerableDescriptor({}))

        cleanup(args);
        args.forEach(function(v) {
            v = v.toString();

            var onName = "on" + capitalizeFirst(v);
            var onFn   = function(fn) {
                var myName = v;
                if(typeof fn === 'function')
                    obj._fnStore[myName] = fn;
                return obj;
            }
            var fn     = function() {
                var myName = v;
                var fn = obj._fnStore[myName];
                if(typeof fn === 'function')
                    return fn.apply({},Array.prototype.slice.call(arguments));
            }

            Object.defineProperty(obj,onName,nonenumerableDescriptor(onFn));
            Object.defineProperty(obj,v,nonenumerableDescriptor(fn))
        })
        return obj;
    }

    property Item __private__ : Item{
        TextEdit { id : textedit }
    }



}
