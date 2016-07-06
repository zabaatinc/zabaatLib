//The whole idea behind this loader is to precache components,
//that we have told it to !!

import QtQuick 2.5
Item {
    id : rootObject
    property alias logic : logic
    property alias gui : gui

    //this makes us cache components. next time when this loader will load a cached component, it will
    //be much faster.
    function cache(urlOrComponent){
        if(!urlOrComponent)
            return false;

        var l =loaderFactory.createObject(cachedItems)


        var name = urlOrComponent.toString()
        l.objectName = name
        var prop = typeof urlOrComponent === 'string' ? 'source' : 'sourceComponent'
        l[prop] = urlOrComponent;

        logic.cacheMap[name] = l;
    }
    function doLoad(src, args, forceReload){
        logic.loading = true;

        var name = src.toString();
        var l    = logic.cacheMap[name]
        var prop

        if(typeof src === 'string'){
            rootObject.source = src
            rootObject.sourceComponent = undefined
            prop = 'source'
        }
        else {
            rootObject.source = ""
            rootObject.sourceComponent = src
            prop = 'sourceComponent'
        }


        if(src === "" || src === null || src === undefined){    //same as saying YO BRO EMPTY DIS UP

            logic.curLoader = null
            logic.item = Qt.binding(logic.curLoaderItem)

            visibleArea.moveAllToCached()
            return logic.loading = false;
        }


        l             = l || uncachedLoader
        l.args        = args;
        logic.curLoader = l


        if(l === uncachedLoader) {  //if its something uncached we are loading
            if(l[prop] != src){
                //will load new!!
                l[prop] = src;
            }
            else if(forceReload) {
                //will reload!!
                l.active = false;
                l.active = true;

            }
            else {
                l.loadArgs()
                logic.item = l.item    //update rootObject's item
            }
        }
        else {
            if(!forceReload) {
                l.loadArgs()
                logic.item = l.item    //update rootObject's item
            }
            else {
                l.active = false;
                l.active = true;
            }
        }

        visibleArea.moveAllToCached()
        l.parent = visibleArea;

        logic.loading = false;
    }



    QtObject {
        id : logic
        property bool loading   : false
        property var cacheMap : ({})

        property var  curLoader
        property var  item      : curLoaderItem()
        property int  status    : item && item.status  ? item.status  : Loader.Null
        property real progress  : item && item.progress? item.progress: 0

        function curLoaderItem(){
            return curLoader ? curLoader.item : undefined
        }

        property Component loaderFactory : Component { id : loaderFactory; Loader {
                id : loaderInstance
                anchors.fill: parent
                asynchronous: rootObject.asynchronous
                property var args : null;
                onLoaded : if(item){
                     if(parent === visibleArea)
                        rootObject.loaded()

                    item.anchors.fill = loaderInstance
                    loadArgs()
                }
                function loadArgs(){
                    if(item && args) {
                        for(var a in args){
                            if(item.hasOwnProperty(a))
                                item[a] = args[a]
                        }
                        args = null;
                    }
                }
        } }
    }

    Item {
        id :gui
        anchors.fill: parent

        Item {
            id : cachedItems
            anchors.fill: parent
            visible : false

            Loader {
                id : uncachedLoader
                anchors.fill: parent
                asynchronous: rootObject.asynchronous
                property var args : null;
                onLoaded : if(item){
                    if(parent === visibleArea)
                        rootObject.loaded()

                    item.anchors.fill = uncachedLoader
                    loadArgs()
                }
                function loadArgs(){
                    if(item && args) {
                        for(var a in args){
                            if(item.hasOwnProperty(a))
                                item[a] = args[a]
                        }
                        args = null;
                    }
                }
            }
        }

        Item  {
            id : visibleArea
            anchors.fill: parent

            function moveAllToCached(){
                for(var i = children.length - 1; i >= 0 ; --i){
                    var c = children[i]
                    if(c) {
                        c.parent = cachedItems;
                    }
                }
            }


        }




        z : Number.MAX_VALUE
    }


    //For compatibility & same use as a normal loader
    signal loaded()
    property string source
    property var    sourceComponent
    property bool   asynchronous  : false
    property bool   active        : true
    property alias  item          : logic.item
    property alias  status        : logic.status
    property alias  progress      : logic.progress

    onSourceChanged         : if(!logic.loading) doLoad(source)
    onSourceComponentChanged: if(!logic.loading) doLoad(sourceComponent)
    onActiveChanged         : if(item) item.active = active

}
