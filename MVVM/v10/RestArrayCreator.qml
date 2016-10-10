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
                                     function(val, noUpdate) {
//                                        console.log("CUSTOM SET CALLED", val, "FROM", _value)

                                        var idProperty = this._idProperty;
                                        var signals = this._signals;

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
                                                var ided = helpers.arrayIsIded(_value) && helpers.arrayIsIded(val,idProperty);
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
                var path       = js._path;
                var idProperty = js._idProperty;
                var signals    = js._signals;


                function attachPush() {
                    var f = function(){
                        if(arguments.length === 0)
                            return;

                        Lodash.each(arguments, function(val){
                            function simpleInsertion(){
                                var p = getPath(path,arr.length,val,idProperty);
                                var v = priv.convert(val,p,signals,idProperty);

                                signals.beforePropertyCreated(p,val);
                                Object.defineProperty(arr, arr.length, helpers.getDescriptor(v,p,false))
                                signals.propertyCreated(p,val);
                                signals.lengthChanged(path,arr.length);
                            }

                            if(arr.length === 0 || !helpers.arrayIsIded(arr)) { //if our array is empty or it if its not ided, cool . just shove it in!
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
                    Object.defineProperty(js, 'push', { enumerable : false, value : f })
                }

                //returns an array of deleted elements!!
                function attachSplice(){

                    var f = function(idx,deleteCount){
                        console.log("--------------------------------------")
                        var args        = Array.prototype.slice.call(arguments);
                        var insertElems = args.length <= 2 ? undefined : args.slice(2);

                        var deletedElems = [];

                        if(idx === null || idx === undefined || idx > js.length)
                            idx = js.length;
                        if(idx < 0) //negative
                            idx = js.length - idx;

                        var remaining = js.length - idx;
                        if(deleteCount > remaining)
                            deleteCount = remaining;

                        //handle deletion first
                        var slen = js.length;
                        var dCount = deleteCount;
                        for(var i = idx; deleteCount > 0; ++i){
                            console.log("rem from", js, "@", js[idx]);
                            //i is the index to delete!!
                            deletedElems.push(js[idx]);

                            //always start at where we are deleting!
                            var last = js[js.length-1];
                            for(var j = idx; j < js.length-1; ++j){
                                console.log("set", js[j], "to", js[j+1])
                                js[j] = js[(j+1)];    //this should call our version of SET!
                            }

                            console.log(js, js.length, typeof js[2])
                            js.length = js.length - 1;
//                            js[js.length-1] = last;
                            console.log(js, js.length, typeof js[2])
//                            signals.lengthChanged()

                            deleteCount--;
                        }
//                        console.log("deleted", dCount, "elems from", slen, "resuting in", js.length, js )

                        //begin inserting at i!

                        Lodash.eachRight(insertElems, function(v,k){

                            //shift all the elements to make room!!
//                            console.log("STEP 0", js)
                            for(var i = js.length; i >= idx ; i--){
//                                if(js[i] === undefined){
//                                    Object.defineProperty(js, i, priv.con)
//                                }
//                                else{
                                    js[i] = js[i-1];
//                                }
                            }

//                            console.log("STEP1", js)


                            //replace element at idx
                            js[idx] = v;
//                            console.log("STEP2", js)

                        })





                        //then handle insertion or should we about it the other way??


                        return deletedElems;
                    }

                    Object.defineProperty(js, 'splice', { enumerable : false, value : f })
//                    Object.defineProperty(js, 'splice', helpers.getDescriptorNonEnumerable(f,true));
                }

                function attachFrom(){

                }

                function attachOf(){

                }

                function attachConcat(){

                }

                function attachCopyWihin(){

                }

                function attachFill(){

                }

                function attachFilter(){

                }

                function attachMap(){

                }

                function attachProp(){

                }

                function attachrReverse(){

                }

                function attachShift(){

                }

                function attachUnshift(){

                }

                function attachSlice(){

                }

                function attachSort(){

                }


                attachPush();
                attachSplice();
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
                Object.defineProperty(js,"_signals"   , helpers.getDescriptorNonEnumerable(signals));
                Object.defineProperty(js,"_path"      , helpers.getDescriptorNonEnumerable(path));
                Object.defineProperty(js,"_idProperty", helpers.getDescriptorNonEnumerable(idProperty))
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
