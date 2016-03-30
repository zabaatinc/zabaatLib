import QtQuick 2.5
import Zabaat.Material 1.0
Item {


    ListView {
        id : lv
        anchors.fill: parent
        model : ListModel {
            ListElement { name : "ZButton"        }
            ListElement { name : "ZTextBox"       }
            ListElement { name : "ZHoldButton"    }
            ListElement { name : "ZSwitch"        }
            ListElement { name : "ZSlider"        }
            ListElement { name : "ZCheckbox"      }
            ListElement { name : "ZText"          }
            ListElement { name : "ZTextBoxLabel"  }
        }
        delegate : Item {
            id : delItem
            width : lv.width
            height : lv.height * 0.2
            Loader{
                anchors.centerIn: parent
                width : parent.width/2
                height : parent.height/2
                sourceComponent: components["_" + name] ? components["_" + name] : null
                onLoaded : {
                    item.state = "shadow"
                    if(item.hasOwnProperty('text'))
                        item.text = "Shadow"
                }
            }
        }

    }

    Item {
        id : components
        property Component _ZButton       : Component { id : _ZButton      ; ZButton       {} }
        property Component _ZTextBox      : Component { id : _ZTextBox     ; ZTextBox      {} }
        property Component _ZHoldButton   : Component { id : _ZHoldButton  ; ZHoldButton   {} }
        property Component _ZSwitch       : Component { id : _ZSwitch      ; ZSwitch       {} }
        property Component _ZSlider       : Component { id : _ZSlider      ; ZSlider       {} }
        property Component _ZCheckbox     : Component { id : _ZCheckbox    ; ZCheckbox     {} }
        property Component _ZText         : Component { id : _ZText        ; ZText         {} }
        property Component _ZTextBoxLabel : Component { id : _ZTextBoxLabel; ZTextBoxLabel {} }
    }






}
