import Zabaat.Material 1.0
import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import Zabaat.Utility 1.0

Rectangle {
    id : rootObject
    color : 'lightblue'


    CheckBox{
        id : transparencyBox
        onCheckedChanged: if(checked) {
                              allState = allState +  "-semitransparent"
                          }
                          else {
                              allState = allState.replace("-semitransparent","")
                          }

        text : "Transparency"
        anchors.right: parent.right
        z : 999
    }

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
            onClicked : rootObject.allState = name + transparency
        }


    }



    property int w : 128
    property int h : 64
    property string allState : "default" + transparency
    property string transparency : transparencyBox.checked ? "-semitransparent" : ""

    Grid {
        anchors.bottom: parent.bottom
        width : parent.width
        height : parent.height - lv.height
        ZButton {
            id : button
            width  : w
            height : h
            text   : "Toast!"
            state  : allState
            onClicked : {
                Toasts.create("world" , {state : allState, title : "derp" } );
//                Toasts.error("world","error")
            }
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
            state : allState + "-knob10"
        }
        ZSlider {
            id : zslider
            width : w
            height : h
            min : 0
            max : 100
            state : allState
        }
        ZCheckbox {
            id : zcheckbox
            width : w
            height : h
            state : allState
        }
        ZText {
            id : ztext
            width : w
            height : h
            state : allState
            text : "ZText"
        }
        ZTextBoxLabel {
            width  : w * 1.5
            height : h
            state : 'left'
            state_Label: allState
            state_TextBox: allState
            description : "go nuts"
            text : "herp"
            label : FA.user
        }


    }

    ZRadialView {
        width : w * 2
        height : h * 4
        model : 10
        defaultDelegate.state_Selected: allState + "-f1"
        anchors.bottom: parent.bottom
        anchors.margins: 10
    }

    ZSpinner {
        width : w* 2
        height : h * 4
        model : 10
        defaultDelegate.state_Selected: allState + "-f1"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 10
    }




}
