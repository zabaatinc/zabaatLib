import QtQuick 2.5

//Lets you pick a subrect on an image
Item {
    id : rootObject
    //is percentage of the image!!
    readonly property rect subRect : Qt.rect(cropRect.x/controls.width,
                                             cropRect.y/controls.height,
                                             cropRect.width/controls.width,
                                             cropRect.height/controls.height)

    property alias source          : img.source

    property color barColor: "black"
    property real barOpacity : 0.9

    property bool resizeEnabled        : true
    property real resizeMouseAreaScale : 3
    property bool preserveRatio        : true
    property point ratio               : Qt.point(1,1);

    onRatioChanged: logic.ratioChangeFunc()

    QtObject {
        id : logic
        //rootObject.ratio expressed in lowest terms
        property point lowestRatio : Qt.point(1,1)

        //maintains the maximum size that the crop can get to (depending on the lowestRatio)
        property point maxSize : {
            var w = controls.width
            var h = controls.height
            var x = lowestRatio.x
            var y = lowestRatio.y

//            console.log("w", w, 'h', h,'rx', x,'ry',y)
            if(x > y) {
                //width is larger, so height = would be  width * y/x. if we don't have this much height
                //then we should go about the other way around and then determine width from the height
                var reqHeight = w * y/x
                if(h >=  reqHeight){
//                    console.log('case 1')
//                    console.log("MAX =", Qt.point(w,reqHeight))
                    return Qt.point(w, reqHeight)
                }
                else{
//                    console.log('case 2')
                    return Qt.point(h * x/y, h)
                }
            }
            else if(y > x){
                var reqWidth = w * x/y
                if(w >= reqWidth){
//                    console.log('case 3')
                    return Qt.point(reqWidth, h)
                }
                else {
//                    console.log('case 4')
                    return Qt.point(w, w * y/x)
                }
            }
//            console.log('case 5')
            return Qt.point(w, h)
        }

        function ratioChangeFunc(){
            lowestRatio = lowerRatioToLowestTerms(ratio);
            cropRect.width  = Qt.binding(function() { return maxSize.x  })
            cropRect.height = Qt.binding(function() { return maxSize.y  })
        }
        function lowerRatioToLowestTerms(ratio){
            var w = ratio.x
            var h = ratio.y

            if(w > h) {
                w = w/h
                h = 1
            }
            else if(w < h) {
                h = h/w
                w = 1
            }
            else
                w = h = 1
            return Qt.point(w,h)
        }
    }

    Item {
        id : gui
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color : barColor
            opacity: barOpacity
        }
        Image  {
            id : img
            anchors.fill: parent
            fillMode : Image.PreserveAspectFit
        }

        Item {
            id : controls
            property real safePadding : 2
            width : Math.ceil(img.paintedWidth)       //we always do ceiling so as to not have a missing pixel
            height: Math.ceil(img.paintedHeight)      //same as above
            anchors.centerIn: img

            Rectangle {
                id : cropRect
                color  : 'transparent'
                x      : (parent.width - width)/2
                y      : (parent.height - height)/2
                width  : 300
                height : 300

                MouseArea {
                    id: moveArea
                    anchors.fill: cropRect
                    drag.target: parent
                    drag.minimumX: 0
                    drag.maximumX: controls.width - cropRect.width
                    drag.minimumY: 0
                    drag.maximumY: controls.height - cropRect.height
                }
                Rectangle {
                    id     : edit_resizeCircle
                    border.color: "black"
                    border.width: 2

                    width  : 15
                    height : 15
                    radius : 7
                    enabled : resizeEnabled
                    x : enabled ? cropRect.width  - width/2  : 0
                    y : enabled ? cropRect.height - height/2 : 0

                    MouseArea {
                        id : resizeArea
                        hoverEnabled: true
                        anchors.centerIn: parent
                        width : parent.width * resizeMouseAreaScale
                        height : parent.height * resizeMouseAreaScale

                        drag.target : parent

                        onPressed : {myTimer.start(); myTimer.oldX = parent.x; myTimer.oldY = parent.y }
                        onReleased: myTimer.stop()

                        Timer {
                            property int oldX : 0
                            property int oldY : 0
                            id : myTimer
                            interval : 20
                            repeat: true
                            running :false
                            onTriggered: {
                                var deltaX = oldX - edit_resizeCircle.x
                                var deltaY = oldY - edit_resizeCircle.y

                                if(rootObject.preserveRatio) {
                                    if(ratio.x > ratio.y){
                                        deltaY = deltaX * ratio.y / ratio.x
                                    }
                                    else {
                                        deltaX = deltaY * ratio.x / ratio.y
                                    }
                                }

                                cropRect.width  -= deltaX
                                cropRect.height -= deltaY


                                oldX = edit_resizeCircle.x //= cropRect.width  - edit_resizeCircle.width/2
                                oldY = edit_resizeCircle.y //= cropRect.height - edit_resizeCircle.height/2
                            }
                        }
                    }
                }

                z : Number.MAX_VALUE
            }


            //bars
            Rectangle {
                id : barLeft
                color : barColor
                opacity: barOpacity
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left : parent.left
                anchors.right: cropRect.left
            }
            Rectangle {
                id : barTop
                color : barColor
                opacity: barOpacity

                anchors.left  : cropRect.left
                anchors.right : cropRect.right
                anchors.top   : parent.top
                anchors.bottom: cropRect.top
            }
            Rectangle {
                id : barBottom
                color : barColor
                opacity: barOpacity

                anchors.left  : cropRect.left
                anchors.right : cropRect.right
                anchors.top   : cropRect.bottom
                anchors.bottom: parent.bottom
            }
            Rectangle {
                id : barRight
                color : barColor
                opacity: barOpacity

                anchors.left : cropRect.right
                anchors.right: parent.right
                anchors.top  : parent.top
                anchors.bottom: parent.bottom
            }


        }







    }





}

