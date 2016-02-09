import QtQuick 2.4
import QtGraphicalEffects 1.0
import Zabaat.Material 1.0
Item {
    id             : rootObject
    height         : 40//bar.height * 1.6
    width          : height
    transformOrigin: Item.Center
    smooth         : true

    property color color    : "red"//graphical.knobColor
    property color spillColor      : color
    property color inkColor        : "blue"
    property real  spillScale      : 2

    property bool dragEnabled : false
    property int  minDrag    : 0
    property int  maxDrag    : 1000

    readonly property alias containsMouse : ma.containsMouse
    readonly property double radius  : height/2
    property alias acceptedButtons   : ma.acceptedButtons
    property bool isPressed          : false

    signal        pressed()
    signal        released()
    signal        dragFinished(int x)
    signal        dragging(int x)

    onXChanged: if(ma.drag.active)
                    dragging(x)

    Rectangle {
        id              : spill
        anchors.fill    : parent
        scale           : isPressed ? spillScale : 0
        radius          : parent.radius
        color           : spillColor
        opacity         : 0.3
        Behavior on scale { NumberAnimation { duration : 555 } }
    }
    Rectangle {
        id : knob
        color       : parent.color
        anchors.fill: parent
        radius      : parent.radius
    }

    Rectangle   { id : mask;          anchors.fill: parent;     radius    : parent.radius; visible : false;   }
    ZInk        { id : ink ;          color: inkColor;          msArea    : ma;            visible : false    }
    OpacityMask { anchors.fill: mask; source: ink;              maskSource: mask;          opacity : 0.5;     }
    MouseArea {
        id : ma
        anchors.centerIn: parent
        width : parent.width * 1.5
        height : parent.height * 1.5
        drag.axis       : Drag.XAxis
        drag.minimumX   : minDrag
        drag.maximumX   : maxDrag
        drag.target     : dragEnabled ? rootObject : null
        drag {
            onActiveChanged : if(!active) dragFinished(knob.x)
        }

//        scale           : 1.25
        acceptedButtons : Qt.AllButtons
        onPressed       : { rootObject.isPressed = true; ink.tap(); }
        onReleased      : {
            rootObject.isPressed = false;
            ink.lockMouse()
            if(ma.containsMouse)    ink.end("grow"  , emitSignal, "released")
            else                    ink.end("shrink", emitSignal, null)
        }

        function emitSignal(signalName){
            if(signalName)
                rootObject[signalName]()
        }
    }

}
