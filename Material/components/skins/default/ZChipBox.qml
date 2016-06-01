import Zabaat.Material 1.0
import QtQuick 2.5
ZSkin {
    id : rootObject
    onLogicChanged: if(logic && lv.footerItem){
                        lv.footerItem.text = logic.text
                    }
    clip : true

    ListView {
        id : lv
        width  : parent.width
        height : parent.height
        anchors.left: parent.left
        anchors.leftMargin: 5
        orientation        : ListView.Horizontal
        model              : logic && logic.chips ? logic.chips : null
//        snapMode           : ListView.NoSnap
//        highlightRangeMode : ListView.NoHighlightRange
        spacing : 5
        delegate : ZChip {
            height : lv.height * 3/4
            width  : lv.height * 2.5
            anchors.verticalCenter: parent.verticalCenter
            state  : logic ? logic.chipState : ""
            closeButtonState: logic?  logic.chipCloseButtonState : ""
            closeButtonText: logic ? logic.chipCloseButtonText : "Close"
            text   : lv.model ? lv.model[index] : ""
            onClose: if(logic){
                logic.removeChip(index)
            }
        }
        onCountChanged : if(footerItem && count === 0){
                             footerItem.x = 0
                         }
        footer : Item {
            width  : lv.width
            height : lv.height
            property alias text : footerTextBox.text
                ZTextBox {
                id : footerTextBox
                anchors.fill: parent
                anchors.margins: Math.min(parent.width,parent.height) * 0.1
                property bool mutex : false
                state : logic ? 'b1-f3-tleft' : ""
                label : logic ? logic.label : ""
                onAccepted    : if(logic) logic.setText(text)
            }
            Component.onCompleted: if(logic) {
                                       text = logic.text
                                   }



        }


    }


}
