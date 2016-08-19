import QtQuick 2.5
Item {
    id : cursor
    width  : visible ? height : 0
    Rectangle {
        id : rect
        anchors.fill: parent
        anchors.margins: 5
        radius : height/2
        border.width: 1
        SequentialAnimation {
            running : true
            loops :Animation.Infinite
            ColorAnimation {
                target : rect
                from: "white"
                to: "black"
                duration: 1000
                properties : "color"
            }
            ColorAnimation {
                target : rect
                properties : "color"
                to: "white"
                from: "black"
                duration: 1000
            }
        }
    }
}
