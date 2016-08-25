//sad that this class is necessary. Maybe in the future it won't be.
import QtQuick 2.5
import QtQuick.Window 2.2

pragma Singleton
Item {
    id : rootObject

    Component.onCompleted: console.log("singleton WindowManager is born!")

    property bool loaded          : logic.mainWindow ? true : false
    property var  activeWindow    : null
    property var  activeItem      : null
    readonly property alias count : logic.count
    readonly property alias jsObj : logic.js
    readonly property alias json  : logic.json
    readonly property alias mainWindow : logic.mainWindow
    readonly property alias logic : logic

    QtObject {
        id : logic
        property var mainWindow : null
        property var map        : ({})
        property int nextId     : 0
        property int count      : 0
        property var js         : null
        property string json    : ""

        function updateCount() {    // also updates json!
            var arr  = [];
            var jsArr = []
            if(logic.mainWindow){
                arr.push({window:logic.mainWindow,title:logic.mainWindow.title,id:"mainWindow"})
                jsArr.push({title:logic.mainWindow.title,id:"mainWindow"})
                for(var m in logic.map){
                    var win = logic.map[m]
                    if(win){
                        arr.push({window:win,title:win.title,id:win.objectName})
                        jsArr.push({title:win.title,id:win.objectName})
                    }
                }
            }
            js    = arr
            json  = JSON.stringify(jsArr,null,2)
            count = arr.length
        }
        function generateId(){
            return nextId++;
        }

        property Component windowFactory : Component{
            id : windowFactory
            Window {
                id: windowInstance
                onActiveFocusItemChanged: if(rootObject.activeWindow === windowInstance)
                                              rootObject.activeItem = activeFocusItem
                onActiveChanged         : rootObject.activeWindow = active ? windowInstance : null
                visible : true
                x : 0
                y : 0
                width : 320
                height : 240
                onClosing : {
                    if(logic.map[objectName]) {
                        delete logic.map[objectName]
                        logic.updateCount()
                    }
                }
            }
        }
    }

    function closeAll(){
        for(var m in logic.map){
            var win = logic.map[m]
            if(win)
                close(win.objectName)
        }
    }
    function close(id){
        var w = logic.map[id]
        if(w){
            w.close();
        }
    }
    function create(x,y,w,h,title){
        var win = windowFactory.createObject(Qt.application)
        if(x !== null && typeof x  !== 'undefined')          win.x = x;
        if(y !== null && typeof y  !== 'undefined')          win.y = y;
        if(w !== null && typeof w  !== 'undefined')          win.width  = w;
        if(h !== null && typeof h  !== 'undefined')          win.height = h;
        if(title !== null && typeof title  !== 'undefined')  win.title = title;

        var id        = logic.generateId();
        win.objectName = id;
        logic.map[id] = win

        logic.updateCount()
        return win
    }
    function registerWindow(win) {
        win.activeChanged.connect(function() {
            rootObject.activeWindow = win.active ? win : null
        })
        win.activeFocusItemChanged.connect(function() {
            if(rootObject.activeWindow === win){
                rootObject.activeItem = win.activeFocusItem
            }
        })

        var id        = logic.generateId();
        win.objectName = id;
        logic.map[id] = win
        logic.updateCount()
    }

    function init(mainWindow){
        console.log("Material.MainWindow.Init(", mainWindow, ")")
        if(mainWindow && mainWindow.contentItem) {
            rootObject.activeItem =  mainWindow.activeFocusItem
            rootObject.activeWindow = mainWindow

            mainWindow.activeChanged.connect(function() {
                if(Qt.platform.os === "android" || Qt.platform.os === "winphone" || Qt.platform.ios === "ios") {
                    //there's only one window on mobile. So let's not kid ourselves
                    return rootObject.activeWindow = mainWindow
                }

                rootObject.activeWindow = mainWindow.active ? mainWindow : null
            })
            mainWindow.activeFocusItemChanged.connect(function() {
                if(rootObject.activeWindow === mainWindow){
                    rootObject.activeItem = mainWindow.activeFocusItem
                }
            })
            mainWindow.closing.connect(function() {
                closeAll()
            })
            logic.mainWindow  = mainWindow
            rootObject.anchors.fill =  rootObject.parent = mainWindow.contentItem;

            logic.updateCount()
        }
    }


}
