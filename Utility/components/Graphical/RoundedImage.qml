import QtQuick 2.5
import QtGraphicalEffects 1.0
Item {
    id : rootObject
    property alias source   : img.source
    property alias fillMode : img.fillMode
    property alias radius   : mask.radius
    property alias border   : borderRect.border
    property alias img : img

    Image {
        id: img
        anchors.fill: parent
        fillMode : Image.PreserveAspectCrop
        visible : false
    }


    Rectangle {
        id : mask
        visible : false
        anchors.fill: parent
        radius : height/2
    }

    OpacityMask {
        anchors.fill: parent
        source : img
        maskSource: mask
    }

    Rectangle {
        id : borderRect
        color : 'transparent'
        anchors.fill: parent
        radius : height/2
        border.width: 1
        border.color: 'gray'
    }

}
