import QtQuick 2.4
import Zabaat.Material 1.0
ZObject{
    objectName : "ZHoldButton"
    signal pressed(var self)
    signal clicked(var self, int x, int y)
    clip : false

    property int  holdDuration       : 0
    property int  triggerDuration    : 500
    property bool containsMouse      : false
    property string text             : ""

//    onHoldDurationChanged: console.log(holdDuration, "ms")

    debug                  : false
    onPressed              : log(self, "pressed")
    onClicked              : log(self, "clicked"      , x,  y)
    onContainsMouseChanged : log(this, "containsMouse", containsMouse )
}
