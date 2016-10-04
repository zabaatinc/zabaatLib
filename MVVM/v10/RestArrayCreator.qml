import QtQuick 2.5
import "../Lodash"
pragma Singleton
QtObject {
    id : rootObject
    objectName : "RestArrayCreator"

    //defaults to array construction!
    function create(js, path, signals, idProperty) {
        signals    = signals    || priv.standardSignalsPackage();
        idProperty = idProperty || "id";


        function createObject(js,path) {
            path = helpers.getPath(path);
            if(Lodash.isArray(js)) {
                return convert(js,path);
            }

            var ret = [];
            helpers.attachPropertiesArray(js,path,signals,idProperty);
            return ret;
        }

        function createArray(js,path) {
            path = helpers.getPath(path);
        }

        return Lodash.isObject(js) ? createObject(js,path) :
                                     createArray(js,path);
    }


    property Item __priv : Item{
        id : priv

        QtObject {
            id : helpers
            function getDescriptor(val , path, isReadOnly, updateFunc) {
                var _value = val;
                var _path  = path;

                var r = { enumerable : true }
                r.get =  function() {  return _value; }
                r.set = isReadOnly ? function() { console.error("cannot write to readonly property", _path ) ;} :
                                     function(val, noUpdate) {
                                        if(val != _value) {
                                            var oldVal = _value;
                                            this._signals.beforePropertyUpdated(_path,oldVal,val);
                                            _value = val;

                                            if(!noUpdate)
                                                this._signals.propertyUpdated(_path,oldVal,val);
                                        }
                                    }

                return r;
            }

            //creates a restful path
            function getPath(path,key,val) {
                if(key === null || key === undefined){
                    return path ? path : "";
                }

                var k = val && val[uniqueIdProperty] !== null && val[uniqueIdProperty] !== undefined ? val.id : key;
                return path ? path + "/" + k : k;
            }

            function getDescriptorNonEnumerable(value) {
                var _value = value;
                return {
                    enumerable : false,
                    value: _value
                }
            }

            function attachPropertiesArray(js,path,signals,idProperty) {
                Object.defineProperty(js,"_signals", helpers.getDescriptorNonEnumerable(signals));
                Object.defineProperty(js,"_path", helpers.getDescriptorNonEnumerable(path));
                Object.defineProperty(js,"_idProperty", helpers.getDescriptorNonEnumerable(idProperty))
            }

            function attachPropertiesObject(js,path,signals,idProperty) {
                Object.defineProperty(js,"_signals", helpers.getDescriptorNonEnumerable(signals));
                Object.defineProperty(js,"_path", helpers.getDescriptorNonEnumerable(path));
                Object.defineProperty(js,"_idProperty", helpers.getDescriptorNonEnumerable(idProperty))
            }
        }

        function standardSignalsPackage() {
            return  {
                propertyUpdated       : function(path,data,oldData){ console.log("default::propertyUpdated:", path, "=",data,'from', oldData)      } ,
                propertyCreated       : function(path,data)        { console.log("default::propertyCreated:", path, "=",data)                      } ,
                propertyDeleted       : function(path)             { console.log("default::propertyDeleted:", path)                                } ,
                beforePropertyUpdated : function(path,data,oldData){ console.log("default::beforePropertyUpdated:", path, "=",data,'from', oldData)} ,
                beforePropertyCreated : function(path,data)        { console.log("default::beforePropertyCreated:", path, "=",data)                } ,
                beforePropertyDeleted : function(path)             { console.log("default::beforePropertyDeleted:", path)                          }
            }
        }
        function convert(js, path, signals) {

            function recursiveIterator(v,k,acc,path) {
                var p = helpers.getPath(path,k,v);
                if(Lodash.isArray(v)) {
                    acc[k] = convertArr(v,p);
                }
                else if(Lodash.isObject(v) ){
                    acc[k] = convertObj(v,p);
                }
                else {
                    var isReadonly = k ===  acc._idProperty;
                    Object.defineProperty(acc,k,helpers.getDescriptor(v,p,isReadonly));
                }
            }


            function convertArr(js,path) {
                var arr = priv.createArray(null,path,signals);
                Lodash.each(js, function(v,k) { recursiveIterator(v,k,arr,path); })
                return arr;
            }

            function convertObj(js,path) {
                var obj = priv.createObject(null,path,signals);
                Lodash.each(js, function(v,k) { recursiveIterator(v,k,obj,path); })
                return obj;
            }




            return Lodash.isArray(js) ? convertArr(js,path) :
                                        Lodash.isObject(js) ? convertObj(js,path) :
                                                              js;
        }


        function createArray(js,path,signals,idProperty) {
            var p = helpers.getPath(path);
            if(Lodash.isArray(js)) {
                return convert(js,path,signals);
            }

            var ret = [];
            helpers.attachPropertiesArray(ret,p,signals,idProperty);
            return ret;
        }

        function createObject(js, path, signals,idProperty) {
            path = path || "";
            idProperty = idProperty
            var p = helpers.getPath(path);
            if(Lodash.isObject(js)) {
                return convert(js,path,signals);
            }

            var ret = {};
            helpers.attachPropertiesObject(ret,p,signals,idProperty);
            return ret;
        }





    }



}
