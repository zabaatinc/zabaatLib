import QtQuick 2.5
import "../Lodash"
//The layer between the view & the model. The model in this case is the restArray
ListModel {
    id : rootObject
    property var sourceModel
    property var properties
    property var filterFunc
    property string idProperty : 'id'
    dynamicRoles: true
    onSourceModelChanged: {
        var sigPkg = {
            propertyUpdated        : connections.propertyUpdated,
            propertyCreated        : connections.propertyCreated,
            beforePropertyDeleted  : connections.beforePropertyDeleted
        }
        if(logic.oldModel) {
            logic.oldModel._signals.removeListeners(sigPkg);
        }


        if(sourceModel){
            logic.myPath = sourceModel._path;
            sourceModel._signals.addListeners(sigPkg)
        }

        logic.init();
        logic.oldModel = sourceModel;
    }

    onPropertiesChanged: if(sourceModel)
                             logic.init();
    onIdPropertyChanged: logic.init();
    onFilterFuncChanged: logic.executeFilter();

    Component.onDestruction: {
        console.log("OH NO I DIE", logic.myPath)
        console.trace();
        console.log("--------------------------------")
        var sigPkg = {
            propertyUpdated        : connections.propertyUpdated,
            propertyCreated        : connections.propertyCreated,
            beforePropertyDeleted  : connections.beforePropertyDeleted
        }

        if(sourceModel){
            sourceModel._signals.removeListeners(sigPkg);
        }
        if(logic.oldModel && logic.oldModel !== sourceModel){
            logic.oldModel._signals.removeListeners(sigPkg);    //safety
        }
    }

    function getEmbedded(path){
        for(var p in logic.embeddedModelsMap){
            if(p === path)
                return logic.embeddedModelsMap[p]
        }
        return null;
    }

    property Item logic : Item {
        id : logic
        property string myPath         : "";
        property var embeddedModelsMap : ({});
        property var oldModel          : null;
//        property var embeddedModelsMapPtr : ({})

        function executeFilter(){
            var fn = typeof filterFunc === 'function' ? filterFunc : function() { return true; }

            //first let's see if filterFunc should remove things from our list
            for(var i = 0; i < rootObject.count; ++i){
                var elem = rootObject.get(i);
                if(!fn(elem,elem.path)){
                    del(elem.path)
                }
            }

            //then let's add
            var isIded
            Lodash.each(sourceModel,function(v,k){
                //console.log('ITERATING over', k, JSON.stringify(v))
                if(k === 0) {   //this is where we determine if this is ided or not
                    isIded = v && v.hasOwnProperty(idProperty);
                }
                var key = Object.getOwnPropertyDescriptor(sourceModel,k).get(true);
//                console.log("KEY is", key, "@", JSON.stringify(v))
//                var key  = isIded ? v[idProperty] : i;
                if(fn(v,key))
                    add(v,key);
            })
        }

        function addVm(path, restArr){
            if(logic.embeddedModelsMap[path])
                return false;   //already exists


            var vm          = Qt.createComponent("ViewModel.qml").createObject(embeddedModels);
            vm.logic.myPath = path;
            vm.properties   = 'All';

            logic.embeddedModelsMap[path] = vm;
            console.log("Added embeddedModel @", path, JSON.stringify(restArr));

            vm.sourceModel= restArr;
            vm.logic.embeddedModelsMap = logic.embeddedModelsMap;   //so we only haf one map!

            console.log("---\n"+ Lodash.keys(logic.embeddedModelsMap).join("\n")+ "\n---\n")
            return true;
        }


        function add(val,k){
//            console.log("ADD FUNCTION BEGIN -->", k, JSON.stringify(val));
            var element = {
                path : val._path || k,
                value: {}
            }
            if(typeof val !== 'object'){
                element.value = val;
//                console.log("--> ADD" , element.path)
                return append(element);
            }



            function attach(val,element,properties){
                var propIsArray = Lodash.isArray(properties);
                Lodash.each(val, function(v,k){
                    if(propIsArray && properties.indexOf(k) === -1 && k !== idProperty)
                        return;

                    if(Lodash.isArray(v)){  //skip this badboy & do some recursion here!
                        addVm(v._path, v);
                    }
                    else if(Lodash.isObject(v)) {   //recursively keep attaching. we will always skip arrays into new lms
                        element[k] = {}
                        attach(v, element[k],"All");
//                        console.log("attached", k , JSON.stringify(element,null,2))
                    }
                    else {
                        element[k] = v;
                    }
                })
            }

            attach(val,element.value,properties);
//            console.log("APPENDING", JSON.stringify(element))
            append(element);
        }




        //deletes an index & any related embeddedModels !!
        function del(path,idx){
            if(idx === undefined){
                idx = logic.findByPath(path,true);
            }
            if(idx === -1)
                return false;

            console.log("DELETE CALLED ON", path)
            //remove all embedded stuffs that match this path!
            Lodash.eachRight(logic.embeddedModelsMap, function(v,k) {
                if(k.indexOf(path) === 0) {
                    v.clear();
                    v.destroy();
                    delete logic.embeddedModelsMap[k];
                }
            })

            //remove our idx
            remove(idx);
        }

        //tries to see if any element's path matches path
        function findByPath(path, giveIdx){
            for(var i= 0; i < count; ++i) {
                var elem = get(i);
                if(elem.path === path)
                    return giveIdx ? i : elem;
            }
            return giveIdx ? -1 : null;
        }

        //tries to see if any elements's path is contained by path
        function findByPathFuzzy(path, giveIdx){
            for(var i= 0; i < count; ++i) {
                var elem = get(i);
                if(path.indexOf(elem.path) === 0)
                    return giveIdx ? i : elem;
            }
            return giveIdx ? -1 : null;
        }

        //determies if the path is @ root
        function isAtRoot(path){
//            if(path.indexOf(logic.myPath) !== 0)
//                return false
            if(!pathIsRelevant(path))
                return false;

            var reduced = path.replace(logic.myPath, "");
            if(reduced.charAt(0) === "/")
                reduced = reduced.slice(1);

            return reduced.indexOf("/") === -1 ? true : false
        }

        //determines if the path is relevant to this Viewmodel
        function pathIsRelevant(path){
            var biggestMatch = "";
            var listNames = [logic.myPath].concat(Lodash.keys(logic.embeddedModelsMap));
            Lodash.each(listNames, function(v) {
                if(path.indexOf(v) === 0) {
                    biggestMatch = v.length > biggestMatch.length ? v : biggestMatch;
                }
            })
//            console.log("BIGGESTMATCH AGAINST", path, "IS", biggestMatch)
//            console.log(biggestMatch, "===", logic.myPath , logic.myPath === biggestMatch)
            return biggestMatch === logic.myPath ? true : false
        }


        function init(){
            rootObject.clear();
            Lodash.each(embeddedModelsMap, function(v,k){
                v.destroy();
                delete embeddedModelsMap[k];
            })
            executeFilter();
        }

        //updates obj with newVal
        function setOnElem(obj, path, newVal){
            //console.log(JSON.stringify(obj), path, JSON.stringify(newVal))
            var arr = Lodash.compact(path.split("/"));
            var ptr = obj;

            if(arr.length === 0)
                return false;

            for(var k = 0 ; k < arr.length; ++k) {
                var v = arr[k];
                if(k == arr.length - 1){
                    //update!
                    var currentType = {isArray:Lodash.isArray(ptr[v]),isObject:Lodash.isObject(ptr[v])}
                    var newType     = {isArray:Lodash.isArray(newVal),isObject:Lodash.isObject(newVal)}
                    if(currentType.isArray && newType.isArray) {
                        //WOAH, THIS SHOULD NEVER HAPPEN
                        console.log("THIS CASE SHOULD NEVER OCCUR!")

                    }
                    else if(currentType.isObject && newType.isObject){
                        Lodash.each(newVal, function(val,key) {
                            if(Lodash.isArray(val)) {
                                //TODO CREATE ARRAY
//                                var path = Object.getOwnPropertyDescriptor(newVal,key).get(true);
                                addVm(val._path,val);
                            }
                            else if(Lodash.isObject(val)){
                                //RECURSION
                                if(!ptr[key])
                                    ptr[key] = {}
//                                var path = Object.getOwnPropertyDescriptor(newVal,key).get(true);
                                setOnElem(ptr[key],val._path,val);
                            }
                            else {
                                ptr[key] = newVal[key]
                            }
                        })
                    }
                    else {  //types differ!
                        if(!newType.isArray)
                            ptr[v] = newVal;
                        else
                            addVm(newVal._path,newVal);
                    }

                }
                else {
                    ptr = ptr[v];
                    if(ptr === undefined || ptr === null){
                        console.log("FAILED ON", v)
                        return;
                    }
                }
            }

            return true;
        }


        Item {
            id : connections
            function propertyUpdated(path,data,oldData)  {
                if(!logic.pathIsRelevant(path))
                    return;

                var idx = logic.findByPathFuzzy(path,true);
                if(idx === -1)
                    return;

                var elem = rootObject.get(idx);
                path = path.replace(elem.path, "");
                path = path.charAt(0) === "/" ? path.slice(1) : path;


                var clone = JSON.parse(JSON.stringify(elem.value))
                if(logic.setOnElem(clone,path,data))
                    rootObject.setProperty(idx, 'value', clone);
                else
                    rootObject.setProperty(idx, 'value', data);
            }
            function propertyCreated(path,data)  {
                if(logic.isAtRoot(path)){
//                    var key = data.hasOwnProperty(idProperty) ? data[idProperty] : rootObject.count;
                    var fn = typeof filterFunc === 'function' ? filterFunc : function() { return true; }
                    if(fn(data,path)){
                        console.log("Adding", path, "to", logic.myPath)
                        logic.add(data,path);
                    }
                }
//                else {
//                    //navigate to this thing! first see if there's a path that matches in our map!
//                }
            }
            function beforePropertyDeleted(path)  {
                if(logic.isAtRoot(path)){
                    logic.del(path);
                }
            }
        }


        Item {
            id : embeddedModels

        }
    }

}
