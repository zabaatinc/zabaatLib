import QtQuick 2.5
import "../Lodash"
import Zabaat.Utility 1.0
pragma Singleton
QtObject {
    id : rootObject
    objectName : "RestArrayCreator"
    property alias debugOptions : debugOptions;
//    property alias helpers : helpers;

    //defaults to array construction!
//  js      -> optional . Converts an object or array to special version.
//  path    -> optional . The start of the array (used when an element uses the methods inside signals object).
//  signals -> optional . Should be an object that has these properties or default will be chosen.
//    {lengthChanged         : function(path,len)
//     propertyUpdated       : function(path,data,oldData)
//     propertyCreated       : function(path,data)
//     propertyDeleted       : function(path)
//     beforePropertyUpdated : function(path,data,oldData)
//     beforePropertyCreated : function(path,data)
//     beforePropertyDeleted : function(path)  }
//  idProperty -> The name of the id property inside js that determines element uniqueness. default:"id"
    function create(js, path, signals, idProperty) {
        signals    = debugOptions.standardSignalsPackage(signals);
        idProperty = idProperty || "id";


        return Lodash.isObject(js) ? priv.createObject(js, path, signals, idProperty) :
                                     priv.createArray(js,path, signals, idProperty);
    }

    function addListeners(arr,obj) {
        if(!helpers.isRestful(arr) || !arr._signals || typeof arr._signals.addListeners !== 'function')
            return;

        arr._signals.addListeners(obj);
    }

    function removeListeners(arr,obj) {
        if(!helpers.isRestful(arr) || !arr._signals || typeof arr._signals.removeListeners !== 'function')
            return;

        arr._signals.removeListeners(obj);
    }



    property Item __priv : Item{
        id : priv

        QtObject {
            id : debugOptions
            property bool showPaths : true
            property bool showData  : true
            property bool showOldData : true

            property var batchBeforeCreateMsg: []
            property var batchBeforeUpdateMsg: []
            property var batchBeforeDeleteMsg: []
            property var batchCreateMsg      : []
            property var batchUpdateMsg      : []
            property var batchDeleteMsg      : []

            function allCount(){
                return batchBeforeCreateMsg.length +
                       batchBeforeUpdateMsg.length +
                       batchBeforeDeleteMsg.length +
                       batchCreateMsg.length +
                       batchUpdateMsg.length +
                       batchDeleteMsg.length
            }
            function printAll(){
                Lodash.each(all().sort(), function(v,k){
                    console.log(k,v);
                })
                return "";
            }


            function clearBatches(){
                batchBeforeCreateMsg =  []
                batchBeforeUpdateMsg =  []
                batchBeforeDeleteMsg =  []
                batchCreateMsg       =  []
                batchUpdateMsg       =  []
                batchDeleteMsg       =  []
            }
            function standardSignalsPackage(extraSignals) {
                function prints(path,data,oldData){
                    var p  = helpers.def(path) && debugOptions.showPaths   ? path                     : "";
                    var d  = data     && debugOptions.showData    ? "= "    + JSON.stringify(data)    : "";
                    var od = oldData  && debugOptions.showOldData ? "from " + JSON.stringify(oldData) : "";
                    return { p:p, d:d, od:od }
                }
                function now() {
                    return new Date();
                }

                var fnDebugLengthChanged         = function(path,len){
                    var pr = prints(path,len);
                    if(helpers.def(pr.p)) {
                        var msg = "lenChanged:"+" "+ pr.p +" "+ pr.d+" "+ pr.od
                        debugOptions.batchUpdateMsg.push({msg:msg,time:now()})
                    }
                }
                var fnDebugPropertyUpdated       = function(path,data,oldData){
                    var pr = prints(path,data,oldData);
                    if(helpers.def(pr.p) || pr.d || pr.od){
                        debugOptions.batchUpdateMsg.push({msg:pr.p+" "+ pr.d+" "+ pr.od,time:now()});
                    }
                }
                var fnDebugPropertyCreated       = function(path,data) {
                    var pr = prints(path,data);
                    if(helpers.def(pr.p) || pr.d || pr.od)
                        debugOptions.batchCreateMsg.push({msg:pr.p+" "+ pr.d,time:now()});
                }
                var fnDebugPropertyDeleted       = function(path) {
                    var pr = prints(path);
                    if(helpers.def(pr.p) || pr.d || pr.od)
                        debugOptions.batchDeleteMsg.push({msg:pr.p,time:now()})
                }
                var fnDebugBeforePropertyUpdated = function(path,data,oldData){
                    var pr = prints(path,data,oldData);
                    if(helpers.def(pr.p) || pr.d || pr.od)
                        debugOptions.batchBeforeUpdateMsg.push({msg:pr.p +" "+ pr.d +" "+ pr.od,time:now()});
                }
                var fnDebugBeforePropertyCreated = function(path,data) {
                    var pr = prints(path,data);
                        if(helpers.def(pr.p) || pr.d || pr.od)
                    debugOptions.batchBeforeCreateMsg.push({msg:pr.p +" "+ pr.d,time:now()});
                }
                var fnDebugBeforePropertyDeleted = function(path)  {
                    var pr = prints(path);
                    if(helpers.def(pr.p) || pr.d || pr.od)
                        debugOptions.batchBeforeDeleteMsg.push({msg:pr.p,time:now()})
                }

                var listeners = {
                    lengthChanged         : [fnDebugLengthChanged],
                    propertyUpdated       : [fnDebugPropertyUpdated],
                    propertyCreated       : [fnDebugPropertyCreated],
                    propertyDeleted       : [fnDebugPropertyDeleted],
                    beforePropertyUpdated : [fnDebugBeforePropertyUpdated],
                    beforePropertyCreated : [fnDebugBeforePropertyCreated],
                    beforePropertyDeleted : [fnDebugBeforePropertyDeleted]
                }

                var fnAddSignals = function(extraSignals){
                    function contains(arr,val){
                        for(var k in arr){
                            if(arr[k] === val)
                                return true;
                        }
                        return false;
                    }

                    Lodash.each(extraSignals, function(v,k){
                        if(listeners[k]){
                            var origCount = listeners[k].length
                            var fnArr = Lodash.isArray(v) ? v : [v];
                            Lodash.each(fnArr,function(fn) {
                                if(Lodash.isFunction(fn) && !contains(listeners[k],fn))
                                    listeners[k].push(fn);
                            })
//                            console.log("Added listeners to", k, " resutling in", listeners[k].length , "from", origCount);
                        }
                    })
                }


                var fnRemoveSignals = function(extraSignals){
                    function contains(arr,val){
                        for(var k in arr){
                            if(arr[k] === val)
                                return true;
                        }
                        return false;
                    }

                    Lodash.each(extraSignals, function(v,key){
                        if(listeners[key]){

                            var origCount = listeners[key].length
                            var fnArr = Lodash.isArray(v) ? v : [v];
                            Lodash.each(fnArr,function(fn) {
                                var idx = Lodash.indexOf(listeners[key],fn);
                                if(idx !== -1){
                                    listeners[key].splice(idx,1);
                                }
                            })

                            console.log("Removed", key, "listeners resulting in", listeners[key].length , "from", origCount);

                        }
                    })
                }



                return  {
                    addListeners  : fnAddSignals,
                    removeListeners : fnRemoveSignals,
                    listeners     : listeners,
                    lengthChanged : function(path,len)  {
                        Lodash.eachRight(listeners.lengthChanged, function(v,k){
                            if(typeof v === 'function')
                                v(path,len);
                            else //remove this thing!!
                                listeners.lengthChanged.splice(k,1);
                        })
                    } ,
                    propertyUpdated : function(path,data,oldData){
                        Lodash.eachRight(listeners.propertyUpdated, function(v,k){
                            if(typeof v === 'function')
                                v(path,data,oldData);
                            else
                                listeners.propertyUpdated.splice(k,1);
                        })
                    } ,
                    propertyCreated  : function(path,data) {
                        Lodash.eachRight(listeners.propertyCreated, function(v,k){
                            if(typeof v === 'function')
                                v(path,data);
                            else
                                listeners.propertyCreated.splice(k,1);
                        })
                    } ,
                    propertyDeleted  : function(path) {
                        Lodash.eachRight(listeners.propertyDeleted, function(v,k){
                            if(typeof v === 'function')
                                v(path);
                            else
                                listeners.propertyDeleted.splice(k,1);
                        })
                    } ,
                    beforePropertyUpdated : function(path,data,oldData){
                        Lodash.eachRight(listeners.beforePropertyUpdated, function(v,k){
                            if(typeof v === 'function')
                                v(path,data,oldData);
                            else
                                listeners.beforePropertyUpdated.splice(k,1);
                        })
                    } ,
                    beforePropertyCreated : function(path,data) {
                        Lodash.eachRight(listeners.beforePropertyCreated, function(v,k){
                            if(typeof v === 'function')
                                v(path,data);
                            else
                                listeners.beforePropertyCreated.splice(k,1);
                        })
                    } ,
                    beforePropertyDeleted : function(path)  {
                        Lodash.eachRight(listeners.beforePropertyDeleted, function(v,k){
                            if(typeof v === 'function')
                                v(path);
                            else
                                listeners.beforePropertyDeleted.splice(k,1);
                        })
                    }
                }
            }
            function all(){

                function doReduce(arr,name){
                    return Lodash.reduce(arr, function(a,e){
                        a.push({msg:name + "->" + e.msg, time : e.time })
                        return a;
                    }, [])
                }

                var arr = doReduce(batchBeforeCreateMsg, "beforeCreate")
                          .concat(doReduce(batchBeforeDeleteMsg, "beforeDelete"))
                          .concat(doReduce(batchBeforeUpdateMsg, "beforeUpdate"))
                          .concat(doReduce(batchCreateMsg      , "create"))
                          .concat(doReduce(batchUpdateMsg      , "update"))
                          .concat(doReduce(batchDeleteMsg      , "delete"))
                          .sort(function(a,b){
                              var at = a.time.getTime();
                              var bt = b.time.getTime();
                              if(at == bt){
                                  return a.msg.indexOf('before') !== -1 ? -1 : 1
                              }
                              return at - bt
                          })

                return Lodash.reduce(arr, function(a,e){
                    a.push(e.msg);
                    return a;
                }, [])

            }
        }
        QtObject {
            id : helpers


            function findById(obj,id,idProperty,giveKey){
                idProperty = idProperty || "id";
                for(var a in obj){
                    var item = obj[a];
                    if(item && item[idProperty] === id)
                        return giveKey ?  a : item;
                }
                return giveKey ? -1 : undefined;
            }

            function get(obj,path){
                if(!obj)
                    return undefined;
                if(!path)
                    return obj;

                var propArr = Lodash.compact(path.split("/"));
                var idProperty = obj._idProperty;
                var ptr     = obj;

                for(var i = 0; i < propArr.length; ++i){
                    var p = propArr[i];
                    if(Lodash.isArray(ptr) && arrayIsIded(ptr,idProperty)) {
                        ptr = findById(ptr,p,idProperty);
                    }
                    else {
                        ptr = ptr[p];
                    }
                    if(ptr === undefined)
                        return ptr;
                }
                return ptr;
            }
            function set(obj,path,val,signals){
                if(!obj)
                    return false;
                if(!path) {
                    obj = val;
                    return true;
                }

                var propArr    = Lodash.compact(path.split("/"));
                signals    = signals || obj._signals;
                if(!signals){
                    console.log("NO SIGANLS ON", JSON.stringify(obj))
                }

                var idProperty = obj._idProperty;
                var ptr        = obj;

                for(var i = 0; i < propArr.length; ++i){
                    var p = propArr[i];
                    if(i != propArr.length -1) {
                        if(Lodash.isArray(ptr) && arrayIsIded(ptr,idProperty)) {
                            ptr = findById(ptr,p,idProperty);
                        }
                        else {
                            ptr = ptr[p];
                        }
                        if(ptr === undefined)
                            return false;
                    }
                    else {  //this is where we assign
                        var assignKey = p;
                        if(Lodash.isArray(ptr) && arrayIsIded(ptr,idProperty)) {
                            assignKey = findById(ptr,p,idProperty,true);
                        }
                        var objPath = helpers.getPath(ptr._path,assignKey,val,idProperty);

                        if(ptr.hasOwnProperty(assignKey)) {
                            ptr[assignKey] = val;
                        }
                        else {
                            signals.beforePropertyCreated(objPath,val);
                            var vIns = priv.convert(val,objPath,signals,idProperty);

                            Object.defineProperty(ptr,assignKey,helpers.getDescriptor(vIns,objPath));

                            signals.propertyCreated(objPath,val);
                        }


                        return true;
                    }
                }
                return false;
            }
            function del(obj,path,signals){
                if(!obj || !path)
                    return false;

                var propArr = Lodash.compact(path.split("/"));
                signals = signals || obj._signals;
                if(!signals){
                    console.log("NO SIGANLS ON", JSON.stringify(obj))
                    return false;
                }

                var idProperty = obj._idProperty;
                var ptr        = obj;

                for(var i = 0; i < propArr.length; ++i){
                    var p = propArr[i];
                    if(i != propArr.length -1) {
                        if(Lodash.isArray(ptr) && arrayIsIded(ptr,idProperty))
                            ptr = findById(ptr,p,idProperty);
                        else
                            ptr = ptr[p];

                        if(ptr === undefined)
                            return false;
                    }
                    else {  //this is where we assign
                        var delKey = p;
                        if(Lodash.isArray(ptr) && arrayIsIded(ptr,idProperty)) {
                            delKey = findById(ptr,p,idProperty,true);
                        }
                        if(!delKey)
                            return false;

                        var objPath = helpers.getPath(ptr._path,delKey,ptr[delKey],idProperty);

                        if(!ptr.hasOwnProperty(delKey))
                            return false;

                        if(Lodash.isArray(ptr)) {
//                            console.log("REMOVE CALLED on IDX", delKey)
                            ptr.remove(delKey);
                            return true;
                        }
                        else if(Lodash.isObject(ptr)){
//                            console.log("DEL CALLED ON PROPERTY", delKey)
                            signals.beforePropertyDeleted(objPath);
                            delete ptr[delKey]
                            signals.propertyDeleted(objPath);
                            return true;
                        }
                    }
                }
                return false;
            }

            function isRestful(obj){
                return obj && obj._racgen ? true : false;
            }

            function def(obj, props){
                if(obj === null || obj === undefined || obj === "")
                    return false;

                if(props && !Lodash.isArray(props))
                    props = [props];

                for(var p in props){
                    var key = props[p]
                    if(obj[key] === null || obj[key] === undefined || obj[key] === "")
                        return false;
                }
                return true;
            }

            function arrayIsIded(js, idProp) {
                if(js.length === 0)
                    return true;

                var idProperty = js._idProperty || idProp || null;
                if(idProperty === null)
                    return false;

                var first = js[0];
                return idProperty && Lodash.isObject(first) && first.hasOwnProperty(idProperty) ? true : false
            }

            function idMatcherFuncGen(idProperty,matchTo){
                return function(a){
                    return a[idProperty] === matchTo[idProperty];
                }
            }

            function keyAt(obj,fn,badVal){
                badVal = badVal || -1;
                for(var o in obj) {
                    if(fn(obj[o]))
                        return o;
                }
                return badVal;
            }



            function getDescriptor(val , path, isReadOnly) {

                var _value = val;
                var _path  = path.toString();
                var r = { enumerable : true, configurable : true }

                r.get =  function(givePath) {  return givePath ? _path : _value; }
                r.set = isReadOnly ? function() { /*console.error("cannot write to readonly property", _path )*/ ;} :
                                     function(val, changePath) {
//                                        console.log("CUSTOM SET CALLED", val, "FROM", _value)
                                        if(changePath) {
//                                            console.log("WOOT NOT CHANGING VAL BUT PATH to:",changePath,"from",_path);
                                            return _path = changePath;
                                        }

//                                        console.log(JSON.stringify(this))
//                                        var idProperty = _value && _value._idProperty ? _value._idProperty : this._idProperty;
//                                        var signals    = _value && _value._signals    ? _value._signals    : this._signals;
                                        var idProperty = this._idProperty;
                                        var signals    = this._signals;
                                        if(val != _value) {

                                            var oldVal = _value;

                                            var currentType = { isArray : Lodash.isArray(_value) , isObject : Lodash.isObject(_value) }
                                            var newType     = { isArray : Lodash.isArray(val)    , isObject : Lodash.isObject(val) }

                                            if(!currentType.isArray && !currentType.isObject) { //simplest case
//                                                console.log("SIMPLE SETTER", _value, "to", val)
                                                signals.beforePropertyUpdated(_path,val,_value);
                                                _value = priv.convert(val,_path,signals,idProperty);
                                                signals.propertyUpdated(_path,_value,oldVal);
                                            }
                                            else if(currentType.isArray && newType.isArray) {
                                                var ided = helpers.arrayIsIded(_value,idProperty) && helpers.arrayIsIded(val,idProperty);
                                                if(!ided){
                                                    //since we replace the whole array, there's a good chance
                                                    //that we killed elements. so let's figure that out
                                                    if(_value.length > val.length) {
                                                        Lodash.eachRight(_value, function(v,k){
                                                            var p = getPath(path,k,null,idProperty)
                                                            if(k >= val.length) { //kill
                                                               signals.beforePropertyDeleted(p);
                                                               _value.length = k;   //remove item teehee!
                                                               signals.lengthChanged(_value.length);
                                                               signals.propertyDeleted(p);
                                                            }
                                                            else {      //update
                                                                _value[k] = priv.convert(val[k],p,signals,idProperty)
                                                            }
                                                        })
                                                    }
                                                    else {
                                                        Lodash.eachRight(val, function(v,k) {
                                                            var p = getPath(path,k,null,idProperty)
                                                            if(_value.hasOwnProperty(k))
                                                                _value[k] = priv.convert(val[k],p,signals,idProperty);
                                                            else {
                                                                signals.beforePropertyCreated(p,v);

                                                                var vIns = priv.convert(val[k],p,signals,idProperty)
                                                                Object.defineProperty(_value,k,helpers.getDescriptor(vIns,p));

                                                                signals.propertyCreated(p,vIns);
                                                                signals.lengthChanged(_value.length);
                                                            }
                                                        })
                                                    }
                                                }
                                                else {
                                                    Lodash.each(val, function(v,k){
                                                        _value.push(v); //our custom push function should handle it!
                                                    })
                                                }
                                            }
                                            else if(currentType.isObject && newType.isObject) {
                                                Lodash.each(val, function(v,k){
                                                    var p = helpers.getPath(_path,k,v,idProperty);
                                                    if(_value.hasOwnProperty(k)){
                                                        //since our _value[k] exists, it will run this function on _value[k].
                                                        _value[k] = v;
                                                    }
                                                    else{
                                                        //create this new thing!
                                                        //emit that a new thing was created
                                                        signals.beforePropertyCreated(p,v);
                                                        var r = priv.convert(v, p, signals, idProperty);
                                                        Object.defineProperty(_value, k, helpers.getDescriptor(r, p))
                                                        signals.propertyCreated(p,v);
                                                    }
                                                })
                                            }
                                            else {
                                                //different types, say we deleted old path. and created new object in its place!
                                                //similar to the very first if, but instead of updates, it says deletes and creates
                                                //since we will be releasing memory!
                                                try {
                                                    signals.beforePropertyDeleted(_path)
                                                    signals.beforePropertyCreated(_path,val)
                                                }
                                                catch(e){
                                                    console.log("ERROR" , JSON.stringify(_value), helpers.isRestful(_value), signals)
                                                    throw new TypeError("signals is undefined somehow!!");
                                                }



                                                //since our _value[k] exists, it will run this function on _value[k].
                                                _value = priv.convert(val, _path, signals, idProperty);

                                                try {
                                                    signals.propertyDeleted(_path)
                                                    signals.propertyCreated(_path,_value)
                                                }
                                                catch(e){
//                                                    console.log("ERROR" , JSON.stringify(_value), helpers.isRestful(_value), signals)
                                                }
                                            }

                                        }
                                    }

                return r;
            }

            //creates a restful path
            function getPath(path,key,val, idProperty) {
                idProperty = idProperty || (val && val._idProperty) || "id"
                if(!def(key)){
                    return def(path) ? path.toString() : "";
                }

                var k = def(val,idProperty) ? val[idProperty] : key;
                return def(path) ? path + "/" + k : k.toString();
            }

            function getDescriptorNonEnumerable(value, readOnly) {
                var _value = value;
                return {
                    writable : readOnly ? false : true,
                    configurable : true,
                    enumerable : false,
                    value : _value
                }
            }

            //attaches properties to array (overrides default array stuffs)
            function attachPropertiesArray(js) {
                var arr        = js;
                var idProperty = js._idProperty;
                var signals    = js._signals;

                function updatePath(obj,key,newPath,dontUpdateVal){
                    var val = obj[key];
                    var idProperty = obj._idProperty;
                    if(Lodash.isArray(obj) && helpers.arrayIsIded(obj,idProperty)){
                        //if the array is ided, we need to make sure that the properties at the top level of the arrays
                        var desc = Object.getOwnPropertyDescriptor(arr,key)
                        if(desc)
                            desc.set(null,newPath);
                    }
                    if(val && val._path && !dontUpdateVal){
                        //if the array is unided, we need to change the paths inside all the objects in the array
                        val._updatePath(newPath);
                    }
                }

                //since the js._path can be changed. we don't make a private var of it!!

                //removes a single index from the arr and emits signals that need to be emitted
                //Our deletion works in the following way
                //Del B from A B C D
                //STEP 1 :   A C D D
                //STEP 2 :   A C D
                //essentially we move stuff left by one and then remove at the end!
                function remove(idx){
                    idx = parseInt(idx);
                    if(idx >= arr.length || idx < 0 || idx === NaN) //parseInt returns NaN if it can't figure out what the hell you gave it!
                        return console.error("ERROR:: idx " + idx + " is not in the array")


                    var path = arr._path;
                    var isIded = helpers.arrayIsIded(arr,idProperty);


                    var relevantIdx = isIded ? idx : arr.length-1
                    var delPath = getPath(path,relevantIdx,arr[relevantIdx],idProperty);

                    signals.beforePropertyDeleted(delPath);

                    for(var j = idx; j < arr.length; ++j){
                        if(j === arr.length -1){
                            if(isIded && j === idx)
                                signals.propertyDeleted(delPath);

                            continue;
                        }

                        var old = arr[j];
                        var val = arr[j+1];
                        var p   = getPath(path,j,val,idProperty);

                        //If we use the equal to op, it's gonna update rather than replace
                        //and we need replaced!! we only need to generate update messages
                        //for unided arrays!
                        if(!isIded) {
                            signals.beforePropertyUpdated(p,val,old)
                            updatePath(arr,j+1,j)
                        }

                        Object.defineProperty(arr,j,helpers.getDescriptor(val,p));

                        if(!isIded) {
                            signals.propertyUpdated(p,val,old)
                        }

                        if(isIded && j === idx)
                            signals.propertyDeleted(delPath);

                    }

                    //this is where we actually remove an element from an array
                    //but this is onyl valid for unided array to emit signal at this point!
                    arr.length = arr.length - 1;
                    if(!isIded)
                        signals.propertyDeleted(delPath);

                    signals.lengthChanged(arr.length);


                    return true;
                }

                //inserts a single val at idx and emtis signals that need to be emitted
                //begin inserting at idx!
                //Our insertion works in the following way
                //Insert X @ 1 in A B C D
                //Step 1 :        A B B C D
                //Step 2 :        A X B C D
                //essentially we move stuff to the right by one and then change the index where we wanted to insert
                //If the array has Ids, only new ids will be added. Existing ones will update!!
                function insert(idx, v){
                    idx = parseInt(idx);
                    if(idx < 0 || idx === NaN)
                        return;

                    var path = arr._path;
                    var isIded = helpers.arrayIsIded(arr,idProperty);

                    function doInsert() {
                        for(var i = arr.length; i > idx ; i--){
                             var val = arr[i-1];
//                             console.log(JSON.stringify(val), helpers.isRestful(val))
                             var p  = getPath(path,i,val,idProperty);

                             updatePath(arr,i-1,p);
                             //in this case the val is already converted , so we don't need to convert it right?
                             //we might want to change its path doe
                             if(i >= arr.length){
                                 //new property is being made, so let's make sure we make it observable
                                 //and that we generate the apt signals. However, if the array is ided
                                 //we dont need to say a new property was created because we just moved
                                 if(!isIded)
                                    signals.beforePropertyCreated(p,val)

                                 Object.defineProperty(arr,i,helpers.getDescriptor(val,p));

                                 if(!isIded)
                                    signals.propertyCreated(p,val)
                             }
                             else{
                                var old = arr[i];
                                if(!isIded)
                                    signals.beforePropertyUpdated(p,val,old)

                                Object.defineProperty(arr,i,helpers.getDescriptor(val,p));

                                if(!isIded)
                                    signals.propertyUpdated(p,val,old)

                             }
                        }

                        var pInsert = getPath(path,idx,v,idProperty);
                        var vInsert //the reason we don't call convert here so we don't emit all
                                    //the signals


                        //the reason we don't use arr[idx] = v is because the setter is too smart
                        //it is not gonna replace an object there if this is an object.
                        //Instead we gotta PUT this new object (v) there. We have already moved
                        //the object that was there so this is safe.
                        if(isIded || idx >= arr.length) {
                            signals.beforePropertyCreated(pInsert,v)

                            vInsert = priv.convert(v,pInsert,signals,idProperty);
                            Object.defineProperty(arr,idx,helpers.getDescriptor(vInsert,pInsert));

                            signals.propertyCreated(pInsert,vInsert)
                        }
                        else {
                            //determine whether we need to emit update messages
                            //we only need to do that on unided arrays when we move elements!
                            var oldVal = arr[idx]
                            if(!isIded)
                                signals.beforePropertyUpdated(pInsert,v,oldVal)

                            vInsert = priv.convert(v,pInsert,signals,idProperty);
                            Object.defineProperty(arr,idx,helpers.getDescriptor(vInsert,pInsert));

                            if(!isIded)
                                signals.propertyUpdated(pInsert,vInsert,oldVal)
                        }

                        signals.lengthChanged(arr.length);
                    }

                    //unfortunately, the insert function needs to check if the array is ided.
                    //If it is, it must go and try to find the index reported by v (if any).
                    //If found, it needs to update rather than create a duplicate.
                    if(arr.length === 0 || !helpers.arrayIsIded(arr,idProperty)) { //if our array is empty or it if its not ided, cool . just shove it in!
                        doInsert();
                    }
                    else {
                        var idxOfVal = helpers.keyAt(arr, helpers.idMatcherFuncGen(idProperty,v));
                        if(idxOfVal === -1)
                            doInsert();
                        else {
//                            console.error("I PITY THE FOOL WHO TRIES TO MAKE DUPLICATES!")
                            arr[idxOfVal] = v;  //v will be auto converted by virtue of our CUSTOM SET!
                        }
                    }
                }


                //Pushes arguments into the array. If the array has Ids, only new ids will be added. Existing ones will update!!
                function push(){
//                    console.log("CUSTOM PUSH!!")
                    if(arguments.length === 0)
                        return;

                    var path  = arr._path;
                    Lodash.each(arguments, function(val){
                        function simpleInsertion(){
                            var p = getPath(path,arr.length,val,idProperty);
                            var v = priv.convert(val,p,signals,idProperty);

                            signals.beforePropertyCreated(p,val);
                            Object.defineProperty(arr, arr.length, helpers.getDescriptor(v,p,false))
                            signals.propertyCreated(p,v);
                            signals.lengthChanged(path,arr.length);
                        }

                        if(arr.length === 0 || !helpers.arrayIsIded(arr,idProperty)) { //if our array is empty or it if its not ided, cool . just shove it in!
                            simpleInsertion();
                        }
                        else {
                            //try to find the idx of the thing we are trying to insert, provided its an object!
                            var idx = helpers.keyAt(arr, helpers.idMatcherFuncGen(idProperty,val))
                            if(idx === -1){
                                simpleInsertion();
                            }
                            else {
                                //pray to the Almighty that we have set this idx to have a setter and it handles this madness!
                                arr[idx] = val;
                            }
                        }
                    })
                }


                //returns an array of deleted elements!! Uses remove and insert
                function splice(idx,deleteCount){
                    idx = parseInt(idx);
                    if(idx === NaN)
                        return [];

                    var args        = Array.prototype.slice.call(arguments);
                    var insertElems = args.length <= 2 ? undefined : args.slice(2);
                    var deletedElems = [];

                    if(idx > arr.length)
                        idx = arr.length;
                    else if(idx < 0) //negative
                        idx = arr.length - idx;

                    var remaining = arr.length - idx;
                    if(deleteCount > remaining)
                        deleteCount = remaining;

                    Lodash.times(deleteCount, function(){
                        deletedElems.push(arr[idx]);
                        remove(idx);
                    })

                    Lodash.eachRight(insertElems, function(v,k){
                         insert(idx,v);
                    })

                    return deletedElems;
                }

                function shift(){
                    if(arr.length === 0)
                        return undefined;

                    var r = splice(0,1);
                    return r[0];
                }

                function pop(){
                    if(arr.length === 0)
                        return undefined;

                    var r = splice(-1,1);
                    return r[0];
                }

                function unshift(){
                    var args = Array.prototype.slice.call(arguments);
                    Lodash.eachRight(args, function(v,k){
                         insert(0,v);
                    })
                    return arr.length;
                }

                //returns a new array concated with args!
                function concat(){
                    var args   = Array.prototype.slice.call(arguments);
                    var newArr = create(arr,arr._path,signals,idProperty);

                    Lodash.each(args, function(v){
                        if(!Lodash.isArray(v)){
                            newArr.push(v);
                        }
                        else {
                            Lodash.each(v, function(v2){
                                newArr.push(v2);
                            })
                        }
                    })

                    return newArr;
                }

                function filter(fn){
                    fn = typeof fn === 'function' ? fn : function(){ return true }
                    var newArr = Array.prototype.filter.call(arr, fn);
                    return create(newArr,arr._path,signals,idProperty);
                }

                function map(){
                    var args = Array.prototype.slice.call(arguments);
                    var fn   = typeof args[0] === 'function' ? args[0] : function(a){ return a }

                    var newArr = args.length > 1 ? Array.prototype.map.call(arr, fn, args[1]) :
                                                   Array.prototype.map.call(arr, fn)

                    return create(newArr,arr._path,signals,idProperty);
                }


                function reverse(){
                    var startIdx = 0;
                    var endIdx   = arr.length-1;
                    var path = arr._path;
                    var isIded = helpers.arrayIsIded(arr,idProperty);
                    while(startIdx < endIdx) {
//                        if(startIdx === endIdx) //for odd length arrays. this will be the middle elem!
//                            continue;
                        var sPath = getPath(path,startIdx,arr[startIdx],idProperty);
                        var ePath = getPath(path,endIdx  ,arr[endIdx]  ,idProperty);

                        var sVal = arr[startIdx];
                        var eVal = arr[endIdx];


                        if(!isIded){
                            signals.beforePropertyUpdated(sPath, eVal, sVal);
                            signals.beforePropertyUpdated(ePath, sVal, eVal);
//                            sVal._updatePath(sPath);
//                            eVal._updatePath(ePath);
                        }

                        if(sVal && sVal._updatePath && !isIded){
                            sVal._updatePath();
                        }
                        if(eVal && eVal._updatePath && !isIded){
                            eVal._updatePath();
                        }

//                        updatePath(arr, startIdx, ePath);
//                        updatePath(arr, endIdx  , sPath);
                        Object.defineProperty(arr, startIdx,helpers.getDescriptor(eVal,sPath));
                        Object.defineProperty(arr, endIdx  ,helpers.getDescriptor(sVal,ePath));

                        if(!isIded){
                            signals.propertyUpdated(sPath, eVal, sVal);
                            signals.propertyUpdated(ePath, sVal, eVal);
                        }


                        startIdx++;
                        endIdx--;
                    }
                }

                function reduce(callback, initValue){
                    var args = Array.prototype.slice.call(arguments);
                    var r    = Array.prototype.reduce.call(arr,args[0], args[1]);
                    return create(r,arr._path,signals,idProperty);
                }
                function reduceRight(callback, initValue){
                    var args = Array.prototype.slice.call(arguments);
                    var r    = Array.prototype.reduceRight.call(arr,args[0], args[1]);
                    return create(r,arr._path,signals,idProperty);
                }

                function sort(fn){
                    var isIded = helpers.arrayIsIded(arr,idProperty);
                    fn = typeof fn === 'function' ? fn : function(a,b) { return a -b }

                    //create a clone!
                    var clone = JSON.parse(JSON.stringify(arr));
                    clone.sort(fn);

                    Lodash.each(clone,function(v,k){
                        var oldVal = arr[k];
                        var p      = getPath(arr._path, k, oldVal, idProperty);

                        if(!isIded)
                            signals.beforePropertyUpdated(p,v,oldVal);

                        var vIns = priv.convert(v,p,signals,idProperty,true);

                        Object.defineProperty(arr,k,helpers.getDescriptor(vIns,p));

                        if(!isIded)
                            signals.propertyUpdated(p,v,oldVal);
                    })
                }

                Object.defineProperty(arr,'push'       , helpers.getDescriptorNonEnumerable(push,true))
                Object.defineProperty(arr,'splice'     , helpers.getDescriptorNonEnumerable(splice,true))
                Object.defineProperty(arr,'insert'     , helpers.getDescriptorNonEnumerable(insert,true))
                Object.defineProperty(arr,'remove'     , helpers.getDescriptorNonEnumerable(remove,true))
                Object.defineProperty(arr,'shift'      , helpers.getDescriptorNonEnumerable(shift,true))
                Object.defineProperty(arr,'unshift'    , helpers.getDescriptorNonEnumerable(unshift,true))
                Object.defineProperty(arr,'pop'        , helpers.getDescriptorNonEnumerable(pop,true))
                Object.defineProperty(arr,'concat'     , helpers.getDescriptorNonEnumerable(concat,true))
                Object.defineProperty(arr,'filter'     , helpers.getDescriptorNonEnumerable(filter,true))
                Object.defineProperty(arr,'map'        , helpers.getDescriptorNonEnumerable(map,true))
                Object.defineProperty(arr,'reverse'    , helpers.getDescriptorNonEnumerable(reverse,true))
                Object.defineProperty(arr,'reduce'     , helpers.getDescriptorNonEnumerable(reduce,true))
                Object.defineProperty(arr,'reduceRight', helpers.getDescriptorNonEnumerable(reduceRight,true))
                Object.defineProperty(arr,'sort'       , helpers.getDescriptorNonEnumerable(sort,true))
            }

            //attaches properties to object (overrides default object stuffs)
            function attachPropertiesObject(js) {

            }

            //attaches properties to js that are valid for both arrays and objects
            function attachPropertiesGeneric(js,path,signals,idProperty) {

                function updatePath(newPath){
                    js._path = newPath;
                    Lodash.each(js, function(v,k){
                        var p
                        if(Lodash.isObject(v)){
                            p = getPath(newPath,k,null,idProperty);
                            Object.getOwnPropertyDescriptor(js,k).set(null, p);
                            v._updatePath(p);
                        }
                        else if(Lodash.isArray(v)){
                            p = getPath(newPath,k,v,idProperty);
                            Object.getOwnPropertyDescriptor(js,k).set(null, p);
                            v._updatePath(p);
                        }
                    })
                }

                Object.defineProperty(js,"_signals"   , helpers.getDescriptorNonEnumerable(signals));
                Object.defineProperty(js,"_path"      , helpers.getDescriptorNonEnumerable(path));
                Object.defineProperty(js,"_idProperty", helpers.getDescriptorNonEnumerable(idProperty))
                Object.defineProperty(js,"_updatePath", helpers.getDescriptorNonEnumerable(updatePath));

                //short for restArrayCreatorGenerated . Makes it easy to test objects/arrays if
                //it was created here!
                Object.defineProperty(js,"_racgen", helpers.getDescriptorNonEnumerable(true,true))

                Object.defineProperty(js,'get', helpers.getDescriptorNonEnumerable(function(str){
                    return get(js,str);
                }, true))

                Object.defineProperty(js,'set', helpers.getDescriptorNonEnumerable(function(str,val){
                    return set(js,str,val,signals);
                }))

                Object.defineProperty(js,'del',helpers.getDescriptorNonEnumerable(function(str){
                    return del(js,str,signals);
                }))
            }

        }


        //converts a js object/array to our custom observable one. will dig down to the roots!!
        //returns a new and shiny object if it is not helpers.isRestful
        //otherwise, updates the path of the js
        function convert(js, path, signals, idProperty, suppressSignals) {
            idProperty = idProperty || js._idProperty || "id";

            function recursiveAttacher(v,k,acc,path) {
                var p = helpers.getPath(path,k,v, idProperty);
                if(k !== idProperty && !suppressSignals)
                    signals.beforePropertyCreated(p,v)

                if(Lodash.isArray(v)) {
                    Object.defineProperty(acc,k, helpers.getDescriptor(convertArr(v,p), p));
                }
                else if(Lodash.isObject(v) ){
                    Object.defineProperty(acc,k, helpers.getDescriptor(convertObj(v,p), p));
                }
                else {
                    var isReadonly = k ===  idProperty;
                    Object.defineProperty(acc,k,helpers.getDescriptor(v,p,isReadonly));
                }

                if(k !== idProperty && !suppressSignals)
                    signals.propertyCreated(p,v)
            }


            function convertArr(js,path) {
                var arr = priv.createArray(null,path,signals, idProperty);
                Lodash.each(js, function(v,k) {
                    recursiveAttacher(v,k,arr,path);
                })
                return arr;
            }

            function convertObj(js,path) {
                var obj = priv.createObject(null,path,signals, idProperty);
                Lodash.each(js, function(v,k) {
                    recursiveAttacher(v,k,obj,path);
                })
                return obj;
            }


            if(helpers.isRestful(js)){
                console.log("WOAh, saved duplication mannnnnnnnnnnnnnnnnnnnnn @", path)
                js._updatePath(path);
                return js;
            }
            else {
                return Lodash.isArray(js) ? convertArr(js,path) :
                                            Lodash.isObject(js) ? convertObj(js,path) :
                                                                  js;
            }
        }


        //creates an observable array. calls convert if js is provided!
        function createArray(js,path,signals,idProperty) {
            var p = helpers.getPath(path);
            if(Lodash.isArray(js)) {
                return convert(js,path,signals, idProperty);
            }

            var ret = [];
            helpers.attachPropertiesGeneric(ret,p,signals,idProperty);
            helpers.attachPropertiesArray(ret);
            return ret;
        }


        //creates an observable object. calls convert if js is provided.
        function createObject(js, path, signals,idProperty) {
            path = helpers.def(path) ?  path : "";
            idProperty = idProperty
            var p = helpers.getPath(path);
            if(Lodash.isObject(js)) {
                return convert(js,path,signals,idProperty);
            }

            var ret = {};
            helpers.attachPropertiesGeneric(ret,p,signals,idProperty);
            helpers.attachPropertiesObject(ret);
            return ret;
        }
    }



}
