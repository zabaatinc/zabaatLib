import Zabaat.Material 1.0
import QtQuick 2.5
ZSkin {
    id : rootObject

    onLogicChanged: if(logic){
                        textBox.text = logic.text
                    }
    clip : true

    ListView {
        id : lv
        width  : parent.width
        height : parent.height
        orientation: ListView.Horizontal
        model : logic && logic.chips ? logic.chips : null
        snapMode : ListView.NoSnap
        highlightRangeMode : ListView.NoHighlightRange

        delegate : ZChip {
            height : parent.height
            width  : height * 2.5
            state  : logic ? logic.chipState : ""
            text   : lv.model ? lv.model[index] : ""
//            Component.onCompleted: console.log("OH NOES")
            onClose: if(logic){
                logic.removeChip(index)
            }
        }
        onCountChanged : if(textBox.activeFocus){
                             lv.positionViewAtIndex(lv.count -1 , ListView.End)
                         }
    }

    ZTextBox {
        id : textBox
        width : parent.width
        height : parent.height
        anchors.left      : lv.left
        anchors.leftMargin: -lv.contentX + lv.contentWidth


        property bool mutex : false
        state : logic ? logic.textBoxState + '-b1' : ""
        label : logic ? logic.label : ""
        onAccepted    : setText(text)
//        onTextChanged : setText(text)
        function setText(text){
            if(!mutex) {
                mutex = true;

                if(logic)
                    logic.text = text

//                textBox.text = "";

                mutex = false;
            }
        }
        onActiveFocusChanged: if(activeFocus) {
                                lv.positionViewAtIndex(lv.count -1 , ListView.End)
                              }
    }

}
