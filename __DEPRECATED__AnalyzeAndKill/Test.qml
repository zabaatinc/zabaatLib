import QtQuick 2.0
import Zabaat.Utility 1.0
import Zabaat.Material 1.0
Item {
    id : rootObject

    property real cellWidth : rootObject.width / columns
    property real cellHeight: pv.height;
    property alias columns  : colSlider.value

    PathView {
        id : pv
        model : 358
        width : parent.width
        height : parent.height/4
        anchors.centerIn: parent
        pathItemCount : columns
        cacheItemCount: 4
        delegate: Item {
            width :  cellWidth
            height : cellHeight
            Rectangle {
                id : dr
                anchors.centerIn: parent
                width :  cellWidth
                height : cellHeight

                color : isCurrent ? 'red' : 'yellow'
                Text {
                    anchors.fill: parent
                    text : index
                    font.pointSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color : parent.isCurrent ? 'white' : 'black'
                }
                border.width: 1
                property bool isCurrent : pv.currentIndex === index
            }
            z : dr.isCurrent  ? Number.MAX_VALUE : (pv.count - index);
        }
        path : Path {
            startX : 0
            startY : startYSlider.value;
            PathLine { x : pv.width ; y : startYSlider.value }
        }
        preferredHighlightBegin: 0.5
        preferredHighlightEnd  : 0.5
//        highlightRangeMode: ListView.StrictlyEnforceRange
        snapMode          : ListView.NoSnap
    }

    ZTracer {
        anchors.fill: pv
        color : 'green'
    }

    Text {
        anchors.bottom: pv.top
        text : pv.currentIndex
        font.pointSize: 20
        anchors.horizontalCenter: parent.horizontalCenter

    }



    Column {
        id : controls
        width : parent.width
        height : childrenRect.height
        spacing : 10
        anchors.bottom: parent.bottom
        ZSlider {
            id : colSlider
            width : parent.width/2
            height : rootObject.height * 0.1
            anchors.horizontalCenter: parent.horizontalCenter
            value : 15
            min : 5
            max : 100
            label :"columns"
            state : "default"
            isInt: true
        }
        ZSlider {
            id : startXSlider

            width : parent.width/2
            height : rootObject.height * 0.1
            anchors.horizontalCenter: parent.horizontalCenter
            value : cellWidth/2
            min : 0
            max : pv.width/2
            label :"startX"
            state : "default"
        }
        ZSlider {
            id : startYSlider
            width : parent.width/2
            height : rootObject.height * 0.1
            anchors.horizontalCenter: parent.horizontalCenter
            value : cellHeight
            min : 0
            max : pv.height/2
            label :"startY"
            state : "default"
        }

    }



//    Rectangle {
//        id : pt1
//        x : 100
//        y : 100
//        width : height
//        height : 48
//        border.width: 1
//        radius : height/2
//        MouseArea {
//            anchors.fill: parent
//            drag.target: parent
//            onClicked : rootObject.forceActiveFocus()
//        }
//    }

//    Rectangle {
//        id : pt2
//        x : 300
//        y : 100
//        width : height
//        height : 48
//        border.width: 1
//        radius : height/2
//        MouseArea {
//            anchors.fill: parent
//            drag.target: parent
//            onClicked : rootObject.forceActiveFocus()
//        }
//    }

//    Line {
//        id : line
//        p1 : Qt.point(pt1.x + pt1.width/2,pt1.y + pt1.height/2)
//        p2 : Qt.point(pt2.x + pt2.width/2,pt2.y+pt2.height/2)
//        thickness : 10
//        color : 'red'
//    }

//    Keys.onUpPressed: line.thickness++
//    Keys.onDownPressed: line.thickness--

//    Diamond {
//        id : diamond
//        anchors.centerIn: parent
//        width : parent.width/2
//        height : parent.height/2
//        color : 'yellow'
//        emptyColor: "transparent"
//        border.color: "red"
//        border.width : 1
//    }

//    Column {
//        anchors.bottom: parent.bottom
//        anchors.horizontalCenter: parent.horizontalCenter
//        width : 320
//        height  : 100
//        anchors.margins: 5
//        ZSlider {
//            value : 0
//            min : 0
//            max : 1
//            width : parent.width
//            height : parent.height/2
//            state : "default"
//            onValueChanged : diamond.value= value;
//            ZButton {
//                anchors.left: parent.right
//                text : "FILL STYLE"
//                width : parent.height
//                height : parent.height
//                onClicked : diamond.fillsVertically = !diamond.fillsVertically
//            }
//        }

//        ZSlider {
//            value : 1
//            min : 0
//            max : 20
//            width : parent.width
//            height : parent.height/2
//            onValueChanged : diamond.border.width = value;
//        }

//    }







}
