import QtQuick 2.5
import "Functions.js" as Functions
//Contains dynamically generated list models at runtime !!

/*!
   \brief Class that handles models quite well. Is used in XhrController and SocketIOController.
   \inqmlmodule Zabaat.Controller 1.0 \hr
*/
Item
{
    id : rootObject

    /*! request to get model <modelName> . Both XhrController and SocketIOController act to this request  \hr */
    signal sendGetModelRequest(string modelName)
    signal newModelAdded(string modelName, int count);

    /*! Update message was recevied (verb was update or updated) \hr*/
    signal updateReceived(string updatedModel, string updatedId, var data)

    /*! Create message was received (verb was create or created) \hr*/
    signal createReceived(string createdModel, string createdId, var data)

    /*! The models we currently have \hr */
    property alias models                  : priv.models

    /*! Functions to transform specific models && model objects as they arrive. Determined by key. \hr */
    property var modelTransformerFunctions : ({})
    property alias modelCount : priv.modelCount

    Item {
        id : modelContainer
    }


    QtObject {
        id : priv
        property var models        : ({})
        property int modelCount    : 0
        property var modelCbs      : ({})         //These are callbacks for the entire models!


        //Checks callbacks for newly received models or model pieces
        //If we got something like "customers/1" , it will check for "customers/1" as well as "customers"
        function isUndef(item,prop){
            if(item === null || typeof item === 'undefined')
                return true;

            prop = isArray(prop) ? prop : [prop]
            for(var i = 0; i < prop.length; ++i){
                var p = prop[i]
                if(item[p] === null || typeof item[p] === 'undefined')
                    return true;
            }
            return false;
        }
        function isDef(item) {
            return !isUndef.apply(this,arguments);
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
                    if(obj !== null)
                    {
                        var prop = modelCbs[modelName][i]._prop;

                        if(id == "")
                            obj[prop] = getModel(matchStr)
                        else {
                            for(var j = 0; j < getModel(matchStr).count; j++) {
                                if( getModel(matchStr).get(j).id && getModel(matchStr).get(j).id == id)
                                {
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
        function appendToModel(lm, data) {
            var arr = isArray(data) ? data : [data]
            for(var i = 0; i < arr.length; i++) {
                addObjectToModel(lm,arr[i])
            }
        }
        function addObjectToModel(lm, obj) {
//            console.log("data is", toString.call(obj))
            if(obj && isDef(obj,"id")) {
                var existingIdx = getById(lm, obj.id, true);

                if(existingIdx === -1){  //data doesnt exist. append it. EASY. otherwise, we got our work cut out fr us!
                    lm.append(obj);
                    return null;
                }
                else {              //update existing
                    var existingItem = lm.get(existingIdx);
                    updateItem(existingItem, obj);
                }
            }
        }

        function updateItem(existingItem, obj, location){
            for(var o in obj)  {
                if(o !== 'id') {
                    var oldValue  = existingItem[o]
                    var newValue  = obj[o]

                    if(typeof newValue !== 'object'){   //is a simple object
                        if(oldValue !== newValue)
                             existingItem[o] = newValue
                    }
                    else if(!isDef(oldValue)){  //we dont have an old lm, create it and append obj[o] to it??
                        if(isArray(newValue) ){
                            if(newValue.length > 0){
                                existingItem[o] = Functions.getNewObject('ZListModel.qml', modelContainer)
                                existingItem[o].append(newValue)
                            }
                        }
                        else {  //its an object, so we don't need to make a new ListModel
                            existingItem[o] = newValue
                        }
                    }
                    else {
                        deepCopy(existingItem[o],obj[o], existingItem, o,o )
                    }
                }
            }
        }
        function deepCopy(obj1, obj2, prev, lvl1, lvl2)  {

            if(typeof obj2 !== 'object')  {
                //do equality check
                if(obj1 !== obj2)
                    obj1 = obj2

                return
            }

            //if we got an update such that obj2 is now empty, we should do that. //TODO, check the else.
            if(isArray(obj2) && obj2.length === 0){
                if(obj1.toString().toLowerCase().indexOf('model') !== -1)
                    obj1.clear()
                else
                    obj1 = []

                return;
            }

            for(var o in obj2) {
                var newVal = obj2[o]

                if(isDef(newVal) && isDef(newVal.id)) {

                    var elem = getById(obj1, newVal.id)  //this is TE 0
                    if(!elem) {

                        for(var p in newVal) {
                            if(typeof newVal[p] !== 'object') {
                                if(elem[p] !== newVal[p])
                                    elem[p] = newVal[p]
                            }
                            else  {
                                var ret = deepCopy(elem[p], newVal[p], elem, lvl1 + '/' + newVal.id + '/' + p, lvl2 + '/' + o + '/' + p)
                            }
                        }
                    }
                    else {

                        if(obj1.count !== null && typeof obj1.count !== 'undefined') {
                            obj1.append(newVal[o])
                        }
                        else {  //if the model doesn't even exist!!
                            obj1 = [] //newModelFunc('ZListModel.qml',existingItem)
                            obj1.append(obj2)

                            return
                        }
                    }
                }
                else {       //overwrite stuffs!
                     if(obj1.count !== null && typeof obj1.count !== 'undefined')
                     {
                         obj1.clear()
                         obj1.append(obj2)
                         return
                     }
                     else if(obj1.toString().toLowerCase().indexOf('modelobject') === -1 && !isArray(obj1) && typeof obj1 === 'object')
                     {
                         if(prev && prev[lvl1]){
                             prev[lvl1] = obj2
                             return
                         }

                     }
                     else
                     {
                         if(obj1[o] !== newVal[o])
                             obj1[o] = newVal[o]
                     }
                }

            }

        }
    }


    /*! fn : Returns the names of all the models we have so far \hr */
    function getAllModelNames(){
        var temp = []
        for(var m in priv.models)
            temp.push(m)
        return temp
    }

    /*! fn: Flat get model request. Use this if you're happy with a null return forever! \hr */
    function getModel(name)  {  if(priv.models[name])  return priv.models[name];  return null  }


    /*! fn : Get model when it arrives. This will auto fill your model when it gets here locally. If you set the last param to true, we wont autorequest the server
    For this model \hr */
    function getModelWhenItArrives(name, obj, prop, dontAutoRequest) {
        if(priv.models[name]){
//            console.log("returning",name)
            return priv.models[name]
        }
        else
        {
            var o = { _obj : obj , _prop : prop }
            if(priv.modelCbs[name])       priv.modelCbs[name].push(o)
            else                          priv.modelCbs[name] = [o]


            if(!dontAutoRequest)
                sendGetModelRequest(name)       //TODO , see if we already have a request!
            return null
        }
    }


   /*! fn: Adds model with <name> and data <model> . Will add new model if it doesn't exist. Otherwise, will insert/update an existing model \hr */
   function addModel(name, data, cb)  {
       if(name === null || typeof name === 'undefined')
           return console.error("no name provided to ZController.addModel", name)

       var tabStr = arguments.length == 3 ? arguments[2] : ""
       var modelName = name
       var id        = ""

       if(modelTransformerFunctions && modelTransformerFunctions[name]){
           //transform the data cause we got some hotshot model here that needs custom treatment!
           console.log(rootObject, 'modelTransformerFunction(',name,',',data,")")
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

       var lm = priv.models[modelName]
       var isNew = !lm

       if(!lm) {
           priv.models[modelName] = lm = Functions.getNewObject("ZListModel.qml",modelContainer)
           lm.objectName = modelName
       }

       priv.appendToModel(lm,data)
       if(isNew) {
           priv.checkCallbacks(modelName,tabStr + "\t")        //check if anything has requested this model!
           rootObject.newModelAdded(modelName, ++priv.modelCount); //emit that a new model was added!
       }
   }

   /*! fn: Returns whether the passed in param is an array \hr */
   function isArray(obj) {
       return toString.call(obj) === '[object Array]'
   }


   /*! fn: get item by <id> if it exists in model <lm>. lm can be a string name or a model. \hr */
   function getById(lm, id, giveIndex){
       if(typeof lm === 'string')
           lm = getModel(lm);

       if(lm) {
           for(var i = 0; i < lm.count; ++i)   {
               var item = lm.get(i);
               if(item.id === id){
                   return giveIndex ? i : lm.get(i);
               }
           }
       }
       return giveIndex ? -1 : null;
   }

   /*! fn: if prop is an array, we will deal with it differently! We will recurse thru to find the item!
   valid examples of using this function are: __addData. BE WARNED THAT THIS MAY NOT HAVE THE BEST PERFORMANCE FOR HUGE LISTS.
                                                         IN THE WORST CASE IT WILL DO, n * prop.length comparisons, where n is the number of items in the model!
    (1)   getByProperty('workOrders','jobNumber',26400)
    (2)   getByProperty('vehicles',['details','stockNumber'],UC-770) \hr */
   function getByProperty(lm, prop, value, changeFunc){
       if(typeof lm === 'string')
            lm = getModel(lm)

       if(lm !== null && typeof lm !== 'undefined') {
//           console.log('getByProperty', prop, value)

           var thisProp = null
           if(typeof prop !== 'string')       thisProp = prop[0]
           else                               thisProp = prop

           //at this point the only difference here between if and else enclosures is the fact that
           //one is dealing with a root list model while the others are dealing with model objects / array / jsObjects
           if(typeof lm.count !== 'undefined' && lm.count > 0){
               for(var i = 0; i < lm.count; i++)
               {
                   var elem = lm.get(i)
                   if(typeof elem[thisProp] !== 'undefined' && elem[thisProp] !== null)
                   {
                        if((typeof prop === 'string' || prop.length === 1)){
                            if(changeFunc && changeFunc(elem[thisProp]) === value)          return lm.get(i)
                            else if(elem[thisProp] === value)                               return lm.get(i)
                        }
                        else if(typeof prop !== 'string' && prop.length >= 1)
                        {
                            prop.splice(0,1)    //remove one level off of the prop array
                            var res =  getByProperty(elem, prop, value, changeFunc) //we dont pass in the string anymore, we want to search deeper!
                            if(res) //if we found the thing we were looking for within this res (its not null), return it
                                return res
                        }
                   }
               }
           }
           else{
               elem = lm[thisProp]
               if(typeof elem !== 'undefined' && elem !== null)
               {
                   if((typeof prop === 'string' || prop.length === 1) && elem === value)
                   {
                       if(changeFunc){
                            console.log('comparing', value, ' @@@@ ', changeFunc(elem)   )
                       }

                        if(changeFunc && changeFunc(elem) === value)        return lm[thisProp]
                        else if(elem === value)                             return lm[thisProp]
                   }
                   else if(typeof prop !== 'string' && prop.length >= 1)
                   {
                       prop.splice(0,1)                         //remove one level off of the prop array
                       return getByProperty(elem, prop, value, changeFunc) //we dont pass in the string anymore, we want to search deeper!
                   }
               }
           }
       }

       return null
   }


   /*! fn: Clears model with <modelName> \hr */
   function clearModel(modelName){
       var model = getModel(modelName)
       if(model)
           model.clear()
   }


   /*! fn: Recursively prints an object with tabs, tabStr \hr */
   function __printObject(obj, tabStr){
        if(tabStr === null || typeof tabStr === 'undefined'){
            tabStr = ""
            console.log(obj)
        }

        if(obj){
            for(var o in obj){
                var type = typeof obj[o]
                if(type === 'number' || type === 'string')
                    console.log(tabStr + o, '=', type)
                else if(isArray(obj[o]) )
                    console.log(tabStr + 0, '=', 'array of len', obj[o].length)
                else
                {
                    console.log(tabStr + o, '=', obj[o])
                    __printObject(obj[o], tabStr + "\t")
                }
            }
        }
   }


   function removeById(lm, id) {
        if(typeof lm === 'string')
            lm = getModel(lm)

        for(var i = 0; i < lm.count; ++i) {
            var item = lm.get(i)
            if(item.id === id)
                return lm.remove(i)
        }
        return -1
   }
}
