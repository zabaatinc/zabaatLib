import QtQuick 2.5
import Zabaat.Material 1.0
import Zabaat.Base 1.0
//Flexible Toast thbat can take any component and then displays it. If the compoonent is made permanent,
//should take care of its own destruction. Should have a signal called requestDestruction!
Item {
    id : rootObject
    objectName : "ZToastComponent"

    property var    cmp              : null //the component to load. can be string or QQML component
    property var    args             : null //the args to load on the component
    property var    autoCloseFunc    : null
    property var    cb               : null //happens on destruction if provided!
    property alias  duration         : destructionTimer.interval        //-1 is permanent
    property alias  item             : loader.item

    //just so we are compliant with other toasts
    property string title: ""
    property string text : ""

    signal requestDestruction()
    signal attemptingDestruction()
    signal loaded(var item);

    onCmpChanged: {
        if(!cmp){
            loader.source = ""
            loader.sourceComponent = null
        }
        else
            initTimer.start()
    }

    property bool calledToDestroy: false

    function attemptDestruction(suppressSignal){
        if(!rootObject || calledToDestroy)
            return;

        calledToDestroy = true;
        if(!suppressSignal)
            rootObject.attemptingDestruction()
        try{
            rootObject.destroy()
        }catch(e){
//            console.log("Cannot destroy indestructible object", rootObject, ". Requesting destruction from parent")
            rootObject.requestDestruction()
        }
    }


    Component.onDestruction: if(typeof cb === 'function')
                                 cb()


    Loader {
        id : loader
        anchors.fill: this && parent ? parent: null
        onLoaded : if(item){

            try {
                item.requestDestruction.connect(attemptDestruction)
            }
            catch(e) {
                console.error(cmp, "has no request destruction signal!")
            }
            item.Component.destruction.connect(attemptDestruction)

            var getFirstPair = function (obj) {
                for(var k in obj) {
                    return {
                        key : k,
                        val : obj[k]
                    }
                }
            }
            var tryAssign = function(key,value) {
                if(item.hasOwnProperty(key))
                    try {
                        item[key] = value;
                    }
                    catch(e) {
                        Functions.log("Exception: ", e , "\nAssignemnt on", item + "." + key, "failed. Type:", toString.call(value) ,"JSON:", JSON.stringify(value));
                    }
            }
            if(typeof args === 'object') {
                if (Lodash.isArray(args)) {
                    Lodash.each(args, function(i) {
                        var pair = getFirstPair(i);
                        tryAssign(pair.key, pair.val);
                    })
                }
                else {
                    Lodash.each(args,function(v,k) {
                        tryAssign(k,v);
                    })
                }
            }

            rootObject.loaded(item);
        }
    }


    Timer {
        id : initTimer
        interval : 10
        running : false
        onTriggered : {
            if(typeof rootObject.cmp === 'string'){
                loader.source = rootObject.cmp
            }
            else {
                loader.sourceComponent = rootObject.cmp
            }
        }
    }


    Timer {
        id : autoCloseTimer
        running : rootObject.autoCloseFunc ? true : false
        interval : 100
        repeat : true
        onTriggered : {
            if(rootObject.autoCloseFunc && rootObject.autoCloseFunc(rootObject)){
                stop()
                rootObject.attemptDestruction()
            }
        }

    }

    Timer {
        id: destructionTimer
        running : duration > 0
        interval : Toasts.defaultDuration
        onTriggered : {
            stop()
            rootObject.attemptDestruction()
        }
    }
}
