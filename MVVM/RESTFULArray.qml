import QtQuick 2.5
import "Lodash"

//COMMANDMENTS
//1) If key doesn't exist, create it. default assumption is object!
//2) If value type of update is different than original value type, error!
//3) All arrays should have ids. Otherwise they are replaced on update
//4) Partial updates all teh way thru (deep)
//5) DELETE req only occurs on arrays with ids (root level or elsewhere)
//6) PUT updates, POST adds
//7) All server REST commands should be prepended by a version number. Each model should have versions.
Item {
    id : rootObject

    signal updated(string path, var data, var oldData, int index);
    signal created(string path, var data, int index);
    signal deleted(string path, int index);

    readonly property alias length : priv.length
    readonly property alias arr    : priv.arr

    function runUpdate(data) {
        var type = toString.call(data);
        var isArr = type === '[object Array]'
        var isObj = type === '[object Object]'

        if(!isArr && !isObj)
            return false;

        //if our array isn't even initialized, then let's
        //init it!
        if(!priv.arr) {
            var d = isArr ? data : [data]
            priv.arr = _.filter(d, function(v){
                return priv.isDef(v.id)
            })

            //emit created messages!!!
            _.each(priv.arr, function(v,k){
                priv.addId(v.id, v);
                created(v.id, v, k);
            })
            priv.length = priv.arr.length;
        }

        if(isArr){
            _.each(data, function(v){
                set(v.id, v);
            })
            return true;
        }
        else if(isObj) {
            return set(data.id, data);
        }

        return false;

    }



    function set(path, data) {
        var propArr = priv.getPathArray(path);
        if(!propArr || propArr.length === 0)
            return runUpdate(data);

        var ret =  priv.deepSet(priv.arr, propArr, data);
        if(ret.type){
            if(ret.type === 'create') {
                created(path, data)
            }
            else if(ret.type === 'update') {
                updated(propArr[0], data, ret.oldVal, index)
            }
        }



    }


    //If we are on an array, we should first look on the key 'id', then on index!
    function get(path) {
        if(!priv.arr)
            return undefined;

        var propArr = priv.getPathArray(path);
        return !propArr ?  priv.arr : priv.deepGet(priv.arr, propArr);
    }


    function del(path) {
        var propArr = priv.getPathArray(path)
        if(!propArr || propArr.length === 0)
            return false;

        if(propArr.length === 1) {  //is on da root level!
            var id  = propArr[0]
            var idx = priv.findById(priv.arr, id, true)
            if(idx !== -1) {
                priv.arr.splice(idx,1);
                delete priv.idMap[id];
                deleted(id,idx);
                priv.length--;
                return true;
            }
            return false;
        }
        else {
            priv.deepDel(priv.arr, propArr);
        }
    }




    QtObject {
        id : priv
        property var idMap : ({})
        property var arr
        property int length : 0

        //helpers!
        function clone(obj){
            return JSON.parse(JSON.stringify(obj))
        }
        function addId(id,value){
            if(!idMap)
                idMap = {}
            idMap[id] = value;
        }
        function isComplexObject(obj) {
            var t = toString.call(obj)
            return t === '[object Array]' || t === '[object Object]'
        }
        function isSimpleObject(obj) {
            return !isComplexObject(obj);
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
        function getPathArray(pathStr) {
            var type = typeof pathStr

            if(!pathStr || !type === 'string' || !type === 'number')
                return null;

            return pathStr.split("/")
        }
        function idExists(id) {
            return idMap && isDef(idMap[id]) ? true : false
        }
        function findById(array, id, returnIndex){
            var badVal = returnIndex ? -1 : null
            if(!array)
                return badVal

            for(var i in array) {
                var a = array[i]
                if(a.id === id)
                    return returnIndex ? i : a
            }
            return badVal
        }

        //meaty functions, heavy lifters!
        function deepSet(item, pathArr, value) {
            //if there's no item to do this set operation on
            //or if there's no path provided , return false;
            if(!item || !pathArr)
                return false;


            //set up pointer and prevPtr!
            var ptr = item ;
            var prevPtr = null;
            var idx

            function advancePtr(key) {

                function adv(key){
                    prevPtr = ptr;
                    ptr = ptr[key];
                    return key;
                }

                var ptrType = toString.call(ptr)
                if(ptrType === '[object Array]') {
                    var idx = findById(ptr,key,true)
                    if(idx !== -1){
                        return adv(idx);
                    }
                    else if(isDef(ptr[key])) {
                        return adv(key)
                    }
                    return undefined;
                }
                else if(ptrType === '[object Object]') {
                    return isDef(ptr[key]) ? adv(key) : undefined;
                }

                return undefined;
            }


            for(var k = 0; k < pathArr.length ; ++k) {
                var prop = pathArr[k]

                var isLast = k === pathArr.length - 1
                if(isLast) {    //udpate value!!
                    var oldVal = ptr[prop]
                    if(oldVal === null || oldVal === undefined) {
                        ptr[prop] = value;

                        //EMIT UPDATE SIGNALs! & Create!
                        return {type:'create', idx : idx} //UDPATE & CREATE
                    }
                    else {
                        var oldIsComplex = isComplexObject(oldVal)
                        var newIsComplex = isComplexObject(value)

                        var oldType = toString.call(oldVal)
                        var newType = toString.call(value)
                        if(oldType !== newType  && (oldIsComplex || newIsComplex))   {
                            console.error("COMMANDMENT 2 : Cannot Change complex value type!")
                            return false;
                        }

                        //vals are not the same so we can do update!
                        if(oldVal != value) {
                            //make a clone, because we are about to wipe this thing!
                            oldVal = oldIsComplex ? clone(oldVal) : oldVal;

                            ptr[prop] = value;
                            return {type:'update',oldVal:oldVal, idx : idx}; //UPDATE
                        }
                    }
                }
                else if(isComplexObject(ptr)) {
                    if(ptr === arr){    //is root!
                        var aresult = advancePtr(prop)
                        if(aresult)
                            idx = aresult;
                    }
                    else {
                        if(!advancePtr(prop)) { //create the property cause it doesn't exist!
                            ptr[prop] = {}
                            advancePtr(prop)
                        }
                    }
                }
                else {
                    console.error("deepSet::Cannot apply update. Not sufficient info provided perhaps? object at", prop , "is not a property at root level")
                    return false;
                }

            }





        }
        function deepGet(item, pathArr) {
            var ptr     = item
            var prevPtr = null;
            var retVal

            function advancePtr(key) {

                function adv(key){
                    prevPtr = ptr;
                    ptr = ptr[key];
                    return true;
                }

                var ptrType = toString.call(ptr)
                if(ptrType === '[object Array]') {
                    var idx = findById(ptr,key,true)
                    if(idx !== -1){
                        return adv(idx);
                    }
                    else if(isDef(ptr[key])) {
                        return adv(key)
                    }
                    return false;
                }
                else if(ptrType === '[object Object]') {
                    return isDef(ptr[key]) ? adv(key) : false;
                }

                return false;
            }


            _.some(pathArr, function(prop, k) {
                var isLast = k === pathArr.length -1
                if(isLast) {
                    retVal = ptr[prop]
                }
                else {
                    if(!advancePtr(prop)) {
                        console.error("no such property as", prop)
                        return true;
                    }
                }
            })
            return retVal
        }
        function deepDel(item, pathArr){

        }

    }


}

