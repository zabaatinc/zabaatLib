import QtQuick 2.0

Item {
    id : arrowHead
    width : 128
    height: 128

    property alias thickness : rect1.height
    property alias color     : rect1.color

    property real a     : width/2
    property real b     : height
    property real hyp   : Math.sqrt((a * a) + (b * b))
    property real theta : (Math.atan2(b, a) * 180/Math.PI  - thickness/2)

    Rectangle {
        id : rect1
        width           : parent.hyp
        height          : 4
        rotation        : -parent.theta
        color           : "black"
        transformOrigin : Item.BottomLeft
        anchors.left    : parent.left
        anchors.bottom  : parent.bottom
    }
    Rectangle {
        id : rect2
        width           : parent.hyp
        height          : parent.thickness
        rotation        : parent.theta
        color           : parent.color
        transformOrigin : Item.BottomRight
        anchors.right   : parent.right
        anchors.bottom  : parent.bottom
    }


}


