import Zabaat.Material 1.0
import QtQuick 2.5

ZSkin {
    id : rootObject
    property alias text : text
    property alias font : text.font

    color : graphical.fill_Default
    border.color: graphical.borderColor
    property bool paintedWidth : false
    property bool paintedHeight : false


    skinFunc : function(name, params) { //the logic may call this!!
        var fn = guiLogic[name]
        if(typeof fn === 'function')
            return fn(params);
        console.log(rootObject, 'has no skin function called', name)
        return null;
    }
    QtObject {
        id : guiLogic
        function paintedWidth() {  return text.paintedWidth; }
        function paintedHeight() {  return text.paintedHeight; }
    }

    onPaintedWidthChanged: if(paintedWidth) {
                               var f = function() { return text.paintedWidth + 10 }
                               rootObject.width = Qt.binding(f);
                               logic.width      = Qt.binding(f);
                           } else {
                               var temp = rootObject.width
                               rootObject.width = logic.width = 64;
                               rootObject.width = logic.width = temp;
                           }

    onPaintedHeightChanged: if(paintedWidth) {
                                var f= function() { return text.paintedHeight + 10}
                                rootObject.height = Qt.binding(f);
                                logic.height = Qt.binding(f);
                           } else {
                                var temp = rootObject.height
                                rootObject.height = logic.height = 64;
                                rootObject.height = logic.height = temp;
                            }

    Text {
        id : text
        anchors.fill: parent
        anchors.margins: 5
        horizontalAlignment: graphical.text_hAlignment
        verticalAlignment: graphical.text_vAlignment
        font.family: Fonts.font1
//        font.pixelSize: height * 1/4
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
                  "paintedwidth"  : { rootObject : { paintedWidth : true    }},
                  "paintedheight" : { rootObject : { paintedHeight : true   }},
                  "wordwrap"      : { text : { wrapMode : Text.WordWrap     }},
                  "elideright"    : { text: { scale : 1, elide : Text.ElideRight      }},
                  "elideleft"     : { text: { scale : 1, elide : Text.ElideLeft       }},
                  "elidemiddle"   : { text: { scale : 1, elide : Text.ElideMiddle     }}
              })


}
