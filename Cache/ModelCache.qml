import QtQuick 2.5
import Zabaat.Utility.FileIO 1.0 as ZFO
import Zabaat.Utility 1.0
QtObject {
    id : rootObject
    property string cacheDir            : paths.data
    property string specialDeleteKey : 'deleteQuee'
    property alias paths : paths;

    //Function determines if b is newer than a
    property var determineNewerFunc : function(a, b){
        var d1 = toString.call(a.updatedAt) === '[object Date]' ? a.updatedAt : new Date(a.updatedAt);
        var d2 = toString.call(b.updatedAt) === '[object Date]' ? b.updatedAt : new Date(b.updatedAt);
        return d1 < d2;
    }

    //The function that determines whether an entry was deleted
    property var determineDeletedFunc : function(a){
        return !!a.deleted
    }

    //The function that determines two items in the list/item are the same!
    property var equalityFunc : function(a,b){
        return a.id === b.id
    }

    //happens after determinedNewer. By default, newer is all we need to determine update so returns true.
    property var determineUpdatedFunc : function(destElem,cacheElem) {
        return true;
    }

    //The function that adds value into list. The cb parameter is provided for long_running, non async functions.
    //This function will call cb (if it is a function) when the task has completed!
    property var createFunc: function(list,value,cb){
        if(Functions.list.isArray(list))
            list.push(value);
        else
            list.append(value);

        if(typeof cb === 'function')
            return cb();
    }

    //The function that udpates value at idx in list (or you can determine idx by value.id or something)
    //The cb parameter is provided for long_running, non async functions.
    //This function will call cb (if it is a function) when the task has completed!
    property var updateFunc: function(list,value,idx, cb){
        if(Functions.list.isArray(list)){
//            console.log("SETTING", JSON.stringify(list[idx]), "TO", JSON.stringify(value))
            list[idx] = value;
        }
        else {
            list.set(idx,value);
        }

        if(typeof cb === 'function')
            return cb();
    }

    //The function that deletes idx in list (or you can determine idx by value.id or something)
    //The cb parameter is provided for long_running, non async functions.
    //This function will call cb (if it is a function) when the task has completed!
    property var deleteFunc: function(list,value,idx, cb){
        if(Functions.list.isArray(list)){
            list.splice(idx,1);
        }
        else {
            list.remove(idx);
        }

        if(typeof cb === 'function')
            return cb();
    }




    //name <string> : the name of the file to save into cacheDir
    //modelOrArr <array/model> : the array/model whose contents are to be saved
    //arr_only <optional array / 1 object> : array of items that is in line with equality func that tells us to only process these ids!
    //opt_keys <optional array>            : array of keys to store, ignore the rest!
    function cacheModel(name,modelOrArr,arr_only,opt_keys){
        if(!modelOrArr)
            return;

        var isArr = toString.call(modelOrArr) === '[object Array]'
        var arr   = isArr? modelOrArr : Functions.object.listmodelToArray(modelOrArr) ;

        if(arr_only && typeof arr_only === 'object') {
            arr_only = toString.call(arr_only) !== '[object Array]' ? [arr_only] : arr_only
            arr = Lodash.filter(arr, function(a) {

                //iterates over arr_only and compares a & v using equalityFunc.
                //False if nothing is equal to a in arr_only, meaning we will filter it :)
                return  Lodash.some(arr_only, function(v) {
                    if(equalityFunc(a,v))
                        return true;
                })
            })
        }

        opt_keys = typeof opt_keys === 'string' ? [opt_keys] : opt_keys
        if(opt_keys && toString.call(opt_keys) === '[object Array]') {
            arr = Lodash.reduce(arr, function(a,v,k) {
                a.push(Lodash.pick(v,opt_keys));
                return a;
            }, [])
        }


        var res = file.writeFile(cacheDir,name,JSON.stringify(arr,null,2))
//        console.log("Wrote file", cacheDir + "/" + name, "=",res)
        return res;
    }


    //name     <string>                    : the name of the cache file. This is loaded from cacheDir
    //m        <array / listmodel>         : the list model / array to load this cache into
    //cb       <optional function>         : is called when the loadCache operation finishes. Important if create,delete,update are async functions.
    //arr_only <optional array / 1 object> : array of items that is in line with equality func that tells us to only process these ids!
    function loadCache(name,m, cb, arr_only){
        if(!m)
            return false;

        var js = loadFile(name);
        if(!js)
            return false;

        sync(m,js,cb,arr_only);
        return true;
    }

    //name <string> : remove this cache file from our cacheDir
    function deleteCache(name) {
        var fileLocation = cacheDir + "/" + name
        return file.deleteFile(fileLocation);
    }

    //loads the file as a js
    function loadFile(name) {
        var fileLocation = cacheDir + "/" + name
        var f = file.readFile(fileLocation);
        try {
            return JSON.parse(f);
        } catch(e) {
            return false;
        }
    }

    //m        <array / listmodel> : the list model / array to load this cache into
    //js       <array>             : the array to sync m with. This is very similar to loadCache method but we dont load a file in this version.
    //cb       <optional function> : is called when the loadCache operation finishes. Important if create,delete,update are async functions.
    //arr_only <optional array/ 1 object>    : array of items that is in line with equality func that tells us to only process these ids!
    function sync(m, js, cb, arr_only) {
        if( Functions.list.isArray(m) )
            logic.sync(m, js, cb, arr_only);
        else
            logic.syncModel(m, js, cb, arr_only);
    }

    function cacheExists(name) {
        var fileLocation = cacheDir + "/" + name
        var r = file.readFile(fileLocation);
        return r ? true : false;
    }



    property Item logic : Item {
        id : logic

        function sync(destArr, srcArr, cb, arr_only){
            var addArr  = []
            var procArr = []

            var inclusionArrayValid = false;
            if(arr_only && typeof arr_only === 'object') {
                arr_only = toString.call(arr_only) !== '[object Array]' ? [arr_only] : arr_only
                inclusionArrayValid = true;
            }

            if(srcArr.length <= 0) {
//                console.log("!!!!!!!!! MCache Done")
                return typeof cb === 'function' ? cb() : false;
            }


            //iterate thru src array & isolate elements that we need to perform operations with. I.e, new elements not found in our model
            //and elements that are newer in the srcArr
            Lodash.each(srcArr,function(v){

                //if arr_only is valid and this v is not in it. then we dont need to care about this v.
                if(inclusionArrayValid) {
                    var includedIdx = Functions.list.getFromArray_v2(arr_only, function(a) { return equalityFunc(a,v) }, true)
                    if(includedIdx === -1) {
                        return;
                    }
                }


                var idx = Functions.list.getFromArray_v2(destArr,function(a){ return equalityFunc(a,v) },true)
                if(idx !== -1) {
                    var destItem = destArr[idx];
                    var srcIsNewer = determineNewerFunc(destItem,v);
//                    console.log("procThis:", srcIsNewer, "val:", JSON.stringify(v,null,2) , destItem.updatedAt, v.updatedAt)
                    if(srcIsNewer) {
                        procArr.push({v : v, i : idx });
                    }
                }
                else if(!determineDeletedFunc(v)) {  //we add all the stuff later because we dont want the performance to degrade on .getFromList_v2
//                    console.log("AddThis:", JSON.stringify(v,null,2))
                    addArr.push(v);
                }
            })


            //Set up callback stuff
            var totalCbs = addArr.length + procArr.length;
            var cbCount  = 0;

            if(totalCbs <= 0) {
//                console.log("ModelCache::total ops length is 0. Done.")
//                console.log("!!!!!!!!! MCache Done")
                return typeof cb === 'function' ? cb() : false;
            }

            var opCb     = function() {
                ++cbCount;
//                console.log(cbCount, "/", totalCbs , "Called!")
                if(cbCount >= totalCbs && typeof cb === 'function') {
//                    console.log("!!!!!!!!! MCache Done")
                    cb();
                }
            }

            //MAKE SURE TO SORT THE PROC ARR BY INDEX DESCENDING!!!!
            //If you don't do this and we delete some element , it will throw off all the indices!!
            procArr.sort(function(a,b){
                return b.i - a.i;
            })

            //proc the stuff we know we need to process,
            //if the src is newer && we determined that src was deleted, call delete, otherwise update
            Lodash.each(procArr, function(val) {
                var v = val.v
                var idx = val.i

                if(determineDeletedFunc(v)) {
                    return deleteFunc(destArr,v,idx,opCb)
                }
                if(determineUpdatedFunc(destArr[idx] , v)) {
                    return updateFunc(destArr,v,idx,opCb);
                }
                else if(typeof opCb === 'function') {
                    opCb(); //so we make sure we do end up calling the cb @ the end!!!
                }
            })


            //add the stuff we didn't find!
            Lodash.each(addArr,function(v){
                createFunc(destArr,v,opCb);
            })


        }
        function syncModel(destModel, srcArr, cb, arr_only){
            var addArr  = []
            var procArr = []

            var inclusionArrayValid = false;
            if(arr_only && typeof arr_only === 'object') {
                arr_only = toString.call(arr_only) !== '[object Array]' ? [arr_only] : arr_only
                inclusionArrayValid = true;
            }

            if(srcArr.length <= 0) {
//                console.log("!!!!!!!!! MCache Done")
                return typeof cb === 'function' ? cb() : false;
            }




            Lodash.each(srcArr,function(v){

                //if arr_only is valid and this v is not in it. then we dont need to care about this v.
                if(inclusionArrayValid) {
                    var includedIdx = Functions.list.getFromArray_v2(arr_only, function(a) { return equalityFunc(a,v) }, true)
                    if(includedIdx === -1)
                        return;
                }

                var idx = Functions.list.getFromList_v2(destModel,function(a){ return equalityFunc(a,v) },true)
                if(idx !== -1) {
                    var destItem = destModel.get(idx);
                    var srcIsNewer = determineNewerFunc(destItem,v);
                    if(srcIsNewer)
                        procArr.push({v : v, i : idx });
                }
                else if(!determineDeletedFunc(v)) {  //we add all the stuff later because we dont want the performance to degrade on .getFromList_v2
                    addArr.push(v);
                }
            })

            var totalCbs = addArr.length + procArr.length;
            var cbCount  = 0;

            if(totalCbs <= 0) {
//                console.log("!!!!!!!!! MCache Done")
                return typeof cb === 'function' ? cb() : false;
            }


            var opCb = function() {
                ++cbCount;
//                console.log(cbCount, "/", totalCbs , "Called!")
                if(cbCount >= totalCbs && typeof cb === 'function') {
//                    console.log("!!!!!!!!! MCache Done")
                    cb();
                }
            }

            //MAKE SURE TO SORT THE PROC ARR BY INDEX DESCENDING!!!!
            //If you don't do this and we delete some element , it will throw off all the indices!!
            procArr.sort(function(a,b){
                return b.i - a.i;
            })

            //proc the stuff we know we need to process,
            //if the src is newer && we determined that src was deleted, call delete, otehrwise update
            Lodash.each(procArr, function(val) {
                var v = val.v
                var idx = val.i

                if(determineDeletedFunc(v)) {
                    return deleteFunc(destModel,v,idx,opCb)
                }
                if(determineUpdatedFunc(destModel.get(idx) , v)) {
                    return updateFunc(destModel,v,idx,opCb);
                }
                else if(typeof opCb === 'function') {
                    opCb(); //so we make sure we do end up calling the cb @ the end!!!
                }
            })


            //add the stuff we didn't find!
            Lodash.each(addArr,function(v){
                createFunc(destModel,v,opCb);
            })
        }

        ZFO.ZFileOperations { id : file  }
        ZFO.ZPaths          { id : paths }


    }



}
