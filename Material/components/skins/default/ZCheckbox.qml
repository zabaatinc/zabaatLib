import Zabaat.Material 1.0
import QtQuick 2.4

ZSkin {
    id : rootObject
    property alias font : text.font
    property string guiState : "Default"

    Connections {
        target : logic ? logic : null
//        onValueChanged : update()
    }

    border.color : graphical.borderColor
    radius       : 2
    color        : logic ? graphical.fill_Default : Colors.standard




    ZInkArea {
        anchors.fill: parent
//            color : graphical.inkColor
        enabled : logic ? true : false
        onClicked: if(logic) {
                       logic.checked = !logic.checked
                   }
        opacity: graphical.inkOpacity
//            clip :false
    }

    Text {
        id : text
        anchors.fill: parent
        horizontalAlignment: graphical.text_hAlignment
        verticalAlignment  : graphical.text_vAlignment
        color : graphical.text_Default
        text  : logic.checked ? FAR.check : ""
        textFormat: Text.RichText
    }



    states : ({
        "default" : {
                  "graphical" : { "@fill_Default" : [Colors, "standard"] }


         }



    })


}
