import QtQuick 2.0
import Zabaat.Misc.Global 1.0
ListModel
{
    id : lm
    objectName: "objectModel"

    property var  map     : []
    property bool embeddedLists : true

    signal selected(string name, var obj);
    property var addItem : function (name,obj){

        if(map[name])
        {
            ZGlobal.debugBypass(name,'is already open')
            return false
        }

        var newObj
        if(embeddedLists){

            var source = ZGlobal.functions.spch(Qt.resolvedUrl('.'))
            var newList = ZGlobal.functions.getQmlObject(['QtQuick 2.4',source],'ObjectModel{ embeddedLists : false; }',lc)
            newObj = {name: name, main : obj, open : newList}
        }
        else{
            newObj = {name: name, main : obj}
        }

        lm.append(newObj)
        map[name] = newObj
        return true
    }

    property Item listContainer : Item {
        id : lc
    }


    property var removeFromList : function(obj){
//        printListModel("BEFPORE")
        for(var i = 0; i < lm.count; i++)
        {
            var elem = lm.get(i)
            if(elem.open){
                if(tryRemove(obj, elem.open)) {
//                    printListModel("AFTER")
                    return true
                }
                else if(elem.main === obj && obj !== null)
                {
                    if(map[obj.objectName]){
    //                    console.log('killing', elem.main)
                        console.log("MAIN IS", elem.main, "MAIN's PARENT IS", elem.main.parent)
                        console.log('DELETING', obj)
                        delete map[obj.objectName]
                    }



    //                elem.main.parent = null
    //                elem.main.destroy()
                    lm.remove(i)
                    return true
                }
            }
        }
        console.log('remove from list failed horribly')
        return false
    }

    property var tryRemove: function(obj, list){

        for(var i = 0; i < list.count; i++)
        {
            var elem = list.get(i)
            if(elem.main === obj && obj !== null)
            {
                if(map[obj.objectName]){
//                    console.log('killing', elem.main)
                    console.log('DELETING', obj)
                    console.log("MAIN IS", elem.main, "MAIN's PARENT IS", elem.main.parent)
                    delete map[obj.objectName]
                }


//                elem.main.parent = null
//                elem.main.destroy()
                list.remove(i)
                return true
            }
        }
        return false
    }



    property var closeFunc : function(obj) {
//        console.log("closing", obj)
        for(var i = 0; i < lm.count; i++)
        {
            var elem = lm.get(i)
            if(elem.main === obj && obj !== null)
            {
                if(map[obj.objectName]){
//                    console.log('killing', elem.main)
                    console.log('DELETING', obj)
                    delete map[obj.objectName]
                }

                elem.main.parent = null
                elem.main.destroy()
                lm.remove(i)
                break
            }
        }

        if(obj.hasOwnProperty('destroy')) {
//            console.trace()
//            console.log("destroying zLoader")
            obj.destroy()
        }

        //printListModel()
    }

    function printListModel(text, list)
    {
        if(ZGlobal.functions.isUndef(list))        list = lm
        if(ZGlobal.functions.isUndef(text))        text = ""

//        console.log(text, 'ProjectComponents/ObjectModel.qml--->printListModel()')
        for(var i = 0; i < list.count; i++)
        {
            var elem = list.get(i)
            console.log(text, elem.main)

            if(elem.open){
                printListModel("\t" , elem.open)
            }
        }
//        console.log('Map elems')
//        console.log(JSON.stringify(map,null,2))
    }

    function wipe(list){
        if(ZGlobal.functions.isUndef(list))
            list = lm

        for(var i = 0; i < list.count; i++){
            var elem = list.get(i)
            if(elem.main)
                elem.main.destroy()
            if(elem.open)
                wipe(elem.open)
        }

        list.map = []
        list.clear()
    }


}

