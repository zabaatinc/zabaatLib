import Zabaat.Material 1.0
import QtQuick 2.5
import Zabaat.Utility 1.0
ZSkin {
    id : rootObject
    clip : true
    onLogicChanged: if(logic && textBox.text){
                        textBox.text = logic.text
                    }
    color : graphical.fill_Default

    skinFunc : function(name, params) {
        var fn = guiLogic[name]
        if(typeof fn === 'function')
            return fn(params)
        return null;
    }


    QtObject {
        id : guiLogic

        property bool inputMode : lv.count === 0 ? true : false

        function selectWord(wordNum) {
            guiLogic.inputMode = true;
            textBox.selectWord(wordNum)
        }

        function getInputMode() {
            return textBox.visible ?  1 : 0
        }

    }

    Item {
        id : gui
        anchors.fill: parent

        ZTextBox {
            id : textBox
            anchors.fill: parent
            state         : logic ? logic.textBoxState : ""
            label         : logic ? logic.label : ""
            onAccepted    : if(logic) {
                                logic.text = text
                                guiLogic.inputMode = false;

                            }
            visible : guiLogic.inputMode
            Component.onCompleted: if(logic) {
                                       text = logic.text
                                   }
        }

        ListView {
            id : lv
            width  : parent.width
            height : parent.height
            anchors.left: parent.left
            anchors.leftMargin: spacing
            orientation        : ListView.Horizontal
            model              : !guiLogic.inputMode && logic && logic.chips ? logic.chips : null
            visible            : !guiLogic.inputMode
            enabled            : !guiLogic.inputMode
            spacing : 5
            delegate : ZChip {
                id : delChip
                height : lv.height * 3/4
                width  : lv.height * 2.5
                anchors.verticalCenter: parent.verticalCenter
                state  : logic ? logic.chipState : ""
                closeButtonState: logic?  logic.chipCloseButtonState : ""
                closeButtonText: logic ? logic.chipCloseButtonText : "Close"
                text   : lv.model ? lv.model[index] : ""
                onClose: if(logic){
                    textBox.removeWord(index)
                    logic.removeChip(index)
                }
                onClicked : {
                    guiLogic.selectWord(index)
                }

//                Component.onCompleted: colorCheckFunc(text)
                onTextChanged: {
                    if(text !== "" && logic && typeof logic.chipModifierFunc === 'function') {
                        logic.chipModifierFunc(text, delChip)
                    }
                }
                onSkinLoaded : {
                    if(text !== "" && logic && typeof logic.chipModifierFunc === 'function') {
//                        console.log("skin loaded")
                        logic.chipModifierFunc(text, delChip)
                    }
                }

            }
            onCountChanged : if(count === 0 && footerItem)
                                 footerItem.x = 0;
        }

        MouseArea {
            id : ma
            width : lv.width
            height: lv.height
            anchors.left: parent.left
            anchors.leftMargin: lv.contentX + lv.contentItem.childrenRect.width
            onPressed  : mouse.accepted = false;
            onReleased : mouse.accepted = false;
            propagateComposedEvents: true
            preventStealing: false;
            enabled : !guiLogic.inputMode
            onPressedChanged : if(!pressed && !guiLogic.inputMode) {
//                                    console.log("OH HELLo")
                                    guiLogic.inputMode = true;
                                    textBox.forceActiveFocus()
                               }
        }


    }


//    states : ({
//      "default" : { "guiVars": { "chipsPos" : "right" } } ,
//      "left"    : { "guiVars": { "chipsPos" : "left" } } ,
//      "right"   : { "guiVars": { "chipsPos" : "right" } } ,
//      "bottom"  : { "guiVars": { "chipsPos" : "bottom" } } ,
//      "top"     : { "guiVars": { "chipsPos" : "top" } } ,
//    })


}
