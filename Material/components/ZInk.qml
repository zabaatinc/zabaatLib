import QtQuick 2.5
import Zabaat.Material 1.0

Item {
    id                    : inkContainer
    anchors.fill          : parent
    clip                  : true
    property alias tapObj : inkBlob
    property alias color  : inkBlob.color
    property var msArea   : null
    property alias state  : inkBlob.state

    function lockMouse(x, y){
        if(x === null || typeof x === 'undefined')   x = msArea.mouseX
        if(y === null || typeof y === 'undefined')   y = msArea.mouseY

        inkBlob.coords = Qt.point(x,y);
        logic.coordsLocked = true
    }
    function tap(){
        if(inkContainer.state === "hidden") {
            inkContainer.state = "start"
        }
    }
    function end(state, func){
        var arr = null
        if(arguments.length > 2){
            arr = []
            for(var i = 1; i < arguments.length; i++)
                arr.push(arguments[i])
        }

        if(state === null || typeof state === 'undefined'){
            if(func === null) {
                logic.endTap()
            }
            else {
                if(arr === null)    logic.endTapAndCall(func)
                else                logic.endTapAndCall.apply({},arr)
            }
        }
        else {
            inkBlob.args = arr
            if(!logic.coordsLocked)
                inkBlob.coords = Qt.point(msArea.mouseX, msArea.mouseY)
            if(state === "shrink")      inkBlob.startShrink()
            else                        inkBlob.startGrow()
        }
    }

    QtObject {
        id : logic
        objectName : "zInk_LogicSection"
        property bool coordsLocked : false

        function endTap(){
            logic.coordsLocked = false
            inkContainer.state = "hidden"
        }
        function endTapAndCall(func){
            if(func){
                if(arguments.length > 1){
                    var arr = []
                    for(var i = 1 ; i < arguments.length; i++)
                        arr.push(arguments[i])
                    func.apply({}, arr)
                }
                else
                    func()
            }
            if(logic && logic.endTap)
                logic.endTap()
        }
    }

    Rectangle{
        id     : inkBlob
        width  : 0
        height : 0
        radius : height/2
        color  : "yellow"
        transformOrigin: Item.Center
        x : !logic.coordsLocked && !grow.running && !shrink.running ? inkContainer.msArea.mouseX - width/2    : coords.x - width/2
        y : !logic.coordsLocked && !grow.running && !shrink.running ? inkContainer.msArea.mouseY - height/2   : coords.y - height/2

        property var args : null
        function startShrink(){ spotlight.stop(); if(!shrink.running) shrink.start() }
        function startGrow()  { spotlight.stop(); if(!grow.running)   grow.start()   }

        property string spotlightProperty : "width"
        property string growProperty      : "height"
        property point  coords            : Qt.point(0,0)
        property string state             : 'hidden'
        property bool ready               : !grow.running && !shrink.running && !spotlight.running


        function doReset(exclusion) {
            reset = true;
            if(exclusion !== spotlight)  spotlight.stop()
            if(exclusion !== grow)       grow.stop()
            if(exclusion !== shrink)     shrink.stop()
            reset = false;
        }

        function doStart() {
            var w = inkContainer.width < inkContainer.height
            if(w){
                spotlightProperty = "width"
                growProperty      = "height"
                height = Qt.binding(function() {return width})
            }
            else {
                spotlightProperty = "height"
                growProperty      = "width"
                width = Qt.binding(function() { return height })
            }
            spotlight.start()
        }

        onStateChanged :  {
            if(state === "start") {
                width  = height =  0
                doReset();
                if(ready)
                    doStart();
            }
            else if(state === 'hidden'){
                width  = height =  0
                doReset();
            }
        }


        property bool reset : false

        NumberAnimation {
            id         : spotlight
            target     : inkBlob;
            property   : inkBlob.spotlightProperty;
            to         : inkContainer[inkBlob.spotlightProperty] * 1.5;
            duration   : 250;
            easing.type: Easing.InOutQuad;
//                onStopped  : console.log("spotlight stopped")
        }
        NumberAnimation {
            id         : grow
            target     : inkBlob;
            property   : inkBlob.spotlightProperty;
            to         : inkContainer[inkBlob.growProperty] * 2;
            duration   : 167;
            easing.type: Easing.InOutQuad;
            onStarted: inkBlob.doReset(grow)
            onStopped  : {
                if(!inkBlob.reset)
                    inkBlob.cb ? logic.endTap() : logic.endTapAndCall.apply({}, inkBlob.args)
            }
        }
        NumberAnimation {
            id         : shrink
            target     : inkBlob;
            property   : inkBlob.spotlightProperty;
            to         : 0;
            duration   : 167;
            easing.type: Easing.InOutQuad;
            onStarted: inkBlob.doReset(shrink)
            onStopped  : {
                if(!inkBlob.reset)
                    inkBlob.cb ? logic.endTap() : logic.endTapAndCall.apply({}, inkBlob.args)
            }
        }
    }
//    Text {
//        text : inkContainer.state
//        anchors.fill: parent
//    }
}

