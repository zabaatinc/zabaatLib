import QtQuick 2.5
import "ArrayModelFactory.js" as AM
import "Lodash"
QtObject {
    id : rootObject
    property var arr
    property int length : -1    //undefined!

    signal deleted(string path);
    signal updated(string path, var oldValue, var value);
    signal created(string path, var value);


    onArrChanged : {
        if(!arr)
            length = -1;
        else {
            length = arr.length;
        }
    }


    function get(path,opt_defaultVal) {
        if(!arr)
            return null;
        if(!path)
            return arr;

        return priv.deepGet(arr,path);
    }
    function set(path,value,onlyUpdate) {
        console.time('set')
        if(!arr)
            arr = []

        var createdSigs = []
        var updatedSigs = []


        var newValType  = toString.call(value);
        var existing = priv.deepGet(arr,path);
        existing = typeof existing === 'object' ? priv.clone(existing) : existing
        if(existing) {
            //compare things!!!
            var existingType = toString.call(existing);
            if(existingType !== newValType){
//                _.set(arr,path,value);
                priv.deepSet(arr, path, value);
                updated(path, existing, value);
            }
            else if(newValType === '[object Array]'){
                //we will wipe our original array and replace it. OH BOYO!
//                _.set(arr,path,value);
                priv.deepSet(arr, path, value);
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
                priv.deepSet(arr, path, value);

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
                priv.deepSet(arr, path, value);
                updated(path, existing, value);
            }

        }
        else if(!onlyUpdate){
//            _.set(arr,path,value);
            priv.deepSet(arr,path,value);
            created(path,value);
        }
        console.timeEnd('set')
    }




    property Item __priv : Item {
        id : priv


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
            var success = true;
            var isFunc  = typeof value === 'function'

            if(isUndef(obj, propStr))
                return false

            if(!propStr) {
                try {
                    obj = isFunc ? Qt.binding(value) : value
                }catch(e) {
                    success = false;
                    console.log(rootObject, e, "unable to set", obj, 'to', value)
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
                for(var p = 0; p < propArray.length; ++p){
                    var prop = propArray[p]
                    var isLastIteration = p === propArray.length -1
                    currentPropsWalked += currentPropsWalked === "" ? prop : "." + prop


                    if(isDef(objPtr[prop])){
                        if(!isLastIteration){
                            objPtr = objPtr[prop]
                        }
                        else {

                            try {
                                objPtr[prop] = isFunc ? Qt.binding(value) : value
                            }catch(e) {
                                console.log(rootObject, e, "unable to set", obj , ".", currentPropsWalked, 'to', value)
                                success = false;
                            }
                            return success;
                        }
                    }
                    else {
                        //this property doesnt exist, we should create it!!
                        //first let's determine if it's creatable. We must be inside an array or object!
                        if(typeof objPtr === 'object'){ //should work for array as well, will create undefines in the middle

                            if(!isLastIteration) {
                                //read the property name, if its a number, kind of assume that it's array?
                                objPtr[prop] = { }
                                objPtr = objPtr[prop]
                            }
                            else {
                                try {
                                    objPtr[prop] = isFunc ? Qt.binding(value) : value
                                }catch(e) {
                                    console.log(rootObject, e, "unable to set", obj , ".", currentPropsWalked, 'to', value)
                                    success = false;
                                }
                                return success;
                            }
                        }
                        else {
                            console.error("Cannot create new property at" , currentPropsWalked)
                            return false;
                        }
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
            return propStr; //at this poiint its an array!
        }

        function clone(obj) {
            return JSON.parse(JSON.stringify(obj));
        }








    }


}
