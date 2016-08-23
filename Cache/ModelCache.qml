import QtQuick 2.5
import Zabaat.Utility.FileIO 1.0 as ZFO
import Zabaat.Utility 1.0
QtObject {
    id : rootObject
    property url cacheDir            : paths.data
    property string specialDeleteKey : 'deleteQuee'

    //Function determines if b is newer than a
    property var determineNewerFunc : function(a, b){
        var d1 = toString.call(a.updatedAt) === '[object Date]' ? a.updatedAt : new Date(a.updatedAt);
        var d2 = toString.call(b.updatedAt) === '[object Date]' ? b.updatedAt : new Date(b.updatedAt);
        return d1 < d2;
    }

    //The function that determines whether an entry was deleted
    property var determineDeletedFunc : function(a){
        return a.deleted ? true : false
    }

    //The function that determines two items in the list/item are the same!
    property var equalityFunc : function(a,b){
        return a.id == b.id
    }

    //The function that adds value into list
    property var createFunc: function(list,value){
        if(Functions.list.isArray(list))
            list.push(value);
        else
            list.append(value);
    }

    //The function that udpates value at idx in list (or you can determine idx by value.id or something)
    property var updateFunc: function(list,value,idx){
        if(Functions.list.isArray(list)){
            list[idx] = value;
        }
        else {
            list.set(idx,value);
        }
    }

    //The function that deletes idx in list (or you can determine idx by value.id or something)
    property var deleteFunc: function(list,value,idx){
        if(Functions.list.isArray(list)){
            list.splice(idx,1);
        }
        else {
            list.remove(idx);
        }
    }



    function cacheModel(name,modelOrArr){
        if(!modelOrArr)
            return;

        var isArr = toString.call(modelOrArr) === '[object Array]'
        var arr   = isArr? modelOrArr : Functions.object.listmodelToArray(modelOrArr) ;
        file.writeFile(cacheDir,name,JSON.stringify(arr,null,2))
    }
    function loadCache(name,m){
        if(!m)
            return false;

        var fileLocation = cacheDir + "/" + name
        var f = file.readFile(fileLocation);
        try {
            var js = JSON.parse(f);
            if( Functions.list.isArray(m) )
                logic.sync(m, js);
            else
                logic.syncModel(m, js);
            return m;
        }
        catch(e){
            return false;
        }
    }

    //returns a new array if none is provided!

    property Item logic : Item {
        id : logic
        function sync(destArr, srcArr){
            var addArr = []
            _.each(srcArr,function(v){
                var idx = Functions.list.getFromArray_v2(destArr,function(a){ return equalityFunc(a,v) },true)
                if(idx !== -1) {
                    var destItem = destArr[idx];
                    var srcIsNewer = determineNewerFunc(destItem,v);

                    //if the src is newer && we determined  that src was deleted, call delete, otehrwise update
                    if(srcIsNewer){
                        return determineDeletedFunc(v) ? deleteFunc(destArr,v,idx) :
                                                         updateFunc(destArr,v,idx);
                    }
                }
                else {  //we add all the stuff later because we dont want the performance to degrade on .getFromList_v2
                    addArr.push(v);
                }
            })

            //add the stuff we didn't find!
            _.each(addArr,function(v){
                createFunc(destArr,v);
            })
        }
        function syncModel(destModel, srcArr){
            var addArr = []
            _.each(srcArr,function(v){
                var idx = Functions.list.getFromList_v2(destModel,function(a){ return equalityFunc(a,v) },true)
                if(idx !== -1) {
                    var destItem = destModel.get(idx);
                    var srcIsNewer = determineNewerFunc(destItem,v);

                    //if the src is newer && we determined  that src was deleted, call delete, otehrwise update
                    if(srcIsNewer){
                        return determineDeletedFunc(v) ? deleteFunc(destModel,v,idx) :
                                                         updateFunc(destModel,v,idx);
                    }
                }
                else {  //we add all the stuff later because we dont want the performance to degrade on .getFromList_v2
                    addArr.push(v);
                }
            })

            //add the stuff we didn't find!
            _.each(addArr,function(v){
                createFunc(destModel,v);
            })
        }

        ZFO.ZFileOperations { id : file  }
        ZFO.ZPaths          { id : paths }


    }



}
