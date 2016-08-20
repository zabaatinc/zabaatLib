//Creates a view model on a RESTFULArray or an inside part of it
import QtQuick 2.5
ListModel {
    id : lm
    property var ptr_RESTFULArray
    property alias path : logic.path   //The path where the array is. Leave empty for root level stuff


    property Item logic : Item {
        id : logic

        Connections {
            target : ptr_RESTFULArray ? ptr_RESTFULArray : null
            onCreated : {   //path,data,oldData
                if(logic.signalMatchesPath(path)){
//                    console.log("APPENDING", path, JSON.stringify(data))
                    lm.append({id:data.id})
                }
            }
            onUpdated : {   //path,data

            }
            onDeleted : {   //path
                if(logic.signalMatchesPath(path)){
                    logic.remove(data.id);
                }
            }
        }


        property string path : ""
        property var propArr : {
            var arr = path.split('/')
            for(var i = arr.length - 1; i >=0 ; i--){
                var aa = arr[i]
                if(aa === null || aa === undefined || aa === '')
                    arr.splice(i,1);
            }
            propArr = arr;
        }

//        onPropArrChanged: console.log("PROPARR", propArr)


        function signalMatchesPath(path){
            //to make sure that we are listening to updates that we need!
            if(path.indexOf(logic.path) !== 0)
                return false;

            var updatePropArr  = path.split("/");
//            console.log(updatePropArr, propArr, updatePropArr.length - propArr.length)
            return (updatePropArr.length - propArr.length) === 1
            //for instance, we are listening on
            //0/pets and we get a message of 0/pets/0 , we will accept that!
            //but if we get a mesage of 0/pets/0/name , we will deny it!
            //This makes it so we don't double listen to updates !
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
