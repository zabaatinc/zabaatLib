import QtQuick 2.5
import Zabaat.Material 1.0
//Flexible Toast thbat can take any component and then displays it.
Item {
    id : rootObject
    objectName : "ZToastComponent"

    property var    cmp              : null //the component to load. can be string or QQML component
    property var    args             : null //the args to load on the component
    property var    autoCloseFunc    : null
    property var    cb               : null //happens on destruction if provided!
    property alias  duration         : destructionTimer.interval        //-1 is permanent

    //just so we are compliant with other toasts
    property string title: ""
    property string text : ""

    onCmpChanged: {
        if(!cmp){
            loader.source = ""
            loader.sourceComponent = null
        }
        else
            initTimer.start()
    }


    function attemptDestruction(suppressSignal){
        if(!suppressSignal)
            rootObject.attemptingDestruction()
        try{
            rootObject.destroy()
        }catch(e){
            console.log("Cannot destroy indestructible object", rootObject, ". Requesting destruction from parent")
            rootObject.requestDestruction()
        }
    }


    Component.onDestruction: if(cb)
                                 cb()


    Loader {
        id : loader
        anchors.fill: this && parent ? parent: null
        onLoaded : if(item){
            item.Component.destruction.connect(attemptDestruction)
            if(args) {
                for(var a in args){
                    if(item.hasOwnProperty(a))
                        item[a] = args[a]
                }
            }
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