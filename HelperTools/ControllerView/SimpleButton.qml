import QtQuick 2.5
Rectangle {
    id : rootObject
//    width : lv.width
//    height: lv.height * cellHeight
//    color    : lv.currentIndex === index ? color2 : color1
    border.width: 1
    property alias textColor : t.color
    property alias text      : t.text
    property alias font      : t.font
    property alias paintedWidth : t.paintedWidth
    signal clicked();
    Text {
        id : t
        horizontalAlignment:  Text.AlignHCenter
        verticalAlignment  :  Text.AlignVCenter
        anchors.fill: parent
    }

    MouseArea {
        anchors.fill: parent
        onClicked: rootObject.clicked()
    }
}
