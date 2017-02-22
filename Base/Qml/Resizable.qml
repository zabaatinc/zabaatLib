import QtQuick 2.5
//let's the target be resized but not out of the constraint item
//assumes that the constraint item is either parent or sibling!!
Item {
    id : rootObject
    property var target         : parent
    property var constraintItem : target && target.parent ? target.parent : null;
    property real iconSz : 8
    property real radius : iconSz/2
    property color color : "steelblue"
    property real minSize: iconSz * 2
    property real msAreaSize : iconSz * 1.5

    width  : iconSz
    height : iconSz
//    anchors.right : parent.right
//    anchors.bottom: parent.bottom
//    anchors.margins: -iconSz/2
    anchors.fill: target

    Rectangle {
        id : lf
        width  : iconSz
        height : iconSz
        radius : rootObject.radius
        color  : rootObject.color
        anchors.horizontalCenter: parent.left
        anchors.verticalCenter  : parent.verticalCenter
        MouseArea {
            width : msAreaSize
            height: msAreaSize
            anchors.centerIn: parent
            drag.target: parent
            drag.axis: Drag.XAxis
            onMouseXChanged: {
                if(!drag.active || !target)
                    return;

                var rightEdge = target.x + target.width;
                var rw = Math.max(target.width - mouseX , minSize);
                var rx = target.width !== rw ? target.x + mouseX : target.x
                if(constraintItem) {
                    var min = 0
                    var max = constraintItem.width
                    if(constraintItem !== target.parent) {
                        min = constraintItem.x;
                        max += constraintItem.x;
                    }

                    if(rx < min) {
                        rw -= (min - rx);
                        rx  = min;
                    }
                    else if(rx + rw > max) {
                        rx = max - rw;
                    }
                }

                //conserve right edge
                var pastRightEdge = (rx + rw) - rightEdge;
                if(pastRightEdge > 0) {
                    rx -= pastRightEdge;
                }

                target.width = rw;
                target.x     = rx;
            }
        }

    }
    Rectangle {
        id : rt
        width  : iconSz
        height : iconSz
        radius : rootObject.radius
        color  : rootObject.color
        anchors.horizontalCenter: parent.right
        anchors.verticalCenter  : parent.verticalCenter
        MouseArea {
            width : msAreaSize
            height: msAreaSize
            anchors.centerIn: parent
            drag.target: parent
            drag.axis: Drag.XAxis
            onMouseXChanged: {
                if(!drag.active || !target)
                    return;

                var rw = Math.max(target.width + mouseX , minSize);
                if(constraintItem) {

                    var max = constraintItem.width
                    if(constraintItem !== target.parent)
                        max += constraintItem.x;

                    var outsideBounds = (target.x + rw) - max
                    if(outsideBounds > 0) {
                        rw -= outsideBounds;
                    }
                }

                target.width = rw;
            }
        }
    }
    Rectangle {
        id : tp
        width  : iconSz
        height : iconSz
        radius : rootObject.radius
        color  : rootObject.color
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter  : parent.top
        MouseArea {
            width : msAreaSize
            height: msAreaSize
            anchors.centerIn: parent
            drag.target: parent
            drag.axis: Drag.YAxis
            onMouseYChanged: {
                if(!drag.active || !target)
                    return;

                var bottomEdge = target.y + target.height;
                var rh = Math.max(target.height - mouseY , minSize);
                var ry = target.y + mouseY;

                if(constraintItem) {

                    var min = 0;
                    var max = constraintItem.height;

                    if(constraintItem !== target.parent) {
                        min = constraintItem.y;
                        max += constraintItem.y;
                    }

//                    console.log(ry, min);
                    if(ry < min) {
                        rh -= (min - ry);
                        ry  = min;
                    }
                    else if(ry + rh > max) {
                        ry = max - rh;
                    }
                }

                //conserve bottom edge
                var pastEdge = (ry + rh) - bottomEdge;
                if(pastEdge > 0) {
                    ry -= pastEdge;
                }


                target.height = rh;
                target.y = ry;
            }
        }
    }
    Rectangle {
        id : dn
        width  : iconSz
        height : iconSz
        radius : rootObject.radius
        color  : rootObject.color
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter  : parent.bottom
        MouseArea {
            width : msAreaSize
            height: msAreaSize
            anchors.centerIn: parent
            drag.target: parent
            drag.axis: Drag.YAxis
            onMouseYChanged: {
                if(!drag.active || !target)
                    return;

                var rh = Math.max(target.height + mouseY , minSize);
                if(constraintItem) {
                    var max = constraintItem.height
                    if(constraintItem !== target.parent)
                        max += constraintItem.y;

                    var outsideBounds = (target.y + rh) - max
                    if(outsideBounds > 0) {
                        rh -= outsideBounds;
                    }
                }

                target.height = rh;
            }
        }
    }






}
