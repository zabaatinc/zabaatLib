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

    //Generates & returns a new function that calls fn with arguments provided here.
    function generate(fn) {
        var args = Array.prototype.slice.call(arguments);
        if(args.length > 0) //so we dont call fn(fn,argA,argB...), we want fn(argA,argB,...);
            args.splice(0,1);

        return function() {
            return fn.apply(this,args);
        }
    }

    property TextEdit __private__ : TextEdit{
        id : textedit
    }

}
