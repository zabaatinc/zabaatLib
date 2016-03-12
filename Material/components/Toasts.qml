import QtQuick 2.4
import "logic/toasts"

pragma Singleton
Item {
    id : rootObject

    property bool loaded             : parent !== null
    readonly property var init       : logic.init
    readonly property var clearAll   : logic.clearAll
    property string defaultToastType : "ZToastInstance"
    property int    defaultDuration  : 3000

    z                                : 9999999
    Component.onCompleted            : logic.log("Singleton Toasts is born")

    //available functions!
    function create(message,args,type,wPerc,hPerc){
        logic.create(message,type,args,{},wPerc,hPerc)
    }
    function createBlocking(message,args,type,wPerc,hPerc){
        logic.create(message,type,args,{blocking:true},wPerc,hPerc)
    }
    function createPermanent(message,args,type,wPerc,hPerc){
        logic.create(message,type,args,{duration:-1},wPerc,hPerc)
    }
    function createPermanentBlocking(message,args,type,wPerc,hPerc){
        logic.create(message,type,args,{blocking:true,duration:-1},wPerc,hPerc)
    }



    property QtObject __private : QtObject {
        id : logic
        property var mainWindowPtr : null
        property bool debug : true
        function log(){
            if(debug){
                console.log.apply(this,arguments)
            }
        }
        function init(mainWindow){
            if(mainWindow && mainWindow.contentItem) {
                mainWindowPtr = mainWindow
                rootObject.anchors.fill =  rootObject.parent = mainWindow.contentItem;
                loaded = true;
            }
        }

        function create(msg,type,args,config,w,h){
            //make params acceptable
            var newToast       = toastBakery.createObject(toastContainer);
            newToast.anchors.fill  = toastContainer
            newToast.text     = msg || "undefined"

            newToast.args       = args
            newToast.duration  = config.duration || rootObject.defaultDuration
            newToast.blocking  = config.blocking || false
//            newToast.state     = state || "default"

            newToast.w         = w || 0.5
            newToast.h         = h || 0.5

            //now load the inner loader!
            type  = type || "ZToastSimple.qml"
            if(type.indexOf('.qml') === -1)
                type = type + ".qml"
            newToast.type      = type
        }

        function clearAll(){
            for(var i = toastContainer.children.length ; i >= 0; --i){
                var child = toastContainer.children[i]
                child.parent = null
                child.destroy()
            }
            toastContainer.children = []
        }

        property Component toastBakery : Component {
            id : toastBakery
            Item {
                id : toastInstance
                property int duration  : -1
                property bool blocking : false
                property string type   : ""
                property string path   : "logic/toasts/"
                property string text   : ""
                property var    args   : null
                property var    lastActiveThing : null
                property real w : 0.5
                property real h : 0.5

                Component.onDestruction: {
                    if(lastActiveThing)
                        lastActiveThing.forceActiveFocus()
                }

                Rectangle {
                    id : uiBlocker
                    anchors.fill: parent
                    color : 'black'
                    opacity : 0.9
                    visible : parent.blocking
                    enabled : visible
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
                Loader {
                    width           : parent.width  * parent.w
                    height          : parent.height * parent.h
                    anchors.centerIn: parent
                    source          : toastInstance.type !== "" ? toastInstance.path + toastInstance.type : ""
                    onLoaded : {
                        logic.log("Toast loaded!",item);
                        if(toastInstance.blocking) {
                            if(logic.mainWindowPtr && logic.mainWindowPtr.activeFocusItem)
                                toastInstance.lastActiveThing = logic.mainWindowPtr.activeFocusItem
                            uiBlocker.forceActiveFocus()
                        }

                        item.text     = toastInstance.text
                        item.state    = toastInstance.state
                        item.duration = toastInstance.duration

                        if(toastInstance.args){
                            for(var a in toastInstance.args){
                                if(item.hasOwnProperty(a))
                                    item[a] = toastInstance.args[a]
                            }
                        }

                        item.requestDestruction.connect(toastInstance.destroy)
                    }
                }
            }
        }
    }

    Item {
        id          : toastContainer
        anchors.fill: parent


    }

}
