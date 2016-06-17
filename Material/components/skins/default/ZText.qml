import Zabaat.Material 1.0
import QtQuick 2.5

ZSkin {
    id : rootObject
    property alias text : text
    property alias font : text.font
    color : graphical.fill_Default
    border.color: graphical.borderColor
    property bool paintedWidth : false
    onPaintedWidthChanged: if(paintedWidth) {
                                rootObject.width = logic.width = text.paintedWidth + 10
                           }

    Text {
        id : text
        anchors.fill: parent
        anchors.margins: 5
        horizontalAlignment: graphical.text_hAlignment
        verticalAlignment: graphical.text_vAlignment
        font.family: Fonts.font1
        font.pixelSize: height * 1/4
        color : graphical.text_Default
        text : logic ? logic.text : ""
        textFormat: Text.RichText
        onPaintedWidthChanged: if(rootObject.paintedWidth) {
                                   rootObject.width = logic.width = paintedWidth + 10
                               }
    }

    states : ({ "default" :  { rootObject : { "border.width" : 0 ,
                                               "paintedWidth" : false
                                              },
                               graphical : { "fill_Default" : "transparent" }
                  },
                 "fit" : {text : { "@scale" : function() { return text.paintedWidth > text.width ? (text.width - 5) / text.paintedWidth : 1}  }

                  },
                  "paintedwidth" : { rootObject : { paintedWidth : true }

                   }



              })


}
