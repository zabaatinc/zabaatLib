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
    property bool maintainAspectRatio : false;


    Item {
        id : freeFromResize
        anchors.fill: parent
        visible     : !maintainAspectRatio
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
    Item {
        id : aspectRatioResize
        anchors.fill: parent
        visible     : maintainAspectRatio

        Rectangle {
            id     : aspectResizer
            width  : iconSz
            height : iconSz
            radius : rootObject.radius
            color  : rootObject.color
            anchors.horizontalCenter: parent.right
            anchors.verticalCenter  : parent.bottom
            MouseArea {
                width : msAreaSize
                height: msAreaSize
                anchors.centerIn: parent
                drag.target: parent
                property point ratio
                property alias target : rootObject.target

                Timer { id : dragMutex;  interval : 10; }

                onMouseXChanged: {
                    if(!drag.active || !target || ratio.x === 0 || ratio.y === 0)
                        return;

                    if(!dragMutex.running){
                        dragMutex.start()
                        handleDrag(mouseX,0);
                    }
                }
                onMouseYChanged: {
                    if(!drag.active || !target || ratio.x === 0 || ratio.y === 0)
                        return;

                    if(!dragMutex.running){
                        dragMutex.start()
                        handleDrag(0,mouseY);
                    }
                }
                onTargetChanged: {
                    if(target) {
                        var w = target.width
                        var h = target.height
                        return ratio = Qt.point(w/h, h/w);
                    }
                    return ratio = Qt.point(0,0);
                }

                function handleDrag(x,y) {
                    var target = rootObject.target
                    function resizeX(mag) {
                        var newW = target.width + mag;

                        if(constraintItem){
                            var max = constraintItem.width;
                            if(target.parent !== constraintItem) {
                                max += constraintItem.x;
                            }

                            var edge = target.x + target.width;
                            var diff = max - edge;
                            if(diff < 0)
                                newW += diff;
                        }

                        var newH = newW * ratio.y;
                        resize(newW,newH);
                    }
                    function resizeY(mag) {
                        var newH = target.height + mag;

                        if(constraintItem){
                            var max = constraintItem.height;
                            if(target.parent !== constraintItem) {
                                max += constraintItem.y;
                            }

                            var edge = target.y + target.height;
                            var diff = max - edge;
                            if(diff < 0)
                                newH += diff;
                        }

                        var newW = newH * ratio.x;
                        resize(newW,newH);
                    }
                    function resize(w,h) {
                        target.width  = w;
                        target.height = h;
                    }

                    return Math.abs(x) > Math.abs(y) ? resizeX(x) : resizeY(y);
                }
            }

        }
    }






}
