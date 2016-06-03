import Zabaat.Material 1.0
import QtQuick 2.5
import QtGraphicalEffects 1.0
import "helpers"

ZSkin {
    id : rootObject
    property alias font    : text.font
    property alias guiVars : guiVars
    color          : graphical.fill_Empty
    onWidthChanged : if(guiVars.dynamicScale && logic) {
                        logic.width = width
                     }
    skinFunc : function(name, params) {
        var fn = guiLogic[name]
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
            id      : labelContainer
            width   : guiVars.hasLabel ? parent.height : 0
            height  : width
            visible : guiVars.hasLabel

            Loader {
                id : labelLoader
                anchors.fill    : parent
                sourceComponent : !guiVars.hasLabel ? null : logic.labelIsImage ? labelImg : labelTxt
                onLoaded        : if(item) {
                                      item.anchors.fill = labelLoader
                                  }

                Component {
                    id : labelImg
                    Item {
                        id : rootObject
//                        Component.onCompleted: console.log("IMAGE CMP LOADED")
                        Rectangle {
                            anchors.fill: parent
                            color : Colors.standard
                            radius : height/2
                        }

                        Image {
                            id: img
                            anchors.fill: parent
                            fillMode    : Image.PreserveAspectFit
                            visible     : false
                            source      : logic ? logic.label : ""
                        }
                        Rectangle {
                            id : mask
                            visible : false
                            anchors.fill: parent
                            radius : height * guiVars.maskRadius
                        }
                        OpacityMask {
                            anchors.fill: parent
                            source : img
                            maskSource: mask
                        }

                    }
                }
                Component {
                    id : labelTxt
                    Rectangle {
                        color : guiVars.labelColor
                        radius : height/2
                        clip : true
                        border.color: graphical.borderColor
                        border.width: rootObject.border.width
                        Text {
                            id : labelText
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text : rootObject.logic ? rootObject.logic.label : ""
                            font.family:  Fonts.font1
                            font.pixelSize: height * 0.6
                            color : graphical.text_Press
                        }
                    }
                }
            }

            z : 2
        }

        SemiCircle {
            id : semi1
            state : 'left'
            width  : guiVars.hasLabel ? height/2 : 0
            visible : guiVars.hasLabel
            color  : graphical.fill_Default
            height : parent.height
            anchors.left: labelContainer.right
            anchors.leftMargin: -labelContainer.width * 0.75
            radius :  rootObject.radius
        }

        Rectangle {
            id : textContainer
            width  : text.width
            height : parent.height
            anchors.left: semi1.right
            color  : graphical.fill_Default
            radius : !guiVars.hasLabel ? rootObject.radius : 0
            Rectangle {
                width   : parent.width/2
                height  : parent.height
                anchors.right : parent.right
                color : parent.color
                visible : !guiVars.hasLabel

            }

            MouseArea {
                anchors.fill: parent
                onClicked : if(logic)   logic.clicked()
            }

            Text {
                id : text
                width  : !guiVars.dynamicScale ? parent.width  - labelContainer.width/4 :
                                                 Math.max(paintedWidth * 1.1 ,height * 1.25)
                height             : parent.height
                anchors.centerIn   : parent
                horizontalAlignment: graphical.text_hAlignment
                verticalAlignment  : graphical.text_vAlignment
                font.family        : Fonts.font1
                font.pixelSize     : height * 1/4
                color              : graphical.text_Default
                text               : logic ? logic.text : ""
                textFormat         : Text.RichText
                clip               : true
                onTextChanged : if(guiVars.dynamicScale) {

                                }


            }

        }



        SemiCircle {
            id : semi2
            state : 'right'
            height : parent.height
            radius :  rootObject.radius
            anchors.left: textContainer.right
            color  : graphical.fill_Default
        }
        ZButton {
            state  : logic ? logic.closeButtonState : ""
            height : parent.height/2
            width  : height
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: semi2.left
            anchors.leftMargin: -width/2
            text   : logic? logic.closeButtonText : "close"
            onClicked : if(logic)
                            logic.close()
            disableShowsGraphically: false
        }






    }


    states : ({
        "default" :  { graphical :  { "@fill_Default" : function() { return Colors.getContrastingColor(Colors.standard, 1.2) } } ,
                      "rootObject": { "border.width" : 0 , '@radius' : function() { return rootObject.height/2 }  } ,
                      "guiVars"   : { hasClose: false, "@labelColor" : [Colors,"success"], maskRadius : 0.5 }
                     } ,
        "close" :    { "guiVars"  : { hasClose: true }} ,
        "dynamicScale" : { "guiVars" : { dynamicScale : true }}
    })



}
