//Creates a view model on a RESTFULArray or an inside part of it
import QtQuick 2.5
ListModel {
    id : lm
    property var ptr_RESTFULArray
    property string path : ""   //The path where the array is. Leave empty for root level stuff

    Connections {
        target : ptr_RESTFULArray ? ptr_RESTFULArray : null
        onCreated : {   //path,data,oldData
            if(path.indexOf(lm.path) === 0 && logic.updateMsgIsAtRoot(path,data)){
                lm.append({id:data.id})
            }
        }
        onUpdated : {   //path,data

        }
        onDeleted : {   //path
            if(path.indexOf(lm.path) === 0 && logic.updateMsgIsAtRoot(path,data)){
                lm.append({id:data.id})
            }
        }
    }

    QtObject {
        id : logic

        function updateMsgIsAtRoot(path,data){

        }

        function remove(id) {
            for(var i = 0; i < lm.count; ++i){
                if(lm.get(i).id == id){
                    lm.remove(i)
                    return true;
                }
            }
            return false;
        }


    }



}
