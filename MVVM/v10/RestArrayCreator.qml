import QtQuick 2.5
import "../Lodash"
import Zabaat.Utility 1.0
pragma Singleton
QtObject {
    id : rootObject
    objectName : "RestArrayCreator"
    property alias debugOptions : debugOptions;

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
        signals    = signals    || debugOptions.standardSignalsPackage();
        idProperty = idProperty || "id";


        return Lodash.isObject(js) ? priv.createObject(js, path, signals, idProperty) :
                                     priv.createArray(js,path, signals, idProperty);
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
                Lodash.each(all(), function(v,k){
                    console.log(k,v)   ;
                })
            }

            function clearBatches(){
                batchBeforeCreateMsg =  []
                batchBeforeUpdateMsg =  []
                batchBeforeDeleteMsg =  []
                batchCreateMsg       =  []
                batchUpdateMsg       =  []
                batchDeleteMsg       =  []
            }
            function standardSignalsPackage() {
                function prints(path,data,oldData){
                    var p  = helpers.def(path) && debugOptions.showPaths   ? path                     : "";
                    var d  = data     && debugOptions.showData    ? "= "    + JSON.stringify(data)    : "";
                    var od = oldData  && debugOptions.showOldData ? "from " + JSON.stringify(oldData) : "";
                    return { p:p, d:d, od:od }
                }
                function now() {
                    return new Date();
                }

                return  {
                    lengthChanged : function(path,len)  {
                        var pr = prints(path,len);
                        if(helpers.def(pr.p)) {
                            var msg = "lenChanged:"+" "+ pr.p +" "+ pr.d+" "+ pr.od
                            debugOptions.batchUpdateMsg.push({msg:msg,time:now()})
                        }
                    } ,
                    propertyUpdated : function(path,data,oldData){
                        var pr = prints(path,data,oldData);
                        if(helpers.def(pr.p) || pr.d || pr.od){
                            debugOptions.batchUpdateMsg.push({msg:pr.p+" "+ pr.d+" "+ pr.od,time:now()});
                        }
                    } ,
                    propertyCreated  : function(path,data) {
                        var pr = prints(path,data);
                        if(helpers.def(pr.p) || pr.d || pr.od)
                            debugOptions.batchCreateMsg.push({msg:pr.p+" "+ pr.d,time:now()});
                    } ,
                    propertyDeleted  : function(path) {
                        var pr = prints(path);
                        if(helpers.def(pr.p) || pr.d || pr.od)
                            debugOptions.batchDeleteMsg.push({msg:pr.p,time:now()})
                    } ,
                    beforePropertyUpdated : function(path,data,oldData){
                        var pr = prints(path,data,oldData);
                        if(helpers.def(pr.p) || pr.d || pr.od)
                            debugOptions.batchBeforeUpdateMsg.push({msg:pr.p +" "+ pr.d +" "+ pr.od,time:now()});
                    } ,
                    beforePropertyCreated : function(path,data) {
                        var pr = prints(path,data);
                            if(helpers.def(pr.p) || pr.d || pr.od)
                        debugOptions.batchBeforeCreateMsg.push({msg:pr.p +" "+ pr.d,time:now()});
                    } ,
                    beforePropertyDeleted : function(path)  {
                        var pr = prints(path);
                        if(helpers.def(pr.p) || pr.d || pr.od)
                            debugOptions.batchBeforeDeleteMsg.push({msg:pr.p,time:now()})
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

            function isRestful(obj){
                return obj._racgen ? true : false;
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
                r.get =  function() {  return _value; }
                r.set = isReadOnly ? function() { /*console.error("cannot write to readonly property", _path )*/ ;} :
                                     function(val, changePath) {
//                                        console.log("CUSTOM SET CALLED", val, "FROM", _value)
                                        if(changePath) {
                                            console.log("WOOT NOT CHANGING VAL BUT PATH to:",changePath,"from",_path);
                                            return _path = changePath;
                                        }


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
                                                            _value[k] = priv.convert(val[k],p,signals,idProperty)
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
                                                signals.beforePropertyDeleted(_path)
                                                signals.beforePropertyCreated(_path,val)

                                                //since our _value[k] exists, it will run this function on _value[k].
                                                _value = priv.convert(val, _path, signals, idProperty);

                                                signals.propertyDeleted(_path)
                                                signals.propertyCreated(_path,val)
                                            }

                                        }
                                    }

                return r;
            }

            //creates a restful path
            function getPath(path,key,val, idProperty) {
                idProperty = idProperty || (val && val._idProperty) || "id"
                if(!def(key)){
                    return def(path) ? path : "";
                }

                var k = def(val,idProperty) ? val[idProperty] : key;
                return def(path) ? path + "/" + k : k;
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
                        Object.getOwnPropertyDescriptor(arr,key).set(null,newPath);
                    }
                    else if(val && val._path && !dontUpdateVal){
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
                    if(idx >= arr.length || idx < 0)
                        return console.error("ERROR:: idx " + idx + " is not in the array")

                    var path = arr._path;
                    var isIded = helpers.arrayIsIded(arr,idProperty);


                    var relevantIdx = isIded ? idx : arr.length-1
                    var delPath = getPath(path,relevantIdx,arr[relevantIdx],idProperty);

                    signals.beforePropertyDeleted(delPath);

                    for(var j = idx; j < arr.length-1; ++j){
                        arr[j] = arr[j+1];    //this should call our version of SET!

                        if(isIded && j === idx)
                            signals.propertyDeleted(delPath);

                        updatePath(arr,j+1,j)
                    }

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
                    var path = arr._path;
                    if(idx < 0)
                        return;

                    var isIded = helpers.arrayIsIded(arr,idProperty);

                    function doInsert() {
                        for(var i = arr.length; i > idx ; i--){
                             var val = arr[i-1];
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
                                arr[i] = val;
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
                    if(arguments.length === 0)
                        return;

                    var path  = arr._path;
                    Lodash.each(arguments, function(val){
                        function simpleInsertion(){
                            var p = getPath(path,arr.length,val,idProperty);
                            var v = priv.convert(val,p,signals,idProperty);

                            signals.beforePropertyCreated(p,val);
                            Object.defineProperty(arr, arr.length, helpers.getDescriptor(v,p,false))
                            signals.propertyCreated(p,val);
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
                    var args        = Array.prototype.slice.call(arguments);
                    var insertElems = args.length <= 2 ? undefined : args.slice(2);

                    var deletedElems = [];

                    if(idx === null || idx === undefined || idx > arr.length)
                        idx = arr.length;
                    if(idx < 0) //negative
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

                function attachFrom(){}
                function attachOf(){}
                function attachConcat(){}
                function attachCopyWihin(){}
                function attachFill(){}
                function attachFilter(){}
                function attachMap(){}
                function attachProp(){}
                function attachrReverse(){}
                function attachShift(){}
                function attachUnshift(){}
                function attachSlice(){}
                function attachSort(){}


                Object.defineProperty(js, 'push'  , helpers.getDescriptorNonEnumerable(push,true))
                Object.defineProperty(js, 'splice', helpers.getDescriptorNonEnumerable(splice,true))
                Object.defineProperty(arr,'insert', helpers.getDescriptorNonEnumerable(insert,true))
                Object.defineProperty(arr,'remove', helpers.getDescriptorNonEnumerable(remove,true))
//                attachFrom();
//                attachOf
//                attachConcat
//                attachCopyWihin
//                attachFill
//                attachFilter
//                attachMap
//                attachProp
//                attachrReverse
//                attachShift
//                attachUnshift
//                attachSlice
//                attachSort
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
            }

        }


        //converts a js object/array to our custom observable one. will dig down to the roots!!
        function convert(js, path, signals, idProperty) {
            idProperty = idProperty || js._idProperty || "id";

            function recursiveAttacher(v,k,acc,path) {
                var p = helpers.getPath(path,k,v, idProperty);
                if(k !== idProperty)
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

                if(k !== idProperty)
                    signals.propertyCreated(p,v)
            }


            function convertArr(js,path) {
                var arr = priv.createArray(null,path,signals, idProperty);
                Lodash.each(js, function(v,k) { recursiveAttacher(v,k,arr,path); })
                return arr;
            }

            function convertObj(js,path) {
                var obj = priv.createObject(null,path,signals, idProperty);
                Lodash.each(js, function(v,k) { recursiveAttacher(v,k,obj,path); })
                return obj;
            }





            return Lodash.isArray(js) ? convertArr(js,path) :
                                        Lodash.isObject(js) ? convertObj(js,path) :
                                                              js;
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
