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
    property var    validationFunc
    property bool   strictValidation   : false
    property var    setAcceptedTextFunc: function(val) {
                                            if(text !== val)
                                                text = val;
                                        }

    //so our text is validated upon startup!!
    onValidationFuncChanged: if(setTextFunc) setTextFunc(text, false, true)
    Component.onCompleted  : if(setTextFunc) setTextFunc(text, false, true)
    debug : false



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
    function copy()             { return skinFunc(arguments.callee.name) }
    function cut()              { return skinFunc(arguments.callee.name) }
    function deselect()         { return skinFunc(arguments.callee.name) }
    function undo()             { return skinFunc(arguments.callee.name) }
    function redo()             { return skinFunc(arguments.callee.name) }
    function paste()            { return skinFunc(arguments.callee.name) }
    function select(start, end) { return skinFunc(arguments.callee.name, {start:start,end:end}) }
    function selectAll()        { return skinFunc(arguments.callee.name) }
    function selectWord(num)    { return skinFunc(arguments.callee.name, {num:num } ) }
    function removeWord(num)    { return skinFunc(arguments.callee.name, {num:num } ) }
    function selectedText()     { return skinFunc(arguments.callee.name) }

//    function getText(int start, int end)
//    function insert(int position, string text)
//    function isRightToLeft(int start, int end)
//    function moveCursorSelection(int position, SelectionMode mode)
//    function int positionAt(real x, real y, CursorPosition position)
//    function rect positionToRectangle(int pos)
//    function remove(int start, int end)



}
