import QtQuick 2.5
Item {
    id : rootObject
    clip : true

    signal clicked();
    property var m
    property string uid : m !== null && m !== undefined ? m.id : ""

    property alias showCursor : cursor.visible


    Cursor {
        id : cursor
        height : parent.height * 0.7 - 5
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        id : pathText
        width : parent.width - cursor.width
        height : parent.height
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        text : uid
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    Rectangle { //borderrect
        border.width: 1
        anchors.fill: parent
        color : 'transparent'
    }

    MouseArea {
        anchors.fill: parent
        onClicked : rootObject.clicked();
    }


}
