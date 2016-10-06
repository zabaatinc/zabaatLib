import QtQuick 2.5
import "../Lodash"
import Zabaat.Utility 1.0
pragma Singleton
QtObject {
    id : rootObject
    objectName : "RestArrayCreator"
    property alias debugOptions : debugOptions;

    //defaults to array construction!
    function create(js, path, signals, idProperty) {
        signals    = signals    || priv.standardSignalsPackage();
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

            property var batchCreateMsg: []
            property var batchUpdateMsg: []
            property var batchDeleteMsg: []

        }

        QtObject {
            id : helpers



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
                var _path  = path;

                var r = { enumerable : true }
                r.get =  function() {  return _value; }
                r.set = isReadOnly ? function() { console.error("cannot write to readonly property", _path ) ;} :
                                     function(val, noUpdate) {

                                        var idProperty = this._idProperty;
                                        var signals = this._signals;

                                        if(val != _value) {
                                            var oldVal = _value;

                                            var currentType = { isArray : Lodash.isArray(_value) , isObject : Lodash.isObject(_value) }
                                            var newType     = { isArray : Lodash.isArray(val)    , isObject : Lodash.isObject(val) }

                                            if(!currentType.isArray && !currentType.isObject) {
                                                signals.beforePropertyUpdated(_path,val,_value);
                                                if(!newType.isArray && !newType.isObject) { //simplest case!
                                                    _value = val;
                                                }
                                                else { //new thing is a complex object
                                                    if(newType.isArray) {
                                                        _value = priv.createArray(val,_path,signals,idProperty);
                                                    }
                                                    else {
                                                        _value = priv.createObject(val,_path,signals,idProperty);
                                                    }
                                                }
                                                signals.propertyUpdated(_path,_value,oldVal);
                                            }
                                            else {
                                                if(currentType.isArray) {   //we are assigning to an array!

                                                    if(newType.isArray) {   //cool our types match!
                                                        //check if arrays are ided
                                                        var ided = helpers.arrayIsIded(_value) && helpers.arrayIsIded(val,idProperty);
                                                        if(!ided){
                                                            //since we replace the whole array, there's a good chance
                                                            //that we killed elements. so let's figure that out
                                                            Lodash.eachRight(_value, function(v,k){
                                                                var p = getPath(path,k,null,idProperty)
                                                                if(k >= val.length) { //kill
                                                                    //TODO , WILL NOT LET US REMOVE SHIT! LENGTH IS READONLY
                                                                    if(typeof _value[k]._kill === 'function'){
                                                                        _value[k]._kill();
                                                                    }
                                                                    else {
                                                                       signals.beforePropertyDeleted(p);
                                                                        //TODO CONTINUE HERE! DOESNT LET US DELETE

                                                                       signals.propertyDeleted(p);
                                                                    }
                                                                }
                                                                else {      //update

                                                                    _value[k] = priv.convert(val[k],p,signals,idProperty)
                                                                }
                                                            })


                                                        }
                                                        else {
                                                            Lodash.each(val, function(v,k){
                                                                _value.push(v); //our custom push function should handle it!
                                                            })
                                                        }
                                                    }
                                                    else {
                                                        //TODO

                                                    }
                                                }
                                                else {  //we are assigning to an object!

                                                    if(newType.isArray) {
                                                        _value._kill();
                                                    }
                                                    else {
                                                        //TYPES MATCH, we just need to update this object. go thru all the keys and assign them if they exist!
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
                                                }
                                            }
                                        }
                                    }

                return r;
            }

            //creates a restful path
            function getPath(path,key,val, idProperty) {
                idProperty = idProperty || (val && val._idProperty) || "id"
                if(key === null || key === undefined){
                    return path ? path : "";
                }

                var k = val && val[idProperty] !== null && val[idProperty] !== undefined ? val.id : key;
                return path ? path + "/" + k : k;
            }

            function getDescriptorNonEnumerable(value) {
                var _value = value;
                return {
                    enumerable : false,
                    value: _value
                }
            }

            //attaches properties to array (overrides default array stuffs)
            function attachPropertiesArray(js) {
                var arr        = js;
                var path       = js._path;
                var idProperty = js._idProperty;
                var signals    = js._signals;


                function attachPush() {
                    var f = function(val){
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
                    }

                    Object.defineProperty(js, 'push', {
                                            enumerable : true,
                                            value : f
                                          })
                }

                function attachSplice(idx, remove, insertElements){

                }


                attachSplice();
                attachPush();
            }

            //attaches properties to object (overrides default object stuffs)
            function attachPropertiesObject(js) {

            }

            //attaches properties to js that are valid for both arrays and objects
            function attachPropertiesGeneric(js,path,signals,idProperty) {

                //generates delete notifications!
                function kill() {
                    var self = this;
                    self._signals.beforePropertyDeleted(self._path);
                    if(Lodash.isArray(self) || Lodash.isObject(self)){
                        Lodash.each(self, function(v,k){
                            if(typeof v._kill === 'function'){
                                v._kill();
                            }
                        })
//                        delete self;
                    }
                    self._signals.propertyDeleted(self._path);
                }

                Object.defineProperty(js,"_signals"   , helpers.getDescriptorNonEnumerable(signals));
                Object.defineProperty(js,"_path"      , helpers.getDescriptorNonEnumerable(path));
                Object.defineProperty(js,"_idProperty", helpers.getDescriptorNonEnumerable(idProperty))
                Object.defineProperty(js,"_kill"      , helpers.getDescriptorNonEnumerable(kill))

//                console.log("ASSIGNING generic to", path, js._idProperty);
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
            path = path || "";
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




        function standardSignalsPackage() {
            function prints(path,data,oldData){
                var p  = path     && debugOptions.showPaths   ? path                              : "";
                var d  = data     && debugOptions.showData    ? "= "    +JSON.stringify(data)     : "";
                var od = oldData  && debugOptions.showOldData ? "from " + JSON.stringify(oldData) : "";
                return { p:p, d:d, od:od }
            }

            return  {
                rowAdded : function(path,data,index) {
                    var pr = prints(path,data,index);
                    if(pr.p || pr.d)
                        debugOptions.batchCreateMsg.push("RA::row added"+" "+ pr.p +" "+ pr.d)
                },
                rowRemoved : function(path,data,index) {
                    var pr = prints(path,data,index);
                    if(pr.p || pr.d)
                        debugOptions.batchDeleteMsg.push("RA::row added"+" "+ pr.p +" "+ pr.d+" "+ pr.od)
                },
                lengthChanged         : function(path,len)  {
                    var pr = prints(path,len);
                    if(pr.p)
                        debugOptions.batchUpdateMsg.push("lenChanged:"+" "+ pr.p +" "+ pr.d+" "+ pr.od)
                } ,
                propertyUpdated       : function(path,data,oldData){
                    var pr = prints(path,data,oldData);
                    if(pr.p || pr.d || pr.od)
                        debugOptions.batchUpdateMsg.push("Updated:"+" "+ pr.p+" "+ pr.d+" "+ pr.od);
                } ,
                propertyCreated       : function(path,data)        {
                    var pr = prints(path,data);
                    if(pr.p || pr.d || pr.od)
                        debugOptions.batchCreateMsg.push("Created:"+" "+ pr.p+" "+ pr.d);
                } ,
                propertyDeleted       : function(path)             {
                    var pr = prints(path);
                    if(pr.p || pr.d || pr.od)
                        debugOptions.batchDeleteMsg.push("Deleted:"+" "+ pr.p)
                } ,
                beforePropertyUpdated : function(path,data,oldData){
                    var pr = prints(path,data,oldData);
                    if(pr.p || pr.d || pr.od)
                        debugOptions.batchUpdateMsg.push("beforeUpdated:"+" "+ pr.p +" "+ pr.d +" "+ pr.od);
                } ,
                beforePropertyCreated : function(path,data) {
                    var pr = prints(path,data);
                        if(pr.p || pr.d || pr.od)
                    debugOptions.batchCreateMsg.push("beforeCreated:" + pr.p +" "+ pr.d);
                } ,
                beforePropertyDeleted : function(path)  {
                    var pr = prints(path);
                    if(pr.p || pr.d || pr.od)
                        debugOptions.batchDeleteMsg.push("beforeDeleted:"+" "+ pr.p)
                }
            }
        }


    }



}
