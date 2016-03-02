import QtQuick 2.4
import Zabaat.Material 1.0
ZObject {
    id : rootObject
    objectName: "ZTextBox"

    signal inputChanged(string text, string oldText, bool acceptable);
    signal accepted    (string text, string oldText);

    property string text               : ""
    property string error              : ""
    property string label              : ""
    property bool   changeOnlyOnAccept : false
    property var    validationFunc     : null
    property bool   strictValidation   : false
    property var    setAcceptedTextFunc: function(val) { text = val; }

    //so our text is validated upon startup!!
    onValidationFuncChanged: if(setTextFunc) setTextFunc(text, false, true)
    Component.onCompleted  : if(setTextFunc) setTextFunc(text, false, true)


    debug : false

    function getUnformattedText(rtfText){
        if(rtfText === null || typeof rtfText === 'undefined')
            rtfText = text;

        do {
            var startIndex = rtfText.indexOf("<")
            var endIndex   = rtfText.indexOf(">")
            if(startIndex !== -1 && startIndex < endIndex )
                rtfText = rtfText.substring(0,startIndex) + rtfText.substring(endIndex+ 1, rtfText.length);
        }while(startIndex !== -1 && startIndex < endIndex )

        return rtfText;
    }

    property var setTextFunc : function(val, accept, override) {
        if(val !== text || accept || override) {
            var oldText = text;
            var err     = validationFunc ? validationFunc(val, oldText, rootObject) : null;
            error       = err ? err : "";

            if(!err || !strictValidation) {
                if(changeOnlyOnAccept && accept){
                    setAcceptedTextFunc(val);
                    rootObject.inputChanged(val,oldText,err === null)     //emits that input was changed!

                    if(!err)
                        rootObject.accepted(val , oldText);
                }
                else if(!changeOnlyOnAccept){
                    setAcceptedTextFunc(val);
                    rootObject.inputChanged(val,oldText,err === null)     //emits that input was changed!
                    if(accept && !err)
                        rootObject.accepted(val,oldText);
                }
            }
        }
    }
}
