import QtQuick 2.5
import QtGraphicalEffects 1.0
import Zabaat.Material 1.0
Item {
    id      : rootObject
    property var  src
    property bool isImage : false
    property color textColor : Colors.text1
    property color backgroundColor : Colors.info
    property alias border : borderRect.border
    property real  radius : height/2
    property real  maskRadius : 8

    Loader {
        id : labelLoader
        anchors.fill    : parent
        sourceComponent : typeof src !== 'string' ? null : isImage ? labelImg : labelTxt
        onLoaded        : if(item) {
                              item.anchors.fill = labelLoader
                          }

        Component {
            id : labelImg
            Item {
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
                    source      : src
                }
                Rectangle {
                    id : mask
                    visible : false
                    anchors.fill: parent
                    radius : height * rootObject.maskRadius
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
                color : backgroundColor
                radius : height/2
                clip : true
                Text {
                    id : labelText
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text : rootObject.logic ? rootObject.logic.label : ""
                    font.family:  Fonts.font1
                    color : textColor
                }
            }
        }
    }
    Rectangle {
        id : borderRect
        anchors.fill: parent
        radius : rootObject.radius
        color : 'transparent'
        border.color: textColor
        visible : labelLoader && labelLoader.item ? true : false
    }


}
