import QtQuick 2.5
import "ArrayModelFactory.js" as AM
import "Lodash"


//COMMANDMENTS
//1) If key doesn't exist, create it
//2) If value type of update is different than original value type, error!
//3) All arrays should have ids. Otherwise they are replaced on update
//4) Partial updates all teh way thru (deep)
//5) DELETE req only occurs on arrays with ids (root level or elsewhere)
//6) PUT updates, POST adds
//7) All server REST commands should be prepended by a version number. Each model should have versions.




QtObject {
    id : rootObject
    property var arr
    property int length : -1    //undefined!
    readonly property alias mapKeys : priv.mapKeys  //can only be changed on init fools!!

    signal deleted(string path);
    signal updated(string path, var oldValue, var value);
    signal created(string path, var value);
    signal mapsUpdated(string mapName, string group, int index);
    signal mapsAdded  (string mapName, string group, int index);
    signal mapsDeleted(string mapName, string group, int index);
//    signal mapsChanged(string mapName, string value, int index);

    property alias priv : priv

//    onArrChanged : if(!arr)
//                       length = -1;



    //The indices inside the mapKeys can be paths , not just root level entries.
    //If the resultant item is an object (at a map key), it will be stringified as a key
    //e.g.,
    // mapKeys = ['hobbies.0' , ]
    //THE maps point to arrays because not all mapKeys are unique you know.
    //Two people might have the same hobbies.0
    function init(arr, mapKeys) {
        if(!arr)
            return;

        reset();
        if(mapKeys && toString.call(mapKeys) !== '[object Array]') {
            mapKeys = [mapKeys]
        }

        if(_.indexOf(mapKeys,'id') === -1)
            mapKeys.push('id')

        //add pointers. Managing them is gonna be a chore but should improve our life hopefully!


        //let's make all the maps necessary & delete mapKeys that are derpy, the reason to do it here
        //is so we dont have these checks when we are iterating over our super large array (potentially)
        for(var i = mapKeys.length - 1; i>=0 ; --i) {
            var key = mapKeys[i]
            var type = typeof key
            if(type !== 'string' && type !== 'number'){
                mapKeys.splice(i,1);
            }
            else{
                if(!priv.maps[key])
                    priv.maps[key] = {}
            }
        }


        rootObject.arr = arr;
        rootObject.length = arr.length;
        priv.mapKeys = mapKeys;

        _.each(arr, function(v,k){
            priv.addItemToMaps(v);
        })

//        console.log(JSON.stringify(priv.maps,null,2))
    }


    //fn <function> , passes arr items into this. if returns true, item/item's index is returned.
    //returnIndex <bool default=false> , determines whether to return the index or the item
    //return type <var / number> , returns item or index
    function findFirst(fn, returnIndex, startIndex){
        if(!arr || typeof fn !== 'function')
            return returnIndex ? -1 : null

        startIndex = startIndex || 0
        for(var i = startIndex; i < arr.length ; ++i){
            var a = arr[i]
            if(fn(a))
               return returnIndex ? i : a
        }
        return returnIndex ? -1 : null
    }

    //fn <function> , passes arr items into this. if returns true, item is added to results.
    //returnIndices <bool default=false> , return the respective indices of items instead of items themselves.
    //return type <array> , returns array of all items or indices found
    function find(fn,returnIndices, startIndex){
        if(!arr || typeof fn !== 'function')
            return []

        startIndex = startIndex || 0
        var ret = []
        for(var i = startIndex; i < arr.length ; ++i){
            var a = arr[i]
            if(fn(a))
               ret.push(returnIndices ? i : a)
        }
        return ret;
    }


    //Ids should be unique, this let's us hide the fact that id map is also
    //an array on each entry
    function getById(id, path, opt_defaultVal){
        var r = getMapGroup('id', id, path, opt_defaultVal);
        if(toString.call(r) === '[object Array]' && r.length > 0)
            return r[0];
        return opt_defaultVal;
    }

    function setById(id, path, value, onlyUpdate){
        if(priv.isUndef(id))
            return console.error("No id provided!")

        if(path){
            //safety check!
            var t = typeof path
            if(t === 'object') {
                if(value === undefined) {
                    value = path;
                    path = ""
                }
                else {
                    return console.error("ArrayModel::setById:: HEY! You passed an object as path instead of string")
                }
            }
            else if(t !== 'string')
                return console.error("ArrayModel::setById:: HEY! You passed an object as path instead of string")

            if(path.length > 0 && path.charAt(0) !== ".")
                path = "." + path
        }
        else
            path = ""


        //make sure that this object has id !
        value.id = id;

        var idx = findFirst(function(a){ return a.id == id } , true)
        if(idx !== -1){
            set(idx + path, value, onlyUpdate);
        }
        else {
            set(length + path, value, onlyUpdate);     //we are saying add new item at index of length!
        }
    }


    //Returns array of all the items that are fit to be in the map by virtue of
    //having key mapVal. You can think of these as filters if it helps
    function getMapGroup(mapName, mapVal, path, opt_defaultVal) {
        var map = priv.maps[mapName]
        if(!map)
            return opt_defaultVal

        var itemArr = map[mapVal]
        if(priv.isUndef(itemArr))
            return opt_defaultVal

        if(!path)
            return itemArr;

        var ret = []
        _.each(itemArr, function(item){
            ret.push( get(path,opt_defaultVal,item) );
        })
        return ret;
    }

    function get(path,opt_defaultVal,opt_obj) {
        opt_obj = opt_obj || arr;
        if(!opt_obj)
            return null;
        if(!path)
            return opt_obj;

        return priv.deepGet(opt_obj,path);
    }

    //path <string> : the path in <opt_obj> where to set <value>
    //value <var>   : the value to be set
    //onlyUpdate <bool default=false> : turning this flag on means we never add new keys, only update them
    function set(path,value,onlyUpdate) {
        var propArr = priv.propertyStringToArray(path);
        if(propArr.length === 0)
            return ;

        if(!arr)
            arr = []

        var createdSigs = []
        var updatedSigs = []

        var idx = propArr[0]
        var rootItem = arr[idx]

        //if idx doesn't exist at root, we know its a new item @ root Level!!
        if(priv.isUndef(rootItem)) {
            priv.deepSet(arr, propArr,value);
            rootItem = arr[idx]
            priv.addItemToMaps(rootItem);

//            created(idx, newItem);
            created(path,value);
            length++;
        }
        else {  //idx does exist, so it won't affect our length property!
//            console.log("root item exists!", idx)
            var newValType  = toString.call(value);
            var existing = priv.deepGet(arr,propArr);
            existing = typeof existing === 'object' ? priv.clone(existing) : existing
            if(existing) {
                //compare things!!!
                var existingType = toString.call(existing);
                if(existingType !== newValType){
                    //its highly possible that this makes our maps out of sync. lets test!
                    priv.deepSet(arr, propArr, value);
                    updated(path, existing, value);
                }
                else if(newValType === '[object Array]'){
                    //we will wipe our original array and replace it. OH BOYO!
    //                _.set(arr,path,value);
                    priv.deepSet(arr, propArr, value);
                    updated(path, existing, value);
                }
                else if(newValType === '[object Object]'){
                    _.each(value, function(v,k){
                        var eVal = existing[k]
                        if(!eVal){
                            createdSigs.push({path : path + "." + k, value : v})
                        }
                        else if(v !== eVal) {
                            updatedSigs.push({path : path + "." + k, value : v , oldValue : eVal })
                        }
                    })

    //                _.set(arr,path,value);
                    priv.deepSet(arr, propArr, value);

                    //emit create, update signals
                    _.each(createdSigs, function(v,k){
                        created(v.path, v.value);
                    })
                    _.each(updatedSigs, function(v,k){
                        updated(v.path, v.oldValue, v.value);
                    })


                }
                else {
                    //simple thing, string or something!
    //                _.set(arr,path,value);
                    priv.deepSet(arr, propArr, value);
                    updated(path, existing, value);
                }

            }
            else if(!onlyUpdate){
    //            _.set(arr,path,value);
                priv.deepSet(arr,propArr,value);
                created(path,value);

                priv.addItemToMaps(rootItem);
            }


        }




//        console.timeEnd('set')

    }


    //resets this to the default state!
    function reset() {
        arr = undefined
        priv.mapKeys = undefined
        priv.maps = { id: {} }
        length = -1;
    }


    property Item __priv : Item {
        id : priv
        property var mapKeys
        property var maps    : ({ id: {} }) //we always have an id map!

//        function reset() {
//            mapKeys = undefined
//            maps = { id: {} }
//        }


        function updateMaps(val, path) {

        }


        function addItemToMaps(item) {
//            console.log("addItemToMaps", JSON.stringify(item))
            _.each(mapKeys, function(m){
                var val = priv.deepGet(item, m);
                val = typeof val === 'object' ? JSON.stringify(val) : val   //this is bad , but we allow it for not smart cookies / ers.
//                console.log("iterating over map", m, val)
                if(isDef(val)) {
                    var map = priv.maps[m]

                    if(!map[val]) {
                        map[val] = [item];
                        mapsAdded(m, val, map[val].length -1);   //since we added a dude, it's almost trivial to get the index here
                    }
                    else if(_.indexOf(map[val],item) === -1) {
                        map[val].push(item);
                        mapsAdded(m, val, map[val].length -1);   //since we added a dude, it's almost trivial to get the index here
                    }


                }
            })
        }
        function removeFromMaps(mapName, val, index){
            var map = priv.maps[mapName]
            if(!map)
                return false;

            var mapGroup = map[val]
            if(!mapGroup || !mapGroup.length > index)
                return false;

            mapGroup.splice(index,1);

            //emit that an entry from a mapGroup was removed!
            mapsDeleted(mapName,val,index);

            //also emit changes cause the index will have changed???
            return true;
        }


        function isUndef(){
            if(arguments.length === 0)
                return true

            for(var i = 0; i < arguments.length ; i++){
                var item = arguments[i]
                if(item === null || typeof item === 'undefined')
                    return true
            }
            return false
        }
        function isDef(){
            if(arguments.length === 0)
                return false

            for(var i = 0; i < arguments.length; i++){
                var item = arguments[i]
                if(item === null || item === undefined)
                    return false
            }
            return true
        }

        function deepSet(obj, propStr, value) {

            function newArrOrObj(keyName){
                return isNaN(parseInt(keyName)) ? {} : []
            }


            var success = true;
            var isFunc  = typeof value === 'function'

            if(isUndef(obj, propStr))
                return false

            if(!propStr) {
                try {
                    obj = isFunc ? Qt.binding(value) : value
                }catch(e) {
                    success = false;
//                    console.log(rootObject, e, "unable to set", obj, 'to', value)
                }
                return success
            }

    //            console.log(propStr)
            var propStrType = toString.call(propStr)
            var propArray = propStrType === '[object String]' ? propertyStringToArray(propStr) :
                                            '[object Array]'  ? propStr : null;

            var currentPropsWalked = ""
            if(isDef(obj,propArray)){
                //iterate!!
                var objPtr = obj
                var prev   = null;

                var advancePtr = function(key){
                    prev = objPtr;
                    objPtr = objPtr[key]
                }

                for(var p = 0; p < propArray.length; ++p){
                    var prop = propArray[p]
                    var isLastIteration = p === propArray.length -1
                    var prevProp = p > 0 ? propArray[p-1] : null
                    var nextProp = isLastIteration ? null : propArray[p+1]

                    currentPropsWalked += currentPropsWalked === "" ? prop : "." + prop


                    //if objPtr is not an object, we need to overwrite it with one in this case
                    if(typeof objPtr !== 'object'){
//                        console.log(p,prop,'case1::objptr is not object')
                        if(typeof prev === 'object' && prevProp) {
                            prev[prevProp] = objPtr = newArrOrObj(prop)
                        }
                        else {
                            console.error(rootObject, "Cannot create new property at" , currentPropsWalked)
                            return false;
                        }
                    }


                    //if objPtr[prop] is undef, we should try to add a new object or array
                    //depending on if prop is a number or a string
                    if(isUndef(objPtr[prop]) && nextProp){
//                        console.log(p,prop,'case2::objptr.',prop, 'is undefined',prop, "not found on", prevProp, "creating")
                        objPtr[prop] = newArrOrObj(nextProp)
                    }


                    //If this is the last iteration, just try to set the value onto objectPtr[prop]
                    if(!isLastIteration){
//                        console.log(p,prop,'case3::advancePtr on', prop)
                        advancePtr(prop)
                    }
                    else {
//                        console.log(p,prop,'case4::set', prop)
                        try {
                            objPtr[prop] = isFunc ? Qt.binding(value) : value
                        }catch(e) {
                            console.error(rootObject, e, "unable to set", obj , ".", currentPropsWalked, 'to', value)
                            success = false;
                        }
                        return success;
                    }




                }
                return objPtr


            }
            else
                return false
        }
        function deepGet(obj, propStr){
            if(isUndef(obj, propStr))
                return undefined

            if(propStr === "")
                return obj

            var propStrType = toString.call(propStr)
            var propArray = propStrType === '[object String]' ? propertyStringToArray(propStr) :
                                            '[object Array]'  ? propStr : null;

            if(isDef(obj,propArray)){
                //iterate!!
                var objPtr = obj
                for(var p in propArray){
                    var prop = propArray[p]
                    if(isDef(objPtr[prop])){
                        objPtr = objPtr[prop]
                    }
                    else
                        return undefined
                }
                return objPtr
            }
            else
                return undefined
        }

        //turn this into a nice array that we can just walk over!!
        //[1]foo.bar[0].green[0]
        function propertyStringToArray(propStr){
            function compactInPlace(arr){
                for(var a = arr.length - 1; a >= 0; --a){
                    var entry = arr[a]
                    if(isUndef(entry) || entry.length === 0) {
                        arr.splice(a,1)
                    }
                }
                return arr;
            }

            var propArray = []
            if(typeof propStr === "string"){
                //turn this into a nice array that we can just walk over!!
                //[1]foo.bar[0].green[0]

                //first lets convert the []s into dots
                while(propStr.indexOf("[") !== -1){
                    var startIdx = propStr.indexOf("[")
                    var endIdx   = propStr.indexOf("]")

                    if(startIdx +1  !== endIdx ){
                        var varname = propStr.slice(startIdx+1, endIdx )
                        propArray.push(varname)
                    }
                    propStr = propStr.replace(propStr.slice(startIdx, endIdx +1)  , "@")
                }

                //now subdivide on "."
                propStr            = propStr.split(".")
                var propArrCounter = propArray.length - 1
                for(var i = propStr.length - 1; i >= 0; i--){

                    while(propStr[i].indexOf("@") !== -1){
                        varname = propStr[i]
                        var idx = propStr[i].indexOf("@")
                        if(idx !== -1){
                            if(idx === 0){  //insert var before
                                propStr[i] = varname.slice(1)
                                propStr.splice(i,0, propArray[propArrCounter])
                                propArrCounter--
                            }
                            else{           //insert var after (this is at the end)
                               propStr[i] = varname.slice(0,-1)
                               propStr.splice(i+1,0, propArray[propArrCounter])
                               propArrCounter--
                            }
                        }
                    }
                }
            }
            return compactInPlace(propStr); //at this poiint its an array!
        }





        function clone(obj) {
            return JSON.parse(JSON.stringify(obj));
        }








    }


}
