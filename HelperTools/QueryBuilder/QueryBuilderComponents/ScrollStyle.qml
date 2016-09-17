import QtQuick 2.5
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4
ScrollViewStyle {
    id : rootObject
    property color color : "red"

    Component { id : blank; Item {} }


    scrollBarBackground: Item {
        property int w : Screen.width * 0.015
        implicitWidth  : w
        implicitHeight : w
    }
    incrementControl: blank
    decrementControl: blank
    corner : blank
    frame  : blank
    transientScrollBars : true
    handle : Item {
        property int w : Screen.width * 0.015
        implicitWidth  : w
        implicitHeight : w
        z : Number.MAX_VALUE
        Rectangle {
            color: rootObject.color
            opacity : 0.9
            anchors.fill: parent
            anchors.topMargin: 6
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            anchors.bottomMargin: 6
            radius : 10
            border.width: 1
        }
    }
//            transientScrollBars: true
}
