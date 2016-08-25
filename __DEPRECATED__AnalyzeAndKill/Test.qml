import QtQuick 2.0
import Zabaat.Utility 1.0
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

}
