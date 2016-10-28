import Zabaat.Utility 1.0
import QtQuick 2.5
import Zabaat.Base 1.0
Rectangle {
    id : rootObject
    property alias text : text.text;
    property alias textPtr : text
    property point origin : Qt.point(width/2,height/2);
    property real bubbleSize : 64
    radius: Math.max(width,height)/16
    property real distBetweenBubbles : 100;
    border.width: 1
    color : 'aqua'


    onWidthChanged             : bubbleContainer.create();
    onHeightChanged            : bubbleContainer.create();
    onXChanged                 : bubbleContainer.create();
    onYChanged                 : bubbleContainer.create();
    onOriginChanged            : bubbleContainer.create();
    onDistBetweenBubblesChanged: bubbleContainer.create();

    Text {
        id : text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.fill: parent
    }
    Component {
        id : bubbleFactory
        Rectangle {
            color : rootObject.color
            width :  rootObject.bubbleSize;
            height : rootObject.bubbleSize;
            radius: height/2
            border.width: rootObject.border.width;
            border.color: rootObject.border.color;
        }
    }



    Rectangle {
        id : bubbleContainer
        color : 'yellow'
        anchors.fill: parent
        parent : rootObject && rootObject.parent ? rootObject.parent : null;
        opacity: 0.5

        function clear(){
            Lodash.eachRight(children, function(v,k) {
                v.destroy();
            })
        }
        function create(){
            clear();
            var begin = getStartingPtAndDistance();
            var pt = mapToItem(bubbleContainer, begin.pt.x, begin.pt.y);
            var numBubbles = Math.floor(begin.dist / distBetweenBubbles);


//            console.log(pt.x, pt.y, numBubbles);
//            var m = getSlope(pt,origin);
//            var c = getYIntercept(pt, m);
            //so our line is
            //y = mx + c   and we have the 2 consts m & c now.
//            Lodash.times(numBubbles, function(i) {
//                var bubble   = bubbleFactory.createObject(bubbleContainer);
//                var perc     = i/numBubbles;
//                bubble.scale = (1 - perc);
//                bubble.x     = (pt.x + origin.x) * perc;
//                bubble.y     = (pt.y + origin.y) * perc;
//            })
            var bubble = bubbleFactory.createObject(bubbleContainer);
            bubble.x = pt.x;
            bubble.y = pt.y;

//            console.log("FINITO", bubbleContainer.children.length);

        }

        function getStartingPtAndDistance() {
            //use 4 center edges of the bubble and determine what is the shortest!!
            var arr = [
                { pt : { x : rootObject.x + width/2, y : rootObject.y + 0       }  , dist : Number.MAX_VALUE },
                { pt : { x : rootObject.x + width/2, y : rootObject.y + height  }  , dist : Number.MAX_VALUE },
                { pt : { x : rootObject.x + 0      , y : rootObject.y + height/2}  , dist : Number.MAX_VALUE },
                { pt : { x : rootObject.x + width  , y : rootObject.y + height/2}  , dist : Number.MAX_VALUE },
            ]

            arr[0].dist = distance(arr[0].pt , origin);
            arr[1].dist = distance(arr[1].pt , origin);
            arr[2].dist = distance(arr[2].pt , origin);
            arr[3].dist = distance(arr[3].pt , origin);

            var dist = Math.min(arr[0].dist, arr[1].dist, arr[2].dist, arr[3].dist);
            var pt   = Lodash.find(arr,function(a) {
                return a.dist === dist
            })
            return { pt : pt.pt, dist : dist }
        }

        function distance(pt1,pt2){
            var x1 = pt1.x;     var x2 = pt2.x;
            var y1 = pt1.y;     var y2 = pt2.y;
            return Math.sqrt( Math.pow(x2-x1,2) + Math.pow(y2-y1,2) )
        }

        function getSlope(pt1,pt2){
            var x1 = pt1.x;     var x2 = pt2.x;
            var y1 = pt1.y;     var y2 = pt2.y;
            return (y2-y1)/(x2-x1);
        }

        function getYIntercept(pt,m){
            return pt.y - (m * pt.x)
        }




    }

}
