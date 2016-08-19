import QtQuick 2.5
Item {
    id : rootObject
    clip : true

    signal clicked();
    property var m
    property int time    : m ? m.time : -1
    property var res     : m ? m.res  : undefined
    property string path : m ? m.path : ""
    property string type : m ? m.type : ""

    property alias showCursor : cursor.visible

    Rectangle {
        id : titleBar
        width : parent.width
        height : parent.height * 0.3
        color : {
            switch(type) {
                case 'set'   : return Qt.rgba(0,1,0.5);
                case 'get'   : return Qt.rgba(1,0.1,0);
                case 'del'   : return Qt.rgba(1,0.1,0);
                case 'reset' : return Qt.rgba(0.2,0.2,0.2);
                default      : return Qt.rgba(0,0.5,1);
            }
        }


        Item {
            id : textArea
            anchors.fill: parent
            Text {
                anchors.fill: parent
                anchors.margins: 5
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                text : type
            }

            Text {
                anchors.fill: parent
                anchors.margins: 5
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                text : time + " ms"
            }
        }

        SequentialAnimation  {
            loops : Animation.Infinite
            running : !res
            ColorAnimation  {
                target : titleBar
                duration : 1000
                properties : 'color'
                from : 'red'
                to : 'darkred'
            }
            ColorAnimation  {
                target : titleBar
                duration : 1000
                properties : 'color'
                to : 'red'
                from : 'darkred'
            }
        }
    }

    Cursor {
        id : cursor
        height : parent.height - titleBar.height - 5
        anchors.bottom : parent.bottom
    }

    Text {
        id : pathText
        width : parent.width - cursor.width
        height : parent.height - titleBar.height
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        text : path
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
