import Zabaat.Material 1.0
import QtQuick 2.5

ZSkin {
    id : rootObject
    property alias text : text
    property alias font : text.font
    color : graphical.fill_Default

    Text {
        id : text
        anchors.fill: parent
        anchors.margins: 5
        horizontalAlignment: graphical.text_hAlignment
        verticalAlignment: graphical.text_vAlignment
        font.family: Fonts.font1
        font.pixelSize: height * 1/4
        color : Colors.contrastingTextColor(parent.color)
        text : logic ? logic.text : ""
        textFormat: Text.RichText
    }

    states : ({ "default" :  { rootObject : { "border.width" : 0 ,
                                                "@color" : [graphical,"fill_Empty"]
                                              }
                              },
                'text' : {"@color" : function() { return Colors.contrastingTextColor(rootObject.color) } }

              })


}
