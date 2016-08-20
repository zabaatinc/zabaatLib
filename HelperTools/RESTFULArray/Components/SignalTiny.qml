import QtQuick 2.5
Rectangle {
    id : rootObject
    signal clicked();
    property var m
    property string path : m ? m.path : ""
    property string type : m ? m.type : ""
    property var    at   : m ? m.at : null
    property bool   isArrayItem : m  && m.isArrayItem ? true : false
    border.width: 1
    color : type === 'create' ? Qt.rgba(0,1,0.5) :
                                type === 'update' ? Qt.rgba(0,0.5,1) : Qt.rgba(1,0.1,0);

    property alias showCursor : cursor.visible

    Cursor {
        id : cursor
        height : parent.height * 0.7 - 5
        anchors.verticalCenter: parent.verticalCenter
    }

    Item {
        id : textArea
        width : parent.width - cursor.width
        height : parent.height
        anchors.right : parent.right

        Text {
            anchors.fill: parent
            anchors.margins: 5
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            text : type
            font.pixelSize: height * 1/3
        }

        Text {
            anchors.fill: parent
            anchors.margins: 5
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text : at ? Qt.formatTime(at, "hh:mm:ss") : "notime"
            font.pixelSize: height * 1/3
        }

        Text {
            anchors.fill: parent
            anchors.margins: 5
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            text : isArrayItem ? "[" + path + "]" : path
            font.pixelSize: height * 1/3
        }
    }


    MouseArea {
        anchors.fill: parent
        onClicked : rootObject.clicked();
    }


}
