import QtQuick 2.4
import "logic/toasts"

//This is dependent on the WindowManager singleton.
//If you want this to behave properly and have taosts show up in windows from
//which they were invoked (active Window). Make sure you either pass the window
//or create,register window in the WindowManager. Thanks!!
pragma Singleton
Item {
    id : rootObject

    property bool loaded             : mgr.target !== null
    readonly property var init       : logic.init
    readonly property var clearAll   : logic.clearAll
    property string defaultToastType : "ZToastInstance"
    property int    defaultDuration  : 3000
    readonly property alias count    : logic.count
    readonly property alias jsObj    : logic.js
    readonly property alias json     : logic.json
    property point defaultToastSize  : Qt.point(0.5,0.5);


    property bool alwaysLog          : true
    property var logFunc             : null

    z                                : 9999999
    Component.onCompleted            : logic.log("Singleton Toasts is born")

    //available functions!
    function create                 (message,args,type,wPerc,hPerc){
        logic.create(message,type,args,{},wPerc,hPerc)
    }
    function createBlocking         (message,args,type,wPerc,hPerc){
        logic.create(message,type,args,{blocking:true},wPerc,hPerc)
    }
    function createPermanent        (message,args,type,wPerc,hPerc){
        logic.create(message,type,args,{duration:-1},wPerc,hPerc)
    }
    function createPermanentBlocking(message,args,type,wPerc,hPerc){
//        console.log("Toasts create Permanent blocking", message, args, type, wPerc, hPerc);
        logic.create(message,type,args,{blocking:true,duration:-1},wPerc,hPerc)
    }

    function createIn(item,msg,args,type,wPerc,hPerc){
        logic.create(msg,type,args,{},wPerc,hPerc,item)
    }
    function createBlockingIn       (item,message,args,type,wPerc,hPerc){
        logic.create(message,type,args,{blocking:true},wPerc,hPerc,item)
    }
    function createPermanentIn      (item,message,args,type,wPerc,hPerc){
        logic.create(message,type,args,{duration:-1},wPerc,hPerc,item)
    }
    function createPermanentBlockingIn(item,message,args,type,wPerc,hPerc){
        logic.create(message,type,args,{blocking:true,duration:-1},wPerc,hPerc,item)
    }

    function createComponent(componentOrPath, args, cb, wPerc,hPerc,contentItem){
        logic.create("","ZToastComponent",{cmp:componentOrPath,args:args, cb : cb },{},wPerc, hPerc, contentItem)
    }

    function createComponentPermanent(componentOrPath, args, cb, wPerc,hPerc,contentItem){
        logic.create("","ZToastComponent",{cmp:componentOrPath,args:args, cb : cb },{duration:-1},wPerc, hPerc, contentItem)
    }

    function createComponentPermanentBlocking(componentOrPath, args, cb, wPerc,hPerc,contentItem){
        logic.create("","ZToastComponent",{cmp:componentOrPath,args:args, cb : cb },{blocking:true,duration:-1},wPerc, hPerc, contentItem)
    }

    function error(strOrObj,title,args){
        var  obj = { err : strOrObj }
        if(args) {
            for(var a in args){
                obj[a] = args[a]
            }
        }
        logic.create("","ZToastError", obj ,{blocking:true,duration:-1})
    }
    function errorIn(item,strOrObj,title,args){
        var  obj = { err : strOrObj }
        if(args){
            for(var a in args){
                obj[a] = args[a]
            }
        }
        logic.create("","ZToastError", obj ,{blocking:true,duration:-1},null,null,item)
    }

    function dialog(title, text, cbAccept, cbCancel, args){
        dialogIn(title,text,cbAccept,cbCancel,args)
    }

    function dialogIn(title, text, cbAccept, cbCancel, args, item) {
        if(!args)
            args = {}

        args.title      = title;
        args.acceptFunc = cbAccept;
        args.cancelFunc = cbCancel;

        logic.create(text,"ZToastDialog", args, {blocking:true,duration:-1} , null, null , item)
    }

    function dialogWithInput(title, text, cbAccept, cbCancel, args){
        dialogWithInputIn(title,text,cbAccept,cbCancel,args)
    }
    function dialogWithInputIn(title, text, cbAccept, cbCancel, args, item) {
        if(!args)
            args = {}

        args.title      = title;
        args.acceptFunc = cbAccept;
        args.cancelFunc = cbCancel;
//        args.focusFunc = cbFocus;

        logic.create(text,"ZToastDialogInput", args, {blocking:true,duration:-1} , null, null , item)
    }


    function listOptions(title, model, cbAccept, cbCancel, args){
        listOptionsIn(title,model,cbAccept,cbCancel,args)
    }

    function listOptionsIn(title, model, cbAccept, cbCancel, args, item){
        if(!args)
            args = {}

        args.title = title;
        args.acceptFunc = cbAccept;
        args.cancelFunc = cbCancel;
        args.model      = model;

        logic.create("","ZToastList",args,{blocking:true,duration:-1}, null, null, item)
    }




    property QtObject __private : QtObject {
        id : logic
        property var mainWindowPtr : null
        property bool debug : true
        property int nextId : 0

        property var map        : ({})
        property int count      : 0
        property var js         : null
        property string json    : ""

        function log(){
            if(debug){
                console.log.apply(this,arguments)
            }
        }
        function generateId() {
            return nextId++;
        }
        function updateCount() {    // also updates json!
            var arr  = [];
            var jsArr = []

            for(var m in logic.map){
                var t = logic.map[m]
                if(t){
                    arr.push({toast:t,title:t.text,id:t.objectName})
                    jsArr.push({toast:t.text,id:t.objectName})
                }
            }

            js    = arr
            json  = JSON.stringify(jsArr,null,2)
            count = arr.length
        }
        function init(winMgr){
            log(winMgr, typeof winMgr,winMgr.toString() )
            if(winMgr && typeof winMgr !== 'undefined' && winMgr.toString().indexOf("WindowManager") === 0 ) {
                mgr.target = winMgr
            }
        }
        function create(msg,type,args,config,w,h, contentItem){
            //make params acceptable
            var activeThing = null
//            console.log(mgr, mgr.target, mgr.target.activeWindow )
            if(!contentItem) {
                if(!mgr.target || !mgr.target.activeWindow)
                    return
                else {
                    contentItem = mgr.target.activeWindow.contentItem
                    activeThing = mgr.target.activeWindow.activeFocusItem
                }
            }



            var newToast           = toastBakery.createObject(contentItem);
            newToast.anchors.fill  = contentItem

            if(typeof msg === 'function') {
                newToast.text = Qt.binding(msg);
            }
            else {
                newToast.text = msg || "undefined"
            }
            newToast.lastActiveThing = activeThing

            newToast.args          = args
            newToast.duration      = config.duration || rootObject.defaultDuration
            newToast.blocking      = config.blocking || false
            newToast.state     = "f8"

            newToast.w         = w || args.width || args.w ||  defaultToastSize.x
            newToast.h         = h || args.height || args.h || defaultToastSize.y
            newToast.z         = 999999

            //now load the inner loader!
            type  = type || "ZToastSimple.qml"
            if(type.indexOf('.qml') === -1)
                type = type + ".qml"
            newToast.type      = type

            var id = logic.generateId()
            newToast.objectName = id
            logic.map[id] = newToast
            logic.updateCount()

//            console.log("new toast in " , newToast, newToast.parent, mainWindowPtr)
            return newToast
        }
        function clearAll(){
            for(var m in logic.map){
                var item = logic.map[m]
                if(item) {
                    item.destroy()
                    delete logic.map[m]
                }
            }
            logic.updateCount()
        }

        //allows us to access the singleton WindowManagert without making an instance!!
        property Connections windowMgr : Connections {
            id     : mgr
            target : null
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
                property real w : rootObject.defaultToastSize.x
                property real h : rootObject.defaultToastSize.y

                Component.onDestruction: {
                    if(lastActiveThing && lastActiveThing.forceActiveFocus)
                        lastActiveThing.forceActiveFocus()
                    else
                        console.log("no last active thing hurrr", lastActiveThing)

                    if(logic.map[objectName]){
                        delete logic.map[objectName]
                    }
                    logic.updateCount()
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
}
