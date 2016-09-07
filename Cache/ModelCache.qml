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
        return a.deleted ? true : false
    }

    //The function that determines two items in the list/item are the same!
    property var equalityFunc : function(a,b){
        return a.id == b.id
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
            arr = _.filter(arr, function(a) {

                //iterates over arr_only and compares a & v using equalityFunc.
                //False if nothing is equal to a in arr_only, meaning we will filter it :)
                return  _.some(arr_only, function(v) {
                    if(equalityFunc(a,v))
                        return true;
                })
            })
        }

        opt_keys = typeof opt_keys === 'string' ? [opt_keys] : opt_keys
        if(opt_keys && toString.call(opt_keys) === '[object Array]') {
            arr = _.reduce(arr, function(a,v,k) {
                a.push(_.pick(v,opt_keys));
                return a;
            }, [])
        }


        var res = file.writeFile(cacheDir,name,JSON.stringify(arr,null,2))
        console.log("Wrote file", cacheDir + "/" + name, "=",res)
        return res;
    }


    //name     <string>                    : the name of the cache file. This is loaded from cacheDir
    //m        <array / listmodel>         : the list model / array to load this cache into
    //cb       <optional function>         : is called when the loadCache operation finishes. Important if create,delete,update are async functions.
    //arr_only <optional array / 1 object> : array of items that is in line with equality func that tells us to only process these ids!
    function loadCache(name,m, cb, arr_only){
        if(!m)
            return false;

        var fileLocation = cacheDir + "/" + name
        var f = file.readFile(fileLocation);
        try {
            var js = JSON.parse(f);
            sync(m,js, cb, arr_only);
            return m;
        }
        catch(e){
            return false;
        }
    }

    //name <string> : remove this cache file from our cacheDir
    function deleteCache(name) {
        var fileLocation = cacheDir + "/" + name

        //TODO FIX? Apparently this is not a function somehow. WUT M8?
        return file.deleteFile(fileLocation);
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
//                console.log("ModelCache::src Arr length is 0. Done.")
                return typeof cb === 'function' ? cb() : false;
            }


            //iterate thru src array & isolate elements that we need to perform operations with. I.e, new elements not found in our model
            //and elements that are newer in the srcArr
            _.each(srcArr,function(v){

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
                    if(srcIsNewer)
                        procArr.push({v : v, i : idx });
                }
                else {  //we add all the stuff later because we dont want the performance to degrade on .getFromList_v2
                    addArr.push(v);
                }
            })


            //Set up callback stuff
            var totalCbs = addArr.length + procArr.length;
            var cbCount  = 0;

            if(totalCbs <= 0) {
//                console.log("ModelCache::total ops length is 0. Done.")
                return typeof cb === 'function' ? cb() : false;
            }

            var opCb     = function() {
                ++cbCount;
//                console.log(cbCount, "/", totalCbs , "Called!")
                if(cbCount >= totalCbs && typeof cb === 'function') {
//                    console.log('!!!!!!!!!!!! modelCache::MAIN CALLBACK.' , cbCount +"/" + totalCbs)
                    cb();
                }
            }



            //proc the stuff we know we need to process,
            //if the src is newer && we determined that src was deleted, call delete, otehrwise update
            _.each(procArr, function(val) {
                var v = val.v
                var idx = val.i

                return determineDeletedFunc(v) ? deleteFunc(destArr,v,idx,opCb) : updateFunc(destArr,v,idx,opCb);
            })


            //add the stuff we didn't find!
            _.each(addArr,function(v){
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
//                console.log("ModelCache::src Arr length is 0. Done.")
                return typeof cb === 'function' ? cb() : false;
            }




            _.each(srcArr,function(v){

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
                else {  //we add all the stuff later because we dont want the performance to degrade on .getFromList_v2
                    addArr.push(v);
                }
            })

            var totalCbs = addArr.length + procArr.length;
            var cbCount  = 0;

            if(totalCbs <= 0) {
//                console.log("ModelCache::total ops length is 0. Done.")
                return typeof cb === 'function' ? cb() : false;
            }


            var opCb = function() {
                ++cbCount;
//                console.log(cbCount, "/", totalCbs , "Called!")
                if(cbCount >= totalCbs && typeof cb === 'function') {
//                    console.log('!!!!!!!!!!!! modelCache::MAIN CALLBACK.' , cbCount +"/" + totalCbs)
                    cb();
                }
            }

            //proc the stuff we know we need to process,
            //if the src is newer && we determined that src was deleted, call delete, otehrwise update
            _.each(procArr, function(val) {
                var v = val.v
                var idx = val.i

                return determineDeletedFunc(v) ? deleteFunc(destModel,v,idx,opCb) : updateFunc(destModel,v,idx,opCb);
            })


            //add the stuff we didn't find!
            _.each(addArr,function(v){
                createFunc(destModel,v,opCb);
            })
        }

        ZFO.ZFileOperations { id : file  }
        ZFO.ZPaths          { id : paths }


    }



}
