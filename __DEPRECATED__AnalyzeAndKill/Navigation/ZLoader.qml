import QtQuick 2.0
import Zabaat.Misc.Global 1.0

Loader
{
    id           : loader
    active       : ZGlobal.status === Component.Ready
    source       : ""

    //This makes us load later!
    property var  loadObj              : null
    property var  extraInfo            : ({})
    property bool autoAssignObjectName : true
    property bool destroyOnFail        : true
    property int  numErrors            : 0


    signal iFailed(string objectName, var self)
    signal imReady(string objectName, var self)
    signal iDied  (string objectName, var self)



//    Component.onCompleted: console.log(loader)
    onStatusChanged:  {
        if(status == Loader.Error)
        {
            numErrors++
            console.log(loader, 'error while loading', source)
            if(numErrors == 2){ //we failed at loading from local and from server, call it quits!!

                loadObj = null
                if(destroyOnFail){
                    loader.destroy()
                    return
                }
                else{
                    iFailed(objectName, loader)
                }
            }

            //TODO , move this outside (give this a server path so we don't have to import ZGlobal)
            if(ZGlobal.grabQMLsFromServer)
            {
                var arr      = source.toString().split('/')
                var rootLen  = Qt.resolvedUrl('../').length
                loader.setSource(ZGlobal.serverVars.qmlServerPath + source.toString().slice(rootLen))
                console.log("SERVER LOAD", ZGlobal.serverVars.qmlServerPath + source.toString().slice(rootLen))
            }
        }
        else if(status === Loader.Ready)
        {
            //if object has ready signal, connect to it and wait for it to emit ready!
            var waitingOnObjectReady = false

            if(loader.item.hasOwnProperty('ready')){
                waitingOnObjectReady = true
//                console.log('ZLOADER connecting to ready signal')
                loader.item.ready.connect(doReadyFunc)
            }

            //also check if there's an error signal
            if(loader.item.hasOwnProperty('error'))
                loader.item.error.connect(itemErrorHandler)


            //load args into the object
            if(!ZGlobal.functions.isUndef(loadObj))
            {
                //deprecated but we want to support old stuff
                if(ZGlobal._.isArray(loadObj)){
                    for(var i = 0; i < loadObj.length; ++i){
                        if(loader.item.hasOwnProperty([loadObj[i].name]))
                            loader.item[loadObj[i].name] = loadObj[i].value
                    }
                }
                else{
//                    console.log('LOADOBJ',JSON.stringify(loadObj))
                    for(var l in loadObj){
                        if(loader.item.hasOwnProperty(l))
                            loader.item[l] = loadObj[l]
                    }
                }
                loadObj = null  //reset loadObj
            }

            //lets connect to destroy?
//            console.trace()
            if(loader.item.hasOwnProperty('killme') )
                loader.item.killme.connect(killCommand)


            if(!waitingOnObjectReady)       //we could just check for loader.item.hasOwnProperty('ready') again but checking a bool must be faster right?
                doReadyFunc()
        }
    }

    function killCommand(){
//        console.log(loader, 'obeying killme signal of', loader.item);

        if(loader.item)     iDied(loader.item.objectName, loader)
        else                iDied("", loader)

        loader.destroy()
    }

    Component.onDestruction: {
//        console.log(loader, "is dead")
    }

    function doReadyFunc(){
        if(loader && loader.autoAssignObjectName)
        {
            if(typeof loader.item.title !== 'undefined')
                objectName = loader.item.title
            else
            {
                //lets name this object based on the name of this QML
                var objName = source.toString().split('/')
                objectName = objName[objName.length -1]
            }
        }
        if(loader && loader.item && loader.item.ready)  //in case the loader dies before the item gets ready
            loader.item.ready.disconnect(doReadyFunc)

        imReady(objectName, loader)
    }
    function itemErrorHandler(message){
        if(ZGlobal.objects.hudMsg){
            ZGlobal.objects.hudMsg("\uf071",message)
            if(destroyOnFail){
                //kill this with FIRE!
                killCommand()
            }
        }
    }
    function loadPage(source, args){
        var index = source.indexOf('?')
        if(index !== -1)
        {
            var args2 = source.slice(index)
            source    = source.slice(0,index)

            args2 = args2.split(',')
            for(var a in args2)
            {
                var lineArr = args2[a].split('=')

                if(!args)
                    args = []

                args[lineArr[0]] = lineArr[1]
            }
        }

        loadObj = args
//        source = rootPath.toString() + "///" + source.toString()
//        console.log("THE SOURCE IS : ", source)
        if(loader.source !== source)
        {
            loader.setSource(source)
        }
    }
    function showPopup(item, x,y, originItem, parentItem, timerStatus) {//shows new popup or old one if no new item is provided (no params essentially)
        if(item !== null && typeof item !== 'undefined')
        {
            //remove current item from popup if we havew any and if item param is not the same as it
            if(popupWindow.itemPtr !== null && popupWindow.itemPtr !== item ){
                if(popupWindow.parentItemPtr){
                    popupWindow.itemPtr.parent = popupWindow.parentItemPtr
                }
                else{
                    popupWindow.itemPtr.parent = null
                    popupWindow.itemPtr.destroy()
                    popupWindow.itemPtr = null
                }
            }

//            popupWindow.width  = item.width  * 2
//            popupWindow.height = item.height * 2

            //insert new item into popup
            item.parent = popupWindow
            item.visible = true
            popupWindow.itemPtr = item

            //save parent, to return this object to the parent!
            if(parentItem)
                popupWindow.parentItemPtr = parentItem

            //set x and y properties of item
            //item.z = 1

            var coords = ZGlobal.functions.isDef(originItem) ? originItem.mapToItem(loader,0,0) : Qt.point(0,0)
            if(ZGlobal.functions.isUndef(x) && ZGlobal.functions.isUndef(y)){
                if(originItem){
                   x = coords.x + x
                   y = coords.y + y
                }

                if(x < 0)
                    x = 0
                else if(x + item.width > loader.width)
                    x -= (x + item.width) - loader.width


                if(y < 0)
                    y = 0
                else if(y + item.height > loader.height)
                    y -= (y + item.height) - loader.height

                item.x = x
                item.y = y
            }
            else {
                if(ZGlobal.functions.isDef(x)) item.x = coords.x + x
                if(ZGlobal.functions.isDef(y)) item.y = coords.y + y
            }


//            if     (timerStatus === 1)         invisibleTimer.running    = false
//            else if(timerStatus === 2)         invisibleTimer.neverStart = true
//            else                               invisibleTimer.running    = true

            //show popup
            popupWindow.visible = popupWindow.enabled =  true
        }


    }
    function hidePopup(){//hides popup window
        popupWindow.visible = popupWindow.enabled =  false
    }
    function removePopup(){//removes item from popup window (restores it to original parent or if none was provied, kills it with FIRE!
        if(popupWindow.itemPtr !== null ){
            if(popupWindow.parentItemPtr){
                popupWindow.itemPtr.parent = popupWindow.parentItemPtr
            }
            else{
                popupWindow.itemPtr.parent = null
                popupWindow.itemPtr.destroy()
                popupWindow.itemPtr = null
            }
        }
        popupWindow.visible = popupWindow.enabled =  false
    }


    Rectangle {
        anchors.fill: parent
        color : "darkGray"
        opacity : 0.8
        visible : popupWindow.visible
        z : 2147483646
        MouseArea {
            anchors.fill: parent
            onClicked: removePopup()
        }
    }


    Item{
        id : popupWindow
        visible : false
        z : 2147483647

        property var parentItemPtr   : null
        property var itemPtr         : null    //ptr to item
        onVisibleChanged: if(loader && loader.item){
                            loader.item.enabled = !visible
                          }

//        Timer    {
//            id : invisibleTimer
//            interval : 2000
//            repeat : false
//            running : false
//            property bool neverStart : false

//            onTriggered: popupWindow.visible = popupWindow.enabled =  false
//        }
//        MouseArea{
//            id : mouseArea
//            hoverEnabled: true
//            onClicked : mouse.accepted = false;
//            onExited : if(!invisibleTimer.neverStart) invisibleTimer.start()
//            onEntered: invisibleTimer.stop()
//            x : popupWindow.itemPtr ? popupWindow.itemPtr.x : 0
//            y : popupWindow.itemPtr ? popupWindow.itemPtr.y : 0
//            width : popupWindow.itemPtr && !invisibleTimer.neverStart ? popupWindow.itemPtr.width : 0
//            height : popupWindow.itemPtr && !invisibleTimer.neverStart ? popupWindow.itemPtr.height : 0
//            z : 2147483647
//            propagateComposedEvents: true


////            Rectangle{
////                anchors.fill: parent
////                border.width : 3
////                border.color: ZGlobal.style.danger
////                color : 'transparent'
////            }
//            preventStealing: false
//        }
    }



}

