import QtQuick 2.5
import Zabaat.Material 1.0
Rectangle {
    id : rootObject
    objectName : "ZToastComponent"
    signal requestDestruction()
    signal attemptingDestruction()

    property string state      : ""
    property alias stateText   : ztext.state
    property alias stateButton : zbtn.state
    property alias text        : ztext.text
    property alias textButton  : zbtn.text
    property var cb

    property int duration : -1
    color : Colors.accent


    function attemptDestruction(suppressSignal){
        if(!suppressSignal)
            rootObject.attemptingDestruction()
        if(typeof cb === 'function')
            cb();
        try{
            rootObject.destroy()
        }catch(e){
//            console.log("Cannot destroy indestructible object", rootObject, ". Requesting destruction from parent")
            rootObject.requestDestruction()
        }
    }


    Item {
        id : txContainer
        width : parent.width * 0.85
        height : parent.height
        ZText {
            id : ztext
            anchors.fill: parent
            anchors.margins: 5
            state : "t2-tleft-f3"
        }
    }


    Item {
        id : btnContainer
        width : parent.width - txContainer.width
        height : parent.height
        anchors.right: parent.right
        ZButton {
            id : zbtn
            anchors.fill: parent
            anchors.margins: 5
            text : "Dismiss"
            state : "transparent-tsuccess-tright-f3"
            onClicked: {
                closeTimer.stop()
                rootObject.attemptDestruction()
            }
        }
    }

    Timer {
        id : closeTimer
        interval : duration > 0 ? duration : 0
        running : duration > 0
        repeat : false
        onTriggered : rootObject.attemptDestruction()
    }





}
