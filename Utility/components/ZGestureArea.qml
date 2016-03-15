import QtQuick 2.0

//QQuickTouchPoint_QML_78(0x2ebed18) {
//  "objectName": "",
//  "pointId": 0,
//  "pressed": true,
//  "x": 307,
//  "y": 371,
//  "pressure": -1,
//  "velocity": {},
//  "area": {},
//  "startX": 0,
//  "startY": 0,
//  "previousX": 0,
//  "previousY": 0,
//  "sceneX": 307,
//  "sceneY": 371,
//  "startingCoords": {}
//}

MultiPointTouchArea {
    id : rootObject
    signal swipe      (string direction, real angle, real distance, point start, point end)
    signal moving     (int id , point start, point end, real angle, real distance, string direction, int numPts)
    signal oneReleased(int id, point start, point end, real angle, real distance, string direction, int numPts)
    signal pinch      (var ids, point pt1  , point pt2, real angle, real distance, string direction, real magnitude)
    signal unpinch    (var ids, point pt1  , point pt2, real angle, real distance, string direction, real magnitude)
    signal allReleased()

    property int pinchThresholdPx     : 10
    property alias unpinchThresholdPx : rootObject.pinchThresholdPx

    property int swipeThresholdPx : Math.min(width,height) * 1/4
    property int swipeDeadZone    : 20
    property int changeThresholPx : 10  //the amount of pixels that are forgiven, if changed
    property bool debugMode       : false


    property var pressedPoints    : []  //the list of points that are currently held down!
    touchPoints : [ WTouchPoint { id: t1  },
                    WTouchPoint { id: t2  } ]

    onPressed : {
        //get list of touchPoints
        for(var i = 0; i < touchPoints.length; i++){
            var pt = touchPoints[i]

            pt.startingCoords = pt.pos
            var date  = new Date()
            pt.ts  = +date

            pressedPoints.push(pt)
        }
    }
    onUpdated : {
        var pts = []
        for(var i = 0; i < touchPoints.length; i++){
            var pt  = touchPoints[i]
            pt.info = logic.pointInfo(pt);

            moving(pt.pointId, pt.info.start, pt.info.end, pt.info.deg, pt.info.dist, logic.getDirection(pt.info.deg), pressedPoints.length);
            pts.push(pt)
        }

       /* if(pressedPoints.length === 1)
            logic.onePtCheck(pressedPoints[pressedPoints.length -1] )
        else*/ if(pressedPoints.length > 1) {
            logic.multiPointCheck(pressedPoints)
        }

    }
    onReleased: {
        var pts = []

        //get all points
        for(var i = 0; i < touchPoints.length; i++){
            var pt = touchPoints[i]
            pts.push(pt)

            for(var j = pressedPoints.length - 1; j >= 0; j--){
                if(pressedPoints[j] === pt){
                    pt.info = logic.pointInfo(pt);
                    pressedPoints.splice(j,1)
                }
            }
        }

        //lets check for things with only one touchPt
        if(touchPoints.length === 1){
            for(i = 0; i < touchPoints.length; i++){
                pt = pts[i]
                logic.onePtCheck(pt, true);
                logic.resetOthers(pt, pts)
            }
        }

        if(pressedPoints.length === 0)
            allReleased();
    }

    QtObject {
        id : logic
        function resetOthers(pt, touchPoints){
            for(var i = 0; i < touchPoints.length; i++){
                var tp = touchPoints[i]
                if(tp !== pt) {
                    var info          = pointInfo(tp);
                    tp.startingCoords = info.pos ? info.pos : Qt.point(0,0)
                    tp.ts             = info.ts
                }
            }
        }

        function pointInfo(pt){
            var end   = Qt.point(pt.x, pt.y)
            var start = pt.startingCoords
            var dist  = getDistance(start,end)
            var deg   = getAngle(start,end)
            var date  = new Date()
            var ts    =  +date

            return {
                end   : end,
                start : start,
                dist  : dist,
                deg   : deg ,
                ts    : ts
            }
        }
        function hasMoved(pt){
            if(pt !== null && typeof pt !== 'undefined'){
                var diffX = Math.abs(pt.x - pt.startingCoords.x)
                var diffY = Math.abs(pt.y - pt.startingCoords.y)

                return diffX > changeThresholPx || diffY > changeThresholPx
            }
            return false;
        }
        function multiPointCheck(pts){
            var moved       = []
            var unmoved     = []
            var ids         = []

            for(var i = 0 ; i < pts.length; i++){
                var pt = pts[i]
                if(hasMoved(pt))          moved.push(pt)
                else                      unmoved.push(pt)

                ids.push(pt.pointId)
            }

            if(pts.length === 2 && moved.length > 0) {
                var pt1 = pts[0]
                var pt2 = pts[1]

                var oldD   = getDistance(pt2.startingCoords, pt1.startingCoords)
                var newD   = getDistance(pt2.pos           , pt1.pos)
                var deltaD = newD - oldD
//                console.log(deltaD, newD, oldD)

                var oldA, newA, deltaA, direction;

                //deltaD is the distance between the 2 points now (ignoring starting distance)
                //deltaA is the angle between the 2 poiins now (ignoring starting angle)

                if(moved.length === 1) { //one point moved while other was anchor
                    var movedPt   = moved[0]
                    var unmovedPt = unmoved[0]

                    oldA = getAngle(pt2.startingCoords, pt1.startingCoords)
                    newA = getAngle(pt2.pos           , pt1.pos)
                    deltaA = newA - oldA
                }
                else if(moved.length === 2){ //two points moved
                    oldA   = getAngle(pt2.startingCoords, pt1.startingCoords)
                    newA   = getAngle(pt2.pos,         pt1.pos)
                    deltaA = newA - oldA
                }

                direction = getDirection(deltaA)
                var mag   = Math.abs(newD / oldD)
//                console.log(deltaA, deltaD, direction)

                if(Math.abs(deltaD) > unpinchThresholdPx){
                    if(deltaD > 0)
                        unpinch(ids, pt1, pt2, deltaA, deltaD, direction, mag)
                    else
                        pinch  (ids, pt1, pt2, deltaA, deltaD, direction, mag)
                }


            }


        }
        function onePtCheck(pt, release){
             //this should already be done
             var info = pt.info
             if(info !== null && typeof info !== 'undefined'){
                 if(release){
                    swipeCheck(info.start,info.end,info.dist,info.deg)
                 }
                 else {
                    oneReleased(pt.pointId, pt.info.start, pt.info.end, pt.info.deg, pt.info.dist, logic.getDirection(pt.info.deg), pressedPoints.length);
                 }

             }
        }
        function swipeCheck(start,end,dist,deg){
            if(dist >= swipeThresholdPx){
                var str = getDirection(deg)
                if(str !== "dead")
                    swipe(str,deg,dist,start,end)
            }
        }
        function getDirection(deg){
            var arr = ["up","left","down","right"]

            deg = niceAngle(deg);   //remaps our angle nicely to 0 - 360
            //deg from 0 - 360
            //45  - 135 up
            //136 - 225 left
            //225 - 315 down
            //315 - 405 right   //if our angle is less than 45, add 360 to it
            if(deg <= 45)
                deg += 360; //to account for resetting back to 0

            var counter = 0;
            for(var i = 45; i < 405; i += 90) {  //45, 135, 225, 315
                var min = i
                var max = i + 90

                if(deg >= min && deg <= max) {
                    //check if we are in the deadzone!
                    if(deg <= min + swipeDeadZone/2 || deg >= max - swipeDeadZone/2)
                        return "dead"
                    return arr[counter];
                }
                counter++
            }
            return "purr"
        }
        function getDistance(pt1, pt2){
            if(pt1 === null || typeof pt1 === 'undefined')  { console.log("pt1 was replaced"); pt1 = t1 }
            if(pt2 === null || typeof pt2 === 'undefined')  { console.log("pt2 was replaced"); pt2 = t2 }

            return Math.sqrt( Math.pow(pt2.x - pt1.x ,2) + Math.pow(pt2.y - pt1.y,2) )
        }
        function getAngle(pt1, pt2){   //with respenct to xAxis as being 0
            if(pt1 === null || typeof pt1 === 'undefined')  { console.log("pt1 was replaced"); pt1 = t1 }
            if(pt2 === null || typeof pt2 === 'undefined')  { console.log("pt2 was replaced"); pt2 = t2 }

            return toDegrees(Math.atan2(pt2.y - pt1.y, pt2.x - pt1.x))
        }
        function niceAngle(deg){
            //Gives us nice 0 to 360 from right (respect to xaxis)
            if(deg > 0)      deg -= 360
            if(deg <= 0)     deg *= -1
            return deg;
        }
        function toDegrees(rad){
            return (rad * 180)/Math.PI
        }

    }

    Item {
        id : debugModeContainer
        anchors.fill: parent
        visible : debugMode
        property int circleSize : Math.max(width,height) * 0.1

        Rectangle {
            width  : height
            height : parent.circleSize
            radius : height/2
            property var target : t1
            color  : target.color
            x      : target.x - width/2
            y      : target.y - height/2
            border.width: 1
            opacity : 0.5
        }
        Rectangle {
            width  : height
            height : parent.circleSize
            radius : height/2
            property var target : t2
            color  : target.color
            x      : target.x - width/2
            y      : target.y - height/2
            border.width: 1
            opacity : 0.5
        }
    }






}
