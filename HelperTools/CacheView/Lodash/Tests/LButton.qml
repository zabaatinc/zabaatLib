import QtQuick 2.5
MouseArea {
    id : rootObject
    implicitWidth : t.paintedWidth + 20
    implicitHeight: 40
    hoverEnabled: true

    property int fontScl : 1
    property color colorBgPress   : "red"
    property color colorBgHover   : "orange"
    property color colorBg        : "yellow"
    property color colorText      : "black"
    property color colorTextPress : "white"


    Rectangle {
        id : r
        anchors.fill: parent
        radius : height / 8
        color : rootObject.containsPress? colorBgPress :
                                          rootObject.containsMouse ? colorBgHover :
                                                                     colorBg

        border.width: 1
    }

    property alias text: t.text


    Text {
        id : t
        height : parent.height

        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: height * (1/3 * fontScl)
        color : rootObject.containsPress? colorTextPress :
                                          rootObject.containsMouse ? colorText :
                                                                     colorText
    }


}
