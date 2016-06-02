import Zabaat.Material 1.0
ZObject {
    id : rootObject
    objectName : "ZChipBox"

    property string label        : ""
    property string text         : ""
    property var    chips        : []
    property string chipState    : "close"
    property string chipCloseButtonState : 'disabled-circle-f2'
    property string chipCloseButtonText  : FAR.close
    property string textBoxState : "nobar-b0-tleft-lleft"

    onTextChanged : if(typeof chipMakerFunc === 'function'){
                        chips = chipMakerFunc(text);
                    }

    function setText(text) {
        if(chipMakerFunc) {
            rootObject.text = text;
            chips =chipMakerFunc(text);
        }
    }


    property var chipMakerFunc : function(text){
        if(text !== "") {
            return text.split(" ")
        }
        return []
    }

    function removeChip(idx){
        if(chips.length > idx && idx >= 0) {
            chips.splice(idx,1)
            var arr = chips
            chips = null
            chips = arr;
        }
    }






}
