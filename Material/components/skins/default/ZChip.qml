import Zabaat.Material 1.0
import QtQuick 2.5
import QtGraphicalEffects 1.0
import "helpers"
import "ZChip"

ZSkin {
    id : rootObject
    objectName : "ZChipSkin"
    property alias font    : text.font
    property alias guiVars : guiVars
    color          : graphical.fill_Default
    onWidthChanged : if(guiVars.dynamicScale && logic) {
                        logic.width = width
                     }
    skinFunc : function(name, params) {
        var fn = guiLogic[name]
//        console.log("Z C H I P " , fn, name)
        if(typeof fn === 'function')
            return fn(params)
        return null;
    }

    QtObject {
        id : guiVars
        property bool hasClose : false
        property bool hasLabel : logic && logic.label
        property color labelColor : Colors.success
        property real maskRadius : 0.5
        property bool dynamicScale : true
        property real padding : 5
    }

    QtObject {
        id : guiLogic
        function setColor(params) {
            if(params && params.color) {
                var success = true;
                try {
                    graphical.fill_Default = params.color
                }
                catch(e) {
                    console.log(rootObject, e)
                    success = false;
                }
//                console.log("color = ", graphical.fill_Default , "is assigned")
                return success;
            }
            return false;
        }
    }


    Item {
        id : gui
        height : parent.height
        width  : childrenRect.width
        onWidthChanged : if(guiVars.dynamicScale) {
                            rootObject.width = width
                         }


        Item {
            id : leftSide
            width  : childrenRect.width
            height : parent.height

            Rectangle {
                id : semiPadderRect
                anchors.left: semi1.right
                anchors.right: labelContainer.right
                color       : semi1.color
                height      : parent.height
            }
            SemiCircle {
                id : semi1
                state : 'left'
                width  : guiVars.hasLabel ? height/2 : 0
                visible : guiVars.hasLabel
                height : parent.height
                anchors.left: parent.le
                anchors.leftMargin: guiVars.padding
                radius :  rootObject.radius
                color  : graphical.fill_Default
            }
            ChipLabel {
                id : labelContainer
                width : height
                height: guiVars.hasLabel ? parent.height * 0.9 : 0
                src : logic && guiVars.hasLabel ? logic.label : null
                isImage : logic ? logic.labelIsImage : false
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: guiVars.padding
                visible : guiVars.hasLabel

                textColor      : graphical.text_Default
                border.color   : graphical.borderColor
                border.width   : rootObject.border.width
                backgroundColor: graphical.fill_Focus
                z : 2
            }
        }
        Rectangle {
            id : textContainer
            width  : logic ?  Math.min(logic.maxWidth, Math.max(logic.implicitWidth, cw)) : cw
            height : parent.height
            anchors.left: leftSide.right
            color  : graphical.fill_Default
            property real cw : text.paintedWidth + guiVars.padding * 2
            Text {
                id : text
                width              : paintedWidth
                height             : parent.height
                anchors.centerIn   : parent
                horizontalAlignment: graphical.text_hAlignment
                verticalAlignment  : graphical.text_vAlignment
                font.family        : Fonts.font1
                color              : graphical.text_Default
                text               : logic ? logic.text : ""
                textFormat         : Text.RichText
                clip               : true
            }
            z :Number.MAX_VALUE
        }
        MouseArea {
            anchors.fill: textContainer
            onClicked : if(logic)
                            logic.clicked()
        }

        Item {
            id : rightSide
            width  : semi2.width + semi2PadderRect.width
            height : parent.height
            anchors.left: textContainer.right


            Rectangle {
                id : semi2PadderRect
                height : parent.height
                anchors.right: semi2.left
                anchors.left: clsBtn.left
                color : graphical.fill_Default
            }
            SemiCircle {
                id : semi2
                state : 'right'
                height : parent.height
                radius :  rootObject.radius
                anchors.left: clsBtn.left
                anchors.leftMargin: (clsBtn.width + guiVars.padding) - width
                color  : graphical.fill_Default
            }
            ZButton {
                id : clsBtn
                state  : logic ? logic.closeButtonState : ""
                height : parent.height * 0.5
                width  : height
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: guiVars.padding
                text   : logic? logic.closeButtonText : "close"
                onClicked : if(logic)
                                logic.close()
                disableShowsGraphically: false
            }
        }












    }


    states : ({
        "default" :  { graphical :  { "@fill_Default" : function() { return Colors.getContrastingColor(Colors.standard, 1.2) } } ,

                      "guiVars"   : { hasClose: false, "@labelColor" : [Colors,"success"], maskRadius : 0.5 }
                     } ,
        "close" :    { "guiVars"  : { hasClose: true }} ,
        "dynamicScale" : { "guiVars" : { dynamicScale : true }}
    })



}
