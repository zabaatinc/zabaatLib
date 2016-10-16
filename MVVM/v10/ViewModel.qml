import QtQuick 2.5
import "../Lodash"
ListModel {
    id : rootObject
    property var model
    property var properties
    property var filterFunc
    property string idProperty : 'id'

    onModelChanged     : if(model && properties) logic.init();
    onPropertiesChanged: if(model && properties) logic.init();
    onIdPropertyChanged: logic.init();
    onFilterFuncChanged: logic.executeFilter();



    Connections {
        target : model ? model : null;
        onPropertyUpdated : {

        }
        onPropertyCreated : {

        }
        onBeforePropertyDeleted : {

        }
    }

    property Item logic : Item {
        id : logic
        property var map : ({});

        function executeFilter(){
            var fn = typeof filterFunc === 'function' ? filterFunc : function() { return true; }

            //first let's see if filterFunc should remove things from our list
            for(var i = 0; i < rootObject.count; ++i){
                var elem = rootObject.get(i);
                var key  = elem.hasOwnProperty(idProperty) ? elem[idProperty] : i;
                if(!fn(elem,key,i)){
                    del(key,i)
                }
            }

            //then let's add
            var isIded
            Lodash.each(model,function(v,k){
                if(k === 0) {   //this is where we determine if this is ided or not
                    isIded = v.hasOwnProperty && v.hasOwnProperty(idProperty);
                }
                if(fn(v))
                    add(v);
            })
        }

        function add(val){
            var isIded = val.hasOwnProperty(idProperty) ? true : false;
            if(!isIded){

            }
        }

        function del(path,idx){
            if(idx !== undefined){

            }
        }

        function init(){
            rootObject.clear();
            Lodash.each(map, function(v,k){
                v.destroy();
                delete map[k];
            })
            executeFilter();
        }



        Item {
            id : embeddedModels

        }
    }

}
