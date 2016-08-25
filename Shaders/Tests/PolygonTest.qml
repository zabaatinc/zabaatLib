import QtQuick 2.5
import "../"
Rectangle {
    color : 'yellow'

    Polygon {
        width : parent.width/2
        height : parent.height/2
        anchors.centerIn: parent
        color : "blue"
    }


        Rectangle {
            width : parent.width/2
            height : parent.height/2
            anchors.centerIn: parent
            border.width: 1
            color : 'transparent'
        }

}
