import QtQuick 2.0
import Zabaat.Utility 1.0
import Zabaat.Material 1.0
Item {
    id : rootObject

    Rectangle {
        id : pt1
        x : 100
        y : 100
        width : height
        height : 48
        border.width: 1
        radius : height/2
        MouseArea {
            anchors.fill: parent
            drag.target: parent
            onClicked : rootObject.forceActiveFocus()
        }
    }

    Rectangle {
        id : pt2
        x : 300
        y : 100
        width : height
        height : 48
        border.width: 1
        radius : height/2
        MouseArea {
            anchors.fill: parent
            drag.target: parent
            onClicked : rootObject.forceActiveFocus()
        }
    }

    Line {
        id : line
        p1 : Qt.point(pt1.x + pt1.width/2,pt1.y + pt1.height/2)
        p2 : Qt.point(pt2.x + pt2.width/2,pt2.y+pt2.height/2)
        thickness : 10
        color : 'red'
    }

    Keys.onUpPressed: line.thickness++
    Keys.onDownPressed: line.thickness--

    Diamond {
        id : diamond
        anchors.centerIn: parent
        width : parent.width/2
        height : parent.height/2
        color : 'yellow'
        emptyColor: "transparent"
        border.color: "red"
        border.width : 1
    }

    Column {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width : 320
        height  : 100
        anchors.margins: 5
        ZSlider {
            value : 0
            min : 0
            max : 1
            width : parent.width
            height : parent.height/2
            state : "default"
            onValueChanged : diamond.value= value;
            ZButton {
                anchors.left: parent.right
                text : "FILL STYLE"
                width : parent.height
                height : parent.height
                onClicked : diamond.fillsVertically = !diamond.fillsVertically
            }
        }

        ZSlider {
            value : 1
            min : 0
            max : 20
            width : parent.width
            height : parent.height/2
            onValueChanged : diamond.border.width = value;
        }

    }







}
