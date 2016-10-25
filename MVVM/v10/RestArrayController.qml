import QtQuick 2.5
import Zabaat.Base 1.0
pragma Singleton
QtObject {
    id : rootObject
    signal sendGetModelRequest(string modelName);
    signal newModelAdded(string modelName, int count);

    property var modelTransformerFunctions : ({})
    property alias modelCount : priv.count
    property alias models: priv.map

    /*! Update message was recevied (verb was update or updated). Just so we have this signal for compatibality with standard ZController \hr*/
    signal updateReceived(string updatedModel, string updatedId, var data)

    /*! Create message was received (verb was create or created) \hr*/
    signal createReceived(string createdModel, string createdId, var data)

    //before signals
    signal beforePropertyUpdated(string name, string path, var data, var oldData);
    signal beforePropertyCreated(string name, string path, var data);
    signal beforePropertyDeleted(string name, string path);

    //on signals
    signal propertyUpdated(string name, string path, var data, var oldData);
    signal propertyCreated(string name, string path, var data);
    signal propertyDeleted(string name, string path);

//    onBeforePropertyUpdated: console.log(name,path,data,oldData);


    function allModelNames(){
        return Lodash.keys(priv.map);
    }

    function getModel(name){
        return priv.map[name];
    }

    function getModelWhenItArrives(name, obj, prop, dontAutoRequest){
        var m = getModel(name);
        if(m)
            return m;

        var o = { _obj : obj , _prop : prop }
        if(priv.modelCbs[name])       priv.modelCbs[name].push(o)
        else                          priv.modelCbs[name] = [o]


        if(!dontAutoRequest)
            sendGetModelRequest(name)       //TODO , see if we already have a request!
        return null
    }

    function addModel(name,data,cb){
        if(!name)
            return console.error("no name provided to RestArrayController.addModel", name)

        var modelName = name
        var id        = ""

        if(modelTransformerFunctions && modelTransformerFunctions[name]){
            modelTransformerFunctions[name](data)
        }

        //Lets first check if the name has '/'
        if(name.indexOf('/') !== -1) {
            var arr   = name.split("/")
            modelName = arr[0]
            id        = arr[1]

            //add an id field to this bro!!
            if(!data.id)
                data.id = id
        }

        var d = Lodash.isArray(data) ?  d : [d]
        var m = getModel(modelName);
        if(!m) {
            priv.map[modelName] = RestArrayCreator.create(d,null,priv.signalsPackage(modelName));
            priv.checkCallbacks(modelName,tabStr + "\t")        //check if anything has requested this model!
            rootObject.newModelAdded(modelName, ++priv.count); //emit that a new model was added!
        }
        else {
            Lodash.each(d, function(v) {    //the push is the restful push so it goes and does updates!
                m.push(v);
            })
        }
    }

    function get(str){
        var strArr = Lodash.compact(str.split('/'));
        if(strArr.length === 0)
            return undefined;

        var mName   = strArr[0];
        strArr.splice(0,1)
        var propStr = strArr.join('/');
        var m       = getModel(mName);
        return m ? m.get(propStr) : undefined;
    }

    function set(str,val){
        var strArr = Lodash.compact(str.split('/'));
        if(strArr.length === 0)
            return undefined;

        var mName   = strArr[0];
        strArr.splice(0,1)
        var propStr = strArr.join('/');
        var m       = getModel(mName);
        return m ? m.set(propStr,val) : undefined;
    }

    function del(str){
        var strArr = Lodash.compact(str.split('/'));
        if(strArr.length === 0)
            return undefined;

        var mName   = strArr[0];
        strArr.splice(0,1)
        var propStr = strArr.join('/');
        var m       = getModel(mName);
        return m ? m.del(propStr) : undefined;
    }



    function getById(arr, id, giveIndex) {
        if(typeof arr === 'string')
            arr = getModel(arr);

        if(!arr)
            return giveIndex ? -1 : null;

        var f = function (a) { return a.id === id }
        return giveIndex ? Lodash.find(arr, f) : Lodash.findIndex(arr, f);
    }

    function getByProperty(arr, prop, value,changeFunc){
        if(typeof arr === 'string')
            arr = getModel(arr);

        changeFunc = typeof changeFunc === 'function' ? changeFunc : function(a) { return a }

        var f = function (a) { return a[prop] === changeFunc(value) }
        return Lodash.find(arr,f);
    }

    function clearModel(modelName){
        var m = getModel(modelName);
        if(m){
            Lodash.eachRight(m, function(v,k){
                m.remove(k);
            })
        }
    }

    function removeById(arr,id){
        if(typeof arr === 'string')
            arr = getModel(arr)

        return arr ? arr.del(id) : "false"
    }


    property QtObject __priv : QtObject{
        id : priv
        property var map   : ({})
        property int count : 0

        property var modelCbs : ({})

        function signalsPackage(name) {
            return {
                beforePropertyUpdated : function(path,data,oldData){ beforePropertyUpdated(name,path,data,oldData) },
                beforePropertyCreated : function(path,data){ beforePropertyCreated(name,path,data) },
                beforePropertyDeleted : function(path){ beforePropertyDeleted(name,path) },
                propertyUpdated       : function(path,data,oldData){
                    propertyUpdated(name,path,data,oldData)

                    if(path.split("/").length === 1)
                        updateReceived(name,path,data);
                },
                propertyCreated       : function(path,data){
                    propertyCreated(name,path,data)

                    if(path.split("/").length === 1)
                        createReceived(name,path,data);
                },
                propertyDeleted       : function(path){ propertyDeleted (name,path) }
            }
        }
        function checkCallbacks(modelName) {
            var tabStr = arguments.length == 2 ? arguments[1] : ""
            if(modelCbs[modelName]) {
                var matchStr = modelName
                var id    = ""
                if(modelName.indexOf("/") !== -1) {
                    var arr = modelName.split("/")
                    matchStr = arr[0]
                    id       = arr[1]

                    //we should also check if something was wanting the root model here!
                    checkCallbacks(matchStr,tabStr + "\t\t")
                }

                for(var i = modelCbs[modelName].length - 1; i > -1; i--) {
                    var obj  = modelCbs[modelName][i]._obj;
                    if(obj !== null) {
                        var prop = modelCbs[modelName][i]._prop;

                        if(id == "")
                            obj[prop] = getModel(matchStr)
                        else {
                            for(var j = 0; j < getModel(matchStr).count; j++) {
                                if( getModel(matchStr).get(j).id && getModel(matchStr).get(j).id == id) {
                                    obj[prop] = getModel(matchStr).get(j)
                                    break
                                }
                            }
                        }
                    }
                    modelCbs[modelName].splice(i,1)
                }
                delete modelCbs[modelName]
            }
        }
    }
}
