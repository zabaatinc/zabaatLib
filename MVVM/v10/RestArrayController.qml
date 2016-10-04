import QtQuick 2.5
import "../Lodash"
import "./ObservableArray.js" as OA
import "./ObservableObject.js" as OO
pragma Singleton
QtObject {
    id : rootObject
    //before signals
    signal beforeArrayCreated   (string name);
    signal beforeArrayDeleted   (string name);
    signal beforeArrayUpdated   (string name);
    signal beforePropertyUpdated(string name, string path, var data, var oldData);
    signal beforePropertyCreated(string name, string path, var data);
    signal beforePropertyDeleted(string name, string path);

    //on signals
    signal arrayCreated   (string name);
    signal arrayDeleted   (string name);
    signal arrayUpdated   (string name);
    signal propertyUpdated(string name, string path, var data, var oldData);
    signal propertyCreated(string name, string path, var data);
    signal propertyDeleted(string name, string path);

    onBeforePropertyUpdated: console.log(name,path,data,oldData);


    //if given a name, it will add it to our map!
    function newArray(name_opt,arr_opt){
        if(!name_opt){
            return OA.create(arr_opt);
        }

        rootObject.beforeArrayCreated(name_opt);
        var a = OA.create(arr_opt,"", priv.signalsPackage(name_opt));
        priv.count++;
        rootObject.arrayCreated(name_opt);

        return a;
    }

    function exists(name) {
        return priv.map[name] ? true : false;
    }

    //delete the array identified by name. Will call the _.kill method on the array.
    function deleteArray(name) {
        var arr = priv.map[name];
        if(!arr)
            return;

        rootObject.beforeArrayDeleted(name);
        arr._kill();        //will emit granular property messages!
        delete priv.map[name];
        priv.count--;
        rootObject.arrayDeleted(name);
    }

    function updateArray(name, arr) {
        if(!name)
            return;

        var mapArr = priv.map[name];
        if(!mapArr)
            return newArray(name,arr);

        rootObject.beforeArrayUpdated(name);
        mapArr._update(arr);    //will emit granular property messages!
        rootObject.arrayUpdated(name);
    }

    function reset() {
        var arrayNames = Lodash.keys(priv.map);
        Lodash.each(arrayNames, function(v) { deleteArray(v); })
    }




    property QtObject __priv : QtObject{
        id : priv
        property var map : ({})
        property int count : 0

        function signalsPackage(name) {
            return {
                beforePropertyUpdated : function(path,data,oldData){ beforePropertyUpdated(name,path,data,oldData) },
                beforePropertyCreated : function(path,data){ beforePropertyCreated(name,path,data) },
                beforePropertyDeleted : function(path){ beforePropertyDeleted(name,path) },
                propertyUpdated       : function(path,data,oldData){ propertyUpdated(name,path,data,oldData) },
                propertyCreated       : function(path,data){ propertyCreated(name,path,data) },
                propertyDeleted       : function(path){ propertyDeleted (name,path) }
            }
        }


    }
}
