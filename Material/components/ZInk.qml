import QtQuick 2.5
import Zabaat.Material 1.0

Item {
    id                   : inkContainer
    anchors.fill         : parent
    property var tapObj  : null
    property var msArea  : null
    property color color : "yellow"
    clip                 : true

    function lockMouse(x, y){
        if(tapObj){
            if(x === null || typeof x === 'undefined')   x = msArea.mouseX
            if(y === null || typeof y === 'undefined')   y = msArea.mouseY

            tapObj.start.x = x;
            tapObj.start.y = y;
            logic.coordsLocked = true
        }
    }

    function tap(){
        if(tapObj === null)
            tapObj = tapHouse.createObject(inkContainer);
    }
    function end(state, func){
        if(tapObj){
            var arr = null
            if(arguments.length > 2){
                arr = []
                for(var i = 1; i < arguments.length; i++)
                    arr.push(arguments[i])
            }

            if(state === null || typeof state === 'undefined'){
                if(func === null)   logic.endTap()
                else {
                    if(arr === null)    logic.endTapAndCall(func)
                    else                logic.endTapAndCall.apply(this,arr)
                }

            }
            else {
                tapObj.args = arr
                if(!logic.coordsLocked)
                    tapObj.start = Qt.point(msArea.mouseX, msArea.mouseY)
//                console.log("END", tapObj.start.x, tapObj.start.y)
                if(state === "shrink")      tapObj.startShrink()
                else                        tapObj.startGrow()
            }
        }
    }

    QtObject {
        id : logic
        objectName : "zInk_LogicSection"
        function endTap(){
            tapObj.destroy()
            tapObj = null
            logic.coordsLocked = false
        }
        function endTapAndCall(func){
            if(func){
                if(arguments.length > 1){
                    var arr = []
                    for(var i = 1 ; i < arguments.length; i++)
                        arr.push(arguments[i])
                    func.apply(this, arr)
                }
                else
                    func()
            }
            if(logic && logic.endTap)
                logic.endTap()
        }

        property bool coordsLocked : false
    }
    Component {
        id : tapHouse
        Rectangle{
            id     : tapCirc
            width  : 1
            height : 1
            radius : height/2
            color  : inkContainer.color
            transformOrigin: Item.Center
            x : !logic.coordsLocked && !grow.running && !shrink.running ? inkContainer.msArea.mouseX - width/2    : start.x - width/2
            y : !logic.coordsLocked && !grow.running && !shrink.running ? inkContainer.msArea.mouseY - height/2   : start.y - height/2

            property var args : null
            function startShrink(){ spotlight.stop(); if(!shrink.running) shrink.start() }
            function startGrow()  { spotlight.stop(); if(!grow.running)   grow.start()   }

            property string spotlightProperty : "width"
            property string growProperty      : "height"
            property point  start             : Qt.point(0,0)
            Component.onCompleted: {
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
            NumberAnimation {
                id         : spotlight
                target     : tapCirc;
                property   : tapCirc.spotlightProperty;
                to         : inkContainer[tapCirc.spotlightProperty] * 1.5;
                duration   : 250;
                easing.type: Easing.InOutQuad;
//                onStopped  : console.log("spotlight stopped")
            }
            NumberAnimation {
                id         : grow
                target     : tapCirc;
                property   : tapCirc.spotlightProperty;
                to         : inkContainer[tapCirc.growProperty] * 2;
                duration   : 167;
                easing.type: Easing.InOutQuad;
                onStopped  : {
                    tapCirc.cb ? logic.endTap() : logic.endTapAndCall.apply(this, tapCirc.args)
//                    console.log("grow stopped")
                }
            }
            NumberAnimation {
                id         : shrink
                target     : tapCirc;
                property   : tapCirc.spotlightProperty;
                to         : 0;
                duration   : 167;
                easing.type: Easing.InOutQuad;
                onStopped  : {
                    tapCirc.cb ? logic.endTap() : logic.endTapAndCall.apply(this, tapCirc.args)
//                    console.log("shrink stopped")
                }
            }
        }
    }
}

