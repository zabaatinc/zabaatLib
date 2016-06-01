import Zabaat.Material 1.0
import QtQuick 2.5
import QtGraphicalEffects 1.0

ZSkin {
    id : rootObject

    property alias font    : text.font
    property alias guiVars : guiVars

    QtObject {
        id : guiVars
        property bool hasClose : false
        property bool hasLabel : logic && logic.label
        property color labelColor : Colors.success
        property real maskRadius : 0.5
        property bool dynamicScale : true
    }


    Item {
        id : gui
        anchors.fill: parent

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


        Rectangle {
            id : textContainer
            radius: height/2
            width  : !guiVars.dynamicScale ?  parent.width - labelContainer.width/4 : text.width
            onWidthChanged : if(guiVars.dynamicScale) {
                                rootObject.width = guiVars.dynamicScale
                             }

            height : parent.height
            anchors.left: parent.left
            anchors.leftMargin: guiVars.hasLabel ? labelContainer.width/4 : 0
            color  : graphical.fill_Default
            MouseArea {
                anchors.fill: parent
                onClicked : if(logic)   logic.clicked()
            }

            Text {
                id : text
                width  : !guiVars.dynamicScale ? parent.width - closeBtnContainer.width - labelContainer.width/4 :
                                                 Math.min(paintedWidth +20 , height * 2.5)
                height : parent.height
                anchors.centerIn: parent
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

//                Rectangle { anchors.fill: parent ; border.width: 1; color : 'transparent' }

            }

        }


        Item {
            id : closeBtnContainer
            anchors.right: parent.right
            width : height
            height : guiVars.hasClose ? parent.height  : 0
            visible : guiVars.hasClose

            ZButton {
                state  : logic ? logic.closeButtonState : ""
                height : parent.height/2
                width  : height
                anchors.centerIn: parent
                text   : FAR.close
                onClicked : if(logic)
                                logic.close()
                disableShowsGraphically: false
            }
        }





    }


    states : ({
        "default" :  { graphical :  { "@fill_Default" : function() { return Colors.getContrastingColor(Colors.standard, 1.2) } } ,
                      "rootObject": { "border.width" : 0 } ,
                      "guiVars"   : { hasClose: false, "@labelColor" : [Colors,"success"], maskRadius : 0.5 }
                     } ,
        "close" :    { "guiVars"  : { hasClose: true }} ,
        "dynamicScale" : { "guiVars" : { dynamicScale : true }}
    })



}
