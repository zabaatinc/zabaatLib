import QtQuick 2.5
Rectangle {
    id : line
    color : 'green'
    x : p1.x
    y : p1.y
    transformOrigin: Item.Left
    rotation       : Math.atan2(p2.y - p1.y , p2.x - p1.x)  * 180/Math.PI
    width          : (diff.x * c + diff.y * s)
    height         : 10 //same as thickness

    //added for convenience!
    property alias start    : line.p1
    property alias end      : line.p2

    property point p1       : Qt.point(0,0)
    property point p2       : Qt.point(5,0)
    property vector2d diff  : Qt.vector2d(Math.abs(p2.x - p1.x) , Math.abs(p2.y - p1.y))
    property real s         : Math.abs(Math.sin(rotation * toRad))
    property real c         : Math.abs(Math.cos(rotation * toRad))
    property real toRad     : Math.PI/180

    property alias thickness : line.height
    border.width: 1
}
