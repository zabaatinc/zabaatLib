import Zabaat.Material 1.0
import QtQuick 2.5
ZObject {
    id : rootObject
    objectName : "ZChipBox"

    property string label                : ""
    property string text                 : ""
    property var    chips                : []
    property var    chipModifierFunc

    property string chipState            : "close"
    property string chipCloseButtonState : 'danger-circle-f2'
    property string chipCloseButtonText  : FAR.close
    property string textBoxState         : "nobar-b0-lleft"


    onTextChanged : if(typeof chipMakerFunc === 'function'){
//                        var newChips = chipMakerFunc(text);
////                        console.log("text change happening", newChips)
//                        if(newChips) {
////                            console.log(chips, "CMP" ,newChips)
//                            if(!priv.arraysEqual(chips,newChips))
//                                chips = newChips
//                        }
//                        else {
//                            chips = []
//                        }
                        chips = chipMakerFunc(text);
                    }

    onChipModifierFuncChanged: {
        refresh()
    }

    property var chipMakerFunc : function(text){
        function compactify(arr) {
            for(var i = arr.length - 1; i >= 0 ; --i ){
                if(arr[i] === null || typeof arr[i] === 'undefined' || arr[i] === "")
                    arr.splice(i,1);
            }
            return arr;
        }

        if(text !== "") {
            return compactify(text.split(" "))
        }
        return []
    }

    function refresh() {
        var arr = chips
        chips = null
        chips = arr;
    }

    function addChip(str) {
        var arr = chips
        arr.push(str);
        chips = null;
        chips = arr;
        refresh()
    }

    function removeChip(idx){
        if(chips.length > idx && idx >= 0) {
            chips.splice(idx,1)
            refresh()
        }
    }

    function getInputMode(){
        return skinFunc('getInputMode')
    }

    function setInputMode(bool) {
        return skinFunc('setInputMode',bool)
    }


    QtObject {
        id : priv
        function arraysEqual(a, b) {
          if (a === b) return true;
          if (a == null || b == null) return false;
          if (a.length != b.length) return false;

          // If you don't care about the order of the elements inside
          // the array, you should sort both arrays here.

          for (var i = 0; i < a.length; ++i) {
            if (a[i] !== b[i]) return false;
          }
          return true;
        }
    }


}
