import QtQuick 2.5
import Zabaat.Utility 1.0
import QtQuick.Controls 1.4
import Zabaat.Material 1.0
import Zabaat.HelperTools 1.0
Item {
    id : rootObject

    ListView {
        id : lv
        width : parent.width
        height : parent.height * 0.8
        snapMode : ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        orientation: ListView.Horizontal
        model : ListModel {
            ListElement { grp : "A" ; }
            ListElement { grp : "A" ; }
            ListElement { grp : "A" ; }
            ListElement { grp : "A" ; }
            ListElement { grp : "A" ; }
            ListElement { grp : "B" ; }
            ListElement { grp : "B" ; }
            ListElement { grp : "B" ; }
            ListElement { grp : "C" ; }
            ListElement { grp : "C" ; }
            ListElement { grp : "C" ; }
            ListElement { grp : "C" ; }
            ListElement { grp : "D" ; }
            ListElement { grp : "D" ; }
            ListElement { grp : "D" ; }
            ListElement { grp : "D" ; }
            ListElement { grp : "D" ; }
            ListElement { grp : "D" ; }
            ListElement { grp : "D" ; }
            ListElement { grp : "E" ; }
            ListElement { grp : "E" ; }
            ListElement { grp : "E" ; }
            ListElement { grp : "E" ; }
            ListElement { grp : "F" ; }
            ListElement { grp : "F" ; }
            ListElement { grp : "G" ; }
            ListElement { grp : "G" ; }
            ListElement { grp : "H" ; }
            ListElement { grp : "H" ; }
            ListElement { grp : "I" ; }
            ListElement { grp : "J" ; }
            ListElement { grp : "K" ; }
            ListElement { grp : "L" ; }
            ListElement { grp : "M" ; }
            ListElement { grp : "N" ; }
            ListElement { grp : "O" ; }
            ListElement { grp : "P" ; }
            ListElement { grp : "Q" ; }
            ListElement { grp : "R" ; }
            ListElement { grp : "S" ; }
            ListElement { grp : "T" ; }
            ListElement { grp : "U" ; }
            ListElement { grp : "V" ; }
            ListElement { grp : "W" ; }
            ListElement { grp : "X" ; }
            ListElement { grp : "Y" ; }
            ListElement { grp : "Z" ; }
            ListElement { grp : "Za" ; }
            ListElement { grp : "Zb" ; }
            ListElement { grp : "Zc" ; }
        }
        preferredHighlightBegin: (lv.width - cellWidth)/2
        preferredHighlightEnd  : (lv.width - cellWidth)/2
        property real cellWidth : width/3
        highlightMoveDuration : 333
        delegate : Text {
            font.pointSize: 32
            text : grp + " " + index
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            width : lv.cellWidth
            height : lv.height
            ZTracer {}
            Rectangle {
                anchors.fill: parent
                opacity : lv.currentIndex === index ? 0.5 : 0
                color : 'green'
            }
        }
    }

    ZRolodex {
        width : parent.width
        height : parent.height - lv.height
        anchors.bottom: parent.bottom
        model : lv.model
        onPressed: lv.currentIndex = index;
        prefferedDelegateSize: 64
        groupFunc: function(a) {
            return a.grp;
        }
        delegate : Component {
            ZButton {
                property var model
                property int index
                text : model? model.group : ""
                state : 'b1'
                Text {
                    text : parent.width + "," + parent.height
                }
            }
        }

    }

}
