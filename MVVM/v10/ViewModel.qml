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

//    property alias logic : logic
//    property alias

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
        if(properties)
            logic.init();

        logic.oldModel = sourceModel;
    }

    onPropertiesChanged: if(sourceModel && properties) logic.init();
    onIdPropertyChanged: logic.init();
    onFilterFuncChanged: logic.executeFilter();

    Component.onDestruction: {
        var sigPkg = {
            propertyUpdated        : connections.propertyUpdated,
            propertyCreated        : connections.propertyCreated,
            beforePropertyDeleted  : connections.beforePropertyDeleted
        }

        if(sourceModel){
            sourceModel._signals.removeListeners(sigPkg);
        }
        if(logic.oldModel && logic.oldModel !== sourceModel){
            logic.oldModel._signals.removeListneres(sigPkg);    //safety
        }

    }

    property Item logic : Item {
        id : logic
        property string myPath : "";
        property var embeddedModelsMap : ({});
        property var oldModel: null;

        function executeFilter(){
            var fn = typeof filterFunc === 'function' ? filterFunc : function() { return true; }

            //first let's see if filterFunc should remove things from our list
            for(var i = 0; i < rootObject.count; ++i){
                var elem = rootObject.get(i);
                var key  = elem.path;
                if(!fn(elem,key,i)){
                    del(key,i)
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
                if(fn(v,key,i))
                    add(v,key,i);
            })
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
                        var p = v._path;
                        var vm = newVm();
//                        console.log("path @", k, "=", v._path);
                        vm.logic.myPath = p;
                        vm.properties = 'All';
                        console.log("Added embeddedModel @", p, JSON.stringify(v));
                        vm.sourceModel= v;
                        logic.embeddedModelsMap[p] = vm;
                    }
                    else if(Lodash.isObject(v)) {
                        element[k] = {}
                        attach(v, element[k],"All");
                        console.log("attached", k , JSON.stringify(element,null,2))
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

        function newVm(){
            var cmp = Qt.createComponent("ViewModel.qml")  //self
            return cmp.createObject(embeddedModels);
        }


        //deletes an index & any related embeddedModels !!
        function del(path,idx){
            if(idx === undefined){
                idx = connections.logic.findByPath(path,true);
            }
            if(idx === -1)
                return false;

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

        function findByPath(path, giveIdx){
            for(var i= 0; i < count; ++i) {
                var elem = get(i);
                if(elem.path === path)
                    return giveIdx ? i : elem;
            }
            return giveIdx ? -1 : null;
        }

        function findByPathFuzzy(path, giveIdx){
            for(var i= 0; i < count; ++i) {
                var elem = get(i);
                if(path.indexOf(elem.path) === 0)
                    return giveIdx ? i : elem;
            }
            return giveIdx ? -1 : null;
        }

        function isAtRoot(path){
            if(path.indexOf(logic.myPath) === -1)
                return false;

            var reduced = path.replace(logic.myPath, "");
            if(reduced.charAt(0) === "/")
                reduced = reduced.slice(1);

            return reduced.indexOf("/") === -1 ? true : false
        }

        function init(){
            rootObject.clear();
            Lodash.each(embeddedModelsMap, function(v,k){
                v.destroy();
                delete embeddedModelsMap[k];
            })
            executeFilter();
        }

        function setOnElem(obj, path, newVal){
            var arr = path.split("/");
            var ptr = obj;


            for(var k in arr) {
                var v = arr[k];
                if(k == arr.length - 1){
                    //update!
                    if(typeof newVal !== 'object') {
                        console.log("Update", v, "to", JSON.stringify(newVal,null,2), "from", ptr[v])
                        ptr[v] = newVal;
                        console.log(JSON.stringify(ptr,null,2))
//                        console.log("Updated", v, "to", JSON.stringify(data,null,2), "from", ptr[v])
                    }
                    else {
                        Lodash.each(ptr[v], function(val,key) {
                            if(newVal.hasOwnProperty(key)) {
                                console.log("Update", val , 'to', newVal[key] )
                                ptr[key] = newVal[key]
                            }
                        })
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

//            console.log("FINITO")
        }


        Item {
            id : connections
            function propertyUpdated(path,data,oldData)  {
                if(path.indexOf(logic.myPath) === -1)
                    return;

                var elem = logic.findByPathFuzzy(path);
                if(!elem)
                    return;

                path = path.replace(elem.path, "");
                path = path.charAt(0) === "/" ? path.slice(1) : path;

                logic.setOnElem(elem.value,path,data);
                elem.value.firstname = "Shahanu";
                console.log(JSON.stringify(elem.value,null,2))

            }
            function propertyCreated(path,data)  {
                if(logic.isAtRoot(path)){
//                    var key = data.hasOwnProperty(idProperty) ? data[idProperty] : rootObject.count;
                    var fn = typeof filterFunc === 'function' ? filterFunc : function() { return true; }
                    console.log("Adding", path, "to", logic.myPath)
                    if(fn(data,path,rootObject.count)){
                        logic.add(data,path,rootObject.count);
                    }
                }
                else {
                    //navigate to this thing! first see if there's a path that matches in our map!

                }
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
