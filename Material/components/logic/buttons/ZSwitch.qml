import QtQuick 2.4
import Zabaat.Material 1.0
ZObject{
    objectName : "ZSwitch"

    property bool   isOn           : false
    property bool   containsMouse  : false
    property int    duration       : 300

    signal turnedOn()
    signal turnedOff()

    function toggle(){
        isOn = !isOn
    }

    debug                  : false
    onIsOnChanged          : {
        log(this, "isOn", isOn)
        if(isOn)    turnedOn()
        else        turnedOff()
    }
    onContainsMouseChanged : log(this, "containsMouse", containsMouse )
}
