import QtQuick 2.4
import Zabaat.Material 1.0
ZObject{
    id : rootObject
    objectName : "ZToastSimple"
    signal pressed(var self)
    signal clicked(var self, int x, int y, int button)
    signal doubleClicked(var self, int x , int y, int button)
    signal requestDestruction()

    property bool containsMouse      : false
    property string title            : ""
    property string text             : ""
    property alias  duration         : destructionTimer.interval        //-1 is permanent
    property string closeButtonState : "danger-f2-t2"

    debug                  : false
    onPressed              : log(self, "pressed")
    onClicked              : log(self, "clicked"      , x,  y,  button)
    onDoubleClicked        : log(self, "doubleClicked", x,  y,  button)
    onContainsMouseChanged : log(this, "containsMouse", containsMouse )

    function attemptDestruction(){
        try{
            rootObject.destroy()
        }catch(e){
            console.log("Cannot destroy indestructible object", rootObject, ". Requesting destruction from parent")
            rootObject.requestDestruction()
        }
    }

    Timer {
        id: destructionTimer
        running : duration > 0
        interval : Toasts.defaultDuration
        onTriggered : rootObject.attemptDestruction()
    }

}
