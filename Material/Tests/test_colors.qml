import Zabaat.Material 1.0
import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import Zabaat.Utility 1.0

FocusScope {
    id : rootObject

    ListView {
        id : lv
        width  : parent.width
        height : parent.height * 0.1
        orientation : ListView.Horizontal
        model  : ListModel {
            ListElement { name : "default" }
            ListElement { name : "disabled" }
            ListElement { name : "accent" }
            ListElement { name : "info" }
            ListElement { name : "danger" }
            ListElement { name : "success" }
            ListElement { name : "warning" }
            ListElement { name : "ghost" }
            ListElement { name : "transparent" }
            ListElement { name : "t1" }
            ListElement { name : "t2" }
            ListElement { name : "tcenter"         }
            ListElement { name : "tcenterright"    }
            ListElement { name : "tcenterleft"     }
            ListElement { name : "ttopright"       }
            ListElement { name : "ttopleft"        }
            ListElement { name : "tbottomright"    }
            ListElement { name : "tbottomleft"     }
        }
        delegate : Button {
            width : lv.width * 0.05
            height : lv.height
            text : name
            onClicked : rootObject.allState = name
        }


    }



    property int w : 128
    property int h : 64
    property string allState : "default"

    Grid {
        anchors.bottom: parent.bottom
        width : parent.width
        height : parent.height - lv.height
        ZButton {
            id : button
            width  : w
            height : h
            text   : "Hello"
            state  : allState
        }
        ZTextBox {
            id : textbox
            width : w
            height: h
            text : "Hello"
            state  : allState
        }
        ZHoldButton {
            id : holdBUtton
            width : w
            height : h
            text : "Hello"
            state  : allState
        }
        ZSwitch {
            id : zswitch
            width : w
            height: h
            state : allState
        }

    }




}
