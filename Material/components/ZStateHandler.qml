import QtQuick 2.0
//import "Lodash"
//The purpose of this class is to manage the state of all components and
//is the controller for the css like states (separated with "-") on every component.

//add aliases to the root of the component and this will be able to see it.

//docs
//"@<propertyName>" : [Colors, "success" ] , the @ tells the statehandler that this is a binding expression ,
//                                           arr[0] is the object to look into. "@parent" is a special key. This will make it
//                                           the current Object's parent.
//                                           arr[1] is the name of property to bind to.
//                                           arr[2] , if provided, is the modifier (multiplied) to that value


pragma Singleton
Item {
    id : rootObject

    function setState(target, state, statesPropertyName) {
//        var s = state; console.time(s);

        if(logic.isUndef(target) || logic.isUndef(state))
            return false;

        if(logic.isUndef(statesPropertyName))
            statesPropertyName = "states"

        //this is the object that holds all the state json
        var statesObj = target ? target[statesPropertyName] : undefined
        if(logic.isUndef(statesObj))
            return false;

        if(state === "")
            state = 'default'
        else if(state.indexOf('default') !== 0){
            state = 'default-' + state
        }

        var obj = {}      //merge all states into this in order and then apply!
        var sArr = state.split('-')
        for(var i = 0; i < sArr.length; ++i){
            var sItem = statesObj[sArr[i]]
            logic.merge(obj, sItem);
        }

//        console.log(_.keys(obj))
        logic.loadObj(target, obj)
        //we have the obj now, now we just need to apply this thing on the target


//        console.timeEnd(s)
        return true;
    }


    function setState_old(target, state, statesPropertyName) {
//        var s = state; console.time(s);


        if(logic.isUndef(target) || logic.isUndef(state))
            return false;

        if(logic.isUndef(statesPropertyName))
            statesPropertyName = "states"

        //always load default state first!
        logic.loadState(target, 'default', statesPropertyName)

        //now load the other states on top
        if(state === "default" || state === "") //we have already loaded them
            return false;

        if(state.indexOf("-") === -1) {
            logic.loadState(target, state, statesPropertyName)
        }
        else {
            var arr = state.split("-");
//            var log = state.indexOf("semi") !== -1 ? true : false

            for(var i = 0; i < arr.length; i++) {
//                if(log) console.log(arr[i])
                logic.loadState(target, arr[i], statesPropertyName)
            }
        }

        target.state = state;
//        console.timeEnd(s);
        return true;
    }

    QtObject {
        id: logic
        function loadObj(target, obj) {
            if(obj) {
                for(var k in obj) {
                    if(!loadInnerProperty(target, k, obj[k] , target))
                        console.log("could not find", k, "on", target)
                }
            }
        }

        function loadState(target, state, statesPropertyName) {
            var statesObj = target ? target[statesPropertyName] : null
            if(isUndef(statesObj))
                return false;



            var obj = statesObj[state]
            if(obj) {
                for(var k in obj) {
                    if(!loadInnerProperty(target, k, obj[k] , target))
                        console.log("could not find", k, "on", target)
                }
            }
        }
        function loadInnerProperty(target, prop, stateObject, rootObject){
            var obj = prop === "rootObject" ? target : deepGet(target,prop)
            if(obj) {
                for(var key in stateObject) {
                    var item = stateObject[key]

                    if(key.indexOf("@") === 0){
                        //is a binding expressioN!!
                        var k = key.slice(1);

                        if(isArray(item) && item[0] === "@parent" ){
                            if(obj.parent) {
                                item[0] = obj.parent
                            }
                            else
                                item[0] = rootObject


                        }
                        dotSet(obj,k,item,true, rootObject);
                    }
                    else {
                        if(typeof item === 'object' && !isArray(item))    loadInnerProperty(obj ,key, item , rootObject)
                        else                                              dotSet(obj,key,item, false, rootObject)
                    }
                }
                return true;
            }
            return false;
        }

        //HELPERS
        function isDef(arg){
            return arg !== null && typeof arg !== 'undefined'
        }
        function isUndef(arg) {
            return !isDef(arg)
        }
        function dotSet(obj, propStr, value, bind , root) {
            if(isUndef(obj))
                return;

            if(propStr.indexOf(".") === -1 && obj.hasOwnProperty(propStr)) {
//                console.log("set", obj, propStr,value,bind,root)
                set(obj,propStr,value,bind , root)
            }
            else {
                var arr = propStr.split(".")
                var ptr = obj
                for(var i = 0; i < arr.length; i++){
                    var current = arr[i]
                    if(isUndef(current))
                        continue

                    if(ptr.hasOwnProperty(current) || isDef(ptr[current])) {

                        if(i !== arr.length - 1)  ptr = ptr[current]            //advance ptr
                        else {
                            set(ptr,current,value,bind , root)
                        }

                    }
                    else {
                        console.error(root, "error at" , current)
                        break
                    }
                }
            }
        }
        function set(obj, prop, value, bind, root){
            if(bind) {
                if(isFunction(value))
                    obj[prop] = Qt.binding(value)
                else if(isArray(value) && value.length > 1){
//                    console.log(obj,prop,value)
                    if(value.length > 2)
                        obj[prop] = Qt.binding(function() { return value[0][value[1]] * value[2] } )
                    else
                        obj[prop] = Qt.binding(function() { return value[0][value[1]] })
                }
                else if(typeof value === 'object'){
                    if(value.modifier)
                        obj[prop] = Qt.binding(function() { return value.key[value.value] * value.modifier} )
                    else
                        obj[prop] = Qt.binding(function() { return value.key[value.value] } )
                }
                else {
                    console.error(root, "Incorrect format for binding!!", obj, prop, value, bind)
                }
            }
            else {
//                console.log(obj,prop,"=",value)
                obj[prop] = value;
            }
        }

        function deepGet(obj, propStr){
            if(isUndef(obj, propStr))
                return null

    //            console.log(propStr)
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
    //                        console.log(varname)
                        //remove the whole between [ and ]
                    }
                    propStr = propStr.replace(propStr.slice(startIdx, endIdx +1)  , "@")
    //                    console.log(propStr)
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
            propArray = propStr
    //            console.log("end = > ", propArray)

            if(isDef(obj,propArray)){
                //iterate!!
                var objPtr = obj
                for(var p in propArray){
                    var prop = propArray[p]
                    if(isDef(objPtr[prop])){
                        objPtr = objPtr[prop]
                    }
                    else
                        return null
                }
                return objPtr
            }
            else
                return null
        }
        function isArray(obj){
            return toString.call(obj) === '[object Array]';
        }
        function isFunction(obj) {
            return toString.call(obj) === '[object Function]';
        }


        function merge(obj1, obj2, cloneArrays){
            if(!obj2)
                return;

            if(!obj1)
                obj1 = {}

            for(var o in obj2){
                var o2 = obj2[o]
                if(typeof o2 === 'object'){ //we only care bout the linkages!!

                    if(toString.call(o2) === '[object Array]') {    //o2 is array
                        if(cloneArrays){
                            obj1[o] = []
                            for(var a = 0 ; a < o2.length ; ++a){
                                obj1[o][a] = {}
                                merge(obj1[o][a] , o2[a], cloneArrays)
                            }
                        }
                        obj1[o] = o2
                    }
                    else {
                        if(!obj1[o])
                            obj1[o] = {}

                        merge(obj1[o], obj2[o], cloneArrays)
                    }
                }
                else {
                    obj1[o] = o2
                }
            }
        }


    }
}
