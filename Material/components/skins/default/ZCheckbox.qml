import Zabaat.Material 1.0
import QtQuick 2.4

ZSkin {
    id : rootObject


    property alias font : text.font

    Connections {
        target : logic ? logic : null
//        onValueChanged : update()
    }

//    onLogicChanged: if(logic)
//                        update()
    property string guiState : "Default"


    border.color : graphical.borderColor
    radius : 2
    color        : logic && logic.checked ? graphical.fill_Default : Colors.standard

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
        text  : logic.checked ? FA.check : ""
    }



    states : ({
        "default" : {
                  "graphical" : { "@fill_Default" : [Colors, "success"] }

         }



    })


}
