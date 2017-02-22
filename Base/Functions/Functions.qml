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

    function copyToClipboard(text){
        textedit.text = text;
        textedit.selectAll()
        textedit.copy()
        textedit.text = ""
    }

    function log(){
        var arr = [string.currentFileAndLineNum(2)].concat(Array.prototype.slice.call(arguments));
        console.log.apply(this,arr);
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

        var arr = [string.currentFileAndLineNum(2)].concat(outparams);
        console.log.apply(this,arr);
    }

    //Generates & returns a new function that calls fn with arguments provided here.
    function generate(fn) {
        var args = Array.prototype.slice.call(arguments);
        if(args.length > 0) //so we dont call fn(fn,argA,argB...), we want fn(argA,argB,...);
            args.splice(0,1);

        return function() {
            return fn.apply(this,args);
        }
    }

    function connectOnce(sig, fn) {
        return connectUntil(sig,fn, function() { return false })
    }

    function connectUntilTruthy(sig, fn, msg) {
        if(typeof sig !== 'function' || typeof fn !== 'function')
            return;

        var connector = function() {
            var args = Array.prototype.slice.call(arguments);
            if(fn.apply(this,args))
                sig.disconnect(connector);
        }

        try { sig.connect(connector) } catch(e) { console.error(e) }
    }

    function connectUntil(sig, fn, untilFn) {
        if(typeof sig !== 'function' || typeof fn !== 'function' || untilFn !== 'function')
            return;

        var connector = function() {
            var args = Array.prototype.slice.call(arguments);

            fn.apply(this,args);
            if(!untilFn.apply(this,args))
                sig.disconnect(connector);
        }

        try {
            sig.connect(connector);
        } catch(e) {
            console.error(e);
        }
    }


    property TextEdit __private__ : TextEdit{
        id : textedit
    }

}
