import Zabaat.Material 1.0
import QtQuick 2.4
import QtGraphicalEffects 1.0
import "ZSpinner"
//Default button, flat style
Item {
    id : rootObject
    property int   numDelegatesVisible : -1
    property alias lv                  : lv
    property alias model               : lv.model
    property alias currentIndex        : lv.currentIndex
    property alias currentItem         : lv.currentItem
    property alias delegate            : lv.delegate
    property int   cellHeight          : rootObject.height * 0.1
    property bool  shrink    : false
    property DefaultDelegateOptions defaultDelegate : DefaultDelegateOptions{}

    ListView {
        id : lv
        width  : parent.width
        height : Math.max(0, shrink ? cellHeight: parent.height)
//        onHeightChanged: console.log("HEIGHTERTS :: " , height)
        anchors.centerIn: parent
        clip   : true
        model  : 20

        onCurrentIndexChanged: {
//            console.log("CurrentIndex", currentIndex, width ,height, contentY)
            positionViewAtIndex(currentIndex, ListView.Center)
        }

        property real angleDifferencePerIndex : (90/numDels)
        property int numDels : parent.numDelegatesVisible === -1 ? Math.floor(parent.height/cellHeight) : parent.numDelegatesVisible

        onVerticalVelocityChanged: {
            if(shrink) {
                if(verticalVelocity !== 0)   lv.height = cellHeight * lv.numDels
                else                          closeTimer.start()
            }
        }
        preferredHighlightBegin: (lv.height - cellHeight)/2
        preferredHighlightEnd  : (lv.height - cellHeight)/2
        highlightRangeMode: ListView.StrictlyEnforceRange
        snapMode          : ListView.NoSnap
//        highlightMoveDuration: 300
//                    highlightFollowsCurrentItem: true
//                    snapMode           : ListView.SnapOneItem
//                    highlightRangeMode : ListView.StrictlyEnforceRange
//                    contentY: currentIndex * (lv.height * 0.1)
//        onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Center)
        delegate : btnCmp

        Component {
            id : btnCmp
                ZButton {
                id : delItem
                property real angle : (lv.currentIndex - index) * lv.angleDifferencePerIndex
                property real radians : angle * Math.PI/180
                property int indDiff : Math.abs(lv.currentIndex - index)

                width     : lv.width
                height    : cellHeight //* Math.abs(Math.cos(radians))
                text      : defaultDelegate.displayFunc ? defaultDelegate.displayFunc(index,model) : index
                onClicked : lv.currentIndex = index
                enabled   : lv.currentIndex !== index
                disableShowsGraphically: false
                state   : !enabled ? defaultDelegate.state_Selected : defaultDelegate.state_UnSelected
                scale   : 1 - (indDiff / lv.count)
                visible : indDiff < lv.numDels
                opacity : 1 - (indDiff / lv.count)
                transform : Rotation {
                    id : _rot
                    axis.x : 1;
                    axis.y : 0;
                    axis.z : 0;
                    angle  : delItem.angle
                }
            }
        }


        MouseArea {
            anchors.fill: parent ;
            propagateComposedEvents: true;
            onPressed: {
                lv.height = cellHeight * lv.numDels
                mouse.accepted = false;
            }
            enabled : shrink
        }
        Timer {
            id : closeTimer
            interval : 1500
            onTriggered: lv.height = rootObject.cellHeight
        }
        Rectangle {
            anchors.fill: parent
            border.width: 1
            color       : "transparent"
            visible     : shrink
        }

        Behavior on height { NumberAnimation { duration : 300 } }
    }



}
