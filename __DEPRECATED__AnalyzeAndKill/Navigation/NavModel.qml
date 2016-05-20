import QtQuick 2.4
import Zabaat.Misc.Global 1.0


Item {

    property var mainItems : ({})
    property var lists       : []
    property bool hasInit    : false

    signal mainItemAdded(string name, var obj, var model)
    signal itemAdded    (string name)
    signal itemRemoved  (string name)
    signal listRemoved  (string name)
    signal wipeOccurred  ()



    function init(){
        mainItems = {}
        lists = []
        hasInit = true
    }

    //the lists hold two properties only. name && obj

    function addMainItem(projectName, obj){
        if(!hasInit)
            init()

        if(ZGlobal.functions.isUndef(mainItems[projectName])){
            mainItems[projectName] = obj
            var model                = modelFactory.createObject(container)
            model.objectName         = projectName
            lists.push(model)
            mainItemAdded(projectName, obj, model)
            return true
        }
        return false
    }
    function addItem(itemName, obj){
        if(!hasInit)
            init()

        var list = getList(obj.parentProject)
        if(list){
            list.append({name : itemName, obj : obj})
            itemAdded(itemName)
            return true
        }
        return false
    }

    function getListIndex(projectName){
        if(!hasInit)
            init()

        for(var i = 0; i < lists.length; i++){
            var list = lists[i]
            if(list.objectName === projectName)
                return i
        }
        return -1
    }
    function getList(projectName){
        if(!hasInit)
            init()

        var idx = getListIndex(projectName)
        if(idx !== -1)
            return lists[idx]
        return null
    }

    function removeList(projectName){
        var idx = getListIndex(projectName)
        if(idx !== -1) {
            var list = lists[idx]
            if(list){
                list.killAll()
                list.destroy()
            }
            lists.splice(idx,1)
        }
    }
    function removeItem(obj){
        if(!hasInit)
            init()
//        console.log("removeiTem", obj)
        var list = getList(obj.parentProject)
        if(list){
            var idx = list.getIndexByObject(obj)
            if(idx !== -1) {
                itemRemoved(obj.objectName)
                list.remove(idx)
                kill(obj)
                return true
            }
        }
        return false
    }
    function wipe(){
        if(!hasInit)
            init()

        for(var m in mainItems){
            var obj = mainItems[m]

            if(obj.killCommand)       obj.killCommand()
            else                      obj.destroy()
        }
        mainItems = {}

        for(var l in lists){
            var list = lists[l]
            list.clear()
            list.destroy()
        }
        lists = []
        wipeOccurred()
    }
    function kill(obj){
        if(obj.killCommand)     obj.killCommand()
        else                    obj.destroy()
    }

    Component {
        id : modelFactory
        ListModel{
            dynamicRoles: true
            function getIndexByObject(obj){
                for(var i  = 0; i < count; i++){
                    var item = get(i)
                    if(item.obj === obj)
                        return i
                }
                return -1
            }
            function getIndex(name){
                for(var i = 0; i < count; i++){
                    var item = get(i)
                    if(item && item.name == name)
                        return i
                }
                return -1
            }
            function getObject(name){
                var idx = getIndex(name)
                return idx !== -1 ? get(idx) : null
            }
            function killAll(){
                for(var i =0; i < count; i++){
                    var item = get(i)
                    if(item){
                        kill(item.obj)
                    }
                }
            }
        }
    }
    Item  {
        id : container
    }

}

