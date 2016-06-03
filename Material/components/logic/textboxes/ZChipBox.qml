import Zabaat.Material 1.0
ZObject {
    id : rootObject
    objectName : "ZChipBox"

    property string label                : ""
    property string text                 : ""
    property var    chips                : []
    property var    chipModifierFunc     : null

    property string chipState            : "close"
    property string chipCloseButtonState : 'disabled-circle-f2'
    property string chipCloseButtonText  : FAR.close
    property string textBoxState         : "nobar-b0-lleft"


    onTextChanged : if(typeof chipMakerFunc === 'function'){
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

    function removeChip(idx){
        if(chips.length > idx && idx >= 0) {
            chips.splice(idx,1)
            refresh()
        }
    }
    function setText(text) {
        if(chipMakerFunc) {
            rootObject.text = text;
            chips = chipMakerFunc(text);
        }
    }





}
