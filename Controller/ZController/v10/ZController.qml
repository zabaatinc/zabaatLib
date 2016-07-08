import QtQuick 2.0
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


    /*! A function to log debug messages. Can be null. We have an internal one by default.  \hr */
    property var externalDebugFunc         : null

    /*! Determines whether or not to print debug messages \hr */
    property bool debugMode                : true

    /*! Alias to object with internal debug message printer function \hr */
    property alias debug                   : _debug

    /*! The models we currently have \hr */
    property alias models                  : priv.models

    /*! Functions to transform specific models && model objects as they arrive. Determined by key. \hr */
    property var modelTransformerFunctions : ({})



    property alias modelCount : priv.modelCount


    QtObject {
        id : _debug
        function debugMsg()
        {
            if(debugMode)
            {
                if(externalDebugFunc)   externalDebugFunc.apply(this,arguments)
                else                    console.log.apply(this,arguments)
            }
        }

        function bypass()
        {
            if(externalDebugFunc)       externalDebugFunc.apply(this,arguments)
            else                        console.log.apply(this,arguments)
        }
    }
    QtObject {
        id : priv
        property var models        : ({})
        property int modelCount    : 0
        property var modelCbs      : ({})         //These are callbacks for the entire models!


        //Checks callbacks for newly received models or model pieces
        //If we got something like "customers/1" , it will check for "customers/1" as well as "customers"

        function checkCallbacks(modelName) {
            var tabStr = arguments.length == 2 ? arguments[1] : ""
            debug.debugMsg(tabStr + "-------------------------------------------------")
            debug.debugMsg(tabStr + "ZController.checkCallbacks(",modelName,")")
            debug.debugMsg(tabStr + "-------------------------------------------------")

            if(modelCbs[modelName])
            {
                var matchStr = modelName
                var id    = ""
                if(modelName.indexOf("/") !== -1)
                {
                    var arr = modelName.split("/")
                    matchStr = arr[0]
                    id       = arr[1]

                    //we should also check if something was wanting the root model here!
                    debug.debugMsg(tabStr + "\tAlso check callbacks for", matchStr)
                    checkCallbacks(matchStr,tabStr + "\t\t")
                }

                debug.debugMsg(tabStr + "\t", modelCbs[modelName].length, "callback(s) found for", modelName)
                for(var i = modelCbs[modelName].length - 1; i > -1; i--)
                {
                    var obj  = modelCbs[modelName][i]._obj;

                    if(obj !== null)
                    {
                        var prop = modelCbs[modelName][i]._prop;

                        if(id == "")
                            obj[prop] = getModel(matchStr)
                        else
                        {
                            for(var j = 0; j < getModel(matchStr).count; j++)
                            {
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

            //also check if we had a query callback available for this model!
//            checkQueryCallbacks(modelName, tabStr + "\t")
            debug.debugMsg(tabStr + "ZController.checkCallbacks(",modelName,")   end")
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
   function addModel(name, model, cb)  {
       if(name === null || typeof name === 'undefined')
           return console.error("no name provided to ZController.addModel", name)

//       console.log('addModel called', name, model)
//       if(!isArray(model) && model.data){
//            model = [model.data]
//       }


//       console.log("____________________", name ,"____________________________")
//       console.log(JSON.stringify(model,null,2))
//       console.log("________________________________________________")

       var tabStr = arguments.length == 3 ? arguments[2] : ""
//       debug.debugMsg(tabStr + "-------------------------------------------------")
//       debug.debugMsg(tabStr + "ZController.addModel(",name,",<model>)")
//       debug.debugMsg(tabStr + "-------------------------------------------------")

       var modelName = name
       var id        = ""

       if(modelTransformerFunctions && modelTransformerFunctions[name]){
           //transform the data cause we got some hotshot model here that needs custom treatment!
           console.log(rootObject, 'modelTransformerFunction(',name,',',model,")")
           modelTransformerFunctions[name](model)
       }



       //Lets first check if the name has '/'
       if(name.indexOf('/') !== -1)
       {
           var arr   = name.split("/")
           modelName = arr[0]
           id        = arr[1]

           //add an id field to this bro!!
           if(!model.id)
               model.id = id
       }

       //only add if we DONT have this model in our models
       if(!priv.models[modelName])
       {
//           console.log('creating new model ', modelName)
           var lm = Functions.getNewObject("ZListModel.qml",null)
           priv.models[modelName] = lm                                 //add this new model to our list
           __appendToModel(modelName,model)


//           console.log(rootObject, "New model made",modelName)

//           if(modelName === "workorders")
//               __printObject(priv.models[modelName])
           priv.checkCallbacks(modelName,tabStr + "\t")        //check if anything has requested this model!
           rootObject.newModelAdded(modelName, ++priv.modelCount); //emit that a new model was added!
       }
       else
       {
//            console.log(modelName,"already exists.gonna append to it instead!")
            debug.debugMsg(modelName,"already exists.gonna append to it instead!")
//           console.log(modelName, "already exists. gonna append to it instead!", JSON.stringify(model))
            __appendToModel(modelName,model)        //otherwise, we append to this already existing model
       }
       debug.debugMsg(tabStr + "ZController.addModel(",modelName,")   end")

//       if(cb && typeof cb === 'function')
//           cb()
//       else
//           console.log(rootObject, 'addModel has no cb')
   }

   /*! fn: Returns whether the passed in param is an array \hr */
   function isArray(obj) {
       return toString.call(obj) === '[object Array]'
   }

   /*! fn: SHOULD be moved to private. do not USE! \hr */
   function __appendToModel(name, data){
       if(data === null) {
           console.log('ZController --- data is null. nothing to be done')
           return
       }

//       if(data.id !== null && typeof data.id !== 'undefined')    console.log('ZCONTROLLER - append to model',name, 'with id : ', data.id)

       var tabStr = arguments.length == 3 ? arguments[2] : ""
//       debug.debugMsg(tabStr + "-------------------------------------------------")
//       debug.debugMsg(tabStr + "ZController.appendToModel(",name,",<data>)")
//       debug.debugMsg(tabStr + "-------------------------------------------------")

       //Let's see if we have this model
       if(priv.models[name])
       {
           if(isArray(data)){  //check if array
//               console.log(rootObject, "__appendToModel", "isArray", name)
                for(var i = 0; i < data.length; i++) {
                    __addData(name,data[i],i)
                }
           }
           else {
//               if(!data) {
//                   console.log("BAD DATA @", name)
//                   console.log("_____________________________________________")
//                   console.trace()
//                   console.log("_____________________________________________")
//               }
//               console.log(rootObject, 'appending data object to', name , priv.models[name].count)
                __addData(name,data,'root')
//               if(name === 'otherUsersOnPage'){
//                   var test = priv.models[name].get(0).usernames
//                   for(var t = 0 ; t < test.count; t++) {
//                       console.log(t, test.get(t).username)
//                   }
//               }

           }
       }
       else {
//           console.log(name,"doesnt exist.gonna add it instead!")
           addModel(name, data)     //let's add this model if we don't have it!
       }
       debug.debugMsg(tabStr + "ZController.appendToModel(",name,")   end")
   }

    /*! fn: SHOULD be moved to private. do not USE! \hr */
   function __addData(name, data, it, tabStr)
   {
       if(!tabStr) tabStr = ""

       if(data.id !== null && typeof data.id !== 'undefined'){  //this means that we got an object to append not an array of objects!!! hooray.
           var modelPtr = priv.models[name]
           var found    = false
//           console.log(tabStr + "\tZController.addModel -- model",name,"found. We wish to add id:",data.id,"to it...")
           debug.debugMsg(tabStr + "\tZController.addModel -- model",name,"found. We wish to add id:",data.id,"to it...")
//           console.log(tabStr + "\tZController.addModel -- model",name,"found. We wish to add id:",data.id,"to it...")

           //iterate over this model's list elements and change them according to the data?? or add to them according to the data!!
           for(var i = 0; i < modelPtr.count; i++)
           {
               if( modelPtr.get(i).id !== null &&  modelPtr.get(i).id === data.id) {
                   debug.debugMsg(tabStr + "\tZController.addModel", name, " -- id",data.id,"already exists. Modifying it...")
                   var le = modelPtr.get(i)

                   for(var d in data)
                   {
                       if(d !== 'id') {
                           if(typeof data[d] !== 'object'){
                               if(le[d] !== data[d])
                                    le[d] = data[d]
                           }
                           else if(le[d] === null || typeof le[d] === 'undefined'){
//                               console.log(rootObject, 'making new listmodel at', d)
                               le[d] = Functions.getNewObject('ZListModel.qml',le)
//                               console.log("FAT APPEND", data[d])

                               if(data[d] !== null)       le[d].append(data[d])
                               else                       le[d].append({})  //TODO DERP, investigate this change!!

                           }
                           else
                           {
                               debug.debugMsg("DEEP COPY", le[d], data[d], d, d, "", le)
                               __deepCopy(le[d],data[d],d,d , "", le)
                               debug.debugMsg("===================== deepCopy finished ========================")
                           }
                       }
                   }

                   found = true
                   break
               }
           }

           if(!found) {
               debug.debugMsg(tabStr + "\tZController.addModel -- Adding to existing list model...",name, data.id, "was not found. Adding it")
//               console.log(tabStr + "\tZController.addModel -- Adding to existing list model...",name, data.id, "was not found. Adding it")
               modelPtr.append(data)
//               if(name === 'items')
//                  console.log('HEH appending this shit', priv.models[name].get(0), JSON.stringify(priv.models[name].get(0),null,2) )

           }

           //check if anything has requested this model!
//           priv.checkCallbacks(name,tabStr + "\t")
       }


   }

   //You have to do a SET EQUALS TO operation on a jsObject to get it to show updates in a model! dynamic linkages and such!
   //This is because if you try to change inner things inside a jsObject, models won't let you do it by using get(0).propertyname = somevalue
   //TODO, BRO PAL. If this gives you binding issues, perhaps investigate line 305 which is commented out.
   function __deepCopy(obj1, obj2, lvl1, lvl2, tabStr, prev)
   {
       if(!tabStr)
           tabStr = ""

       debug.debugMsg(tabStr,'deepCopy(' + lvl1, ',' + lvl2 + ')')

       if(typeof obj2 !== 'object')
       {
//           console.log(tabStr+ "\t", lvl1,'is no object. Updating')
           debug.debugMsg(tabStr+ "\t", lvl1,'is no object. Updating')

           //do equality check
           if(obj1 !== obj2)
               obj1 = obj2

           return
       }

       //if we got an update such that obj2 is now empty, we should do that. //TODO, check the else.
       if(isArray(obj2) && obj2.length === 0){
           if(obj1.toString().toLowerCase().indexOf('model') !== -1)             obj1.clear()
           else                                                                  obj1 = obj2
       }
       else{
           for(var o in obj2) {
               debug.debugMsg(tabStr + "\t",'examiming',lvl2,'/',o)

               if(obj2[o] !== null && typeof obj2[o] !== 'undefined' && obj2[o].hasOwnProperty('id')) {
                   debug.debugMsg(tabStr + "\t\tFinding", lvl2 + "/" + obj2[o].id)
                   var elem = getById(obj1, obj2[o].id)  //this is TE 0
                   if(elem !== null) {
                       debug.debugMsg(tabStr + "\t\t\tFound")
                       for(var p in obj2[o]) {
                           /*if(elem[p].toString().indexOf('ModelObject') === -1 && !isArray(elem[p]) && typeof elem[p] === 'object'){

    //                           console.log(p, 'is a normal Js Object')
    //                           console.log(JSON.stringify(elem[p],null,2))

                               if(elem[p])
                                    elem[p] = obj2[o][p]

                           }
                           else */if(typeof obj2[o][p] !== 'object')
                           {
    //                           console.log(tabStr + "\t\t\t\t@@", lvl1,'/',obj2[o].id,'/',p,'=',obj2[o][p])
                               debug.debugMsg(tabStr + "\t\t\t\t@@", lvl1,'/',obj2[o].id,'/',p,'=',obj2[o][p])

                               //do equality check
                               if(elem[p] !== obj2[o][p])      elem[p] = obj2[o][p]
    //                           else                            console.log('skipping', lvl1 +'/'+obj2[o].id, 'since value is same')
                           }
                           else
                           {
    //                           console.log(tabStr + "\t\t\t\t", 'calling deepCpy on', lvl1 + '/' + obj2[o].id + '/' + p)
                               debug.debugMsg(tabStr + "\t\t\t\t", 'calling deepCpy on', lvl1 + '/' + obj2[o].id + '/' + p)
                               var ret = __deepCopy(elem[p], obj2[o][p], lvl1 + '/' + obj2[o].id + '/' + p, lvl2 + '/' + o + '/' + p, tabStr + "\t", elem)
                           }
                       }
                   }
                   else              {
    //                   console.log(tabStr + "\t\t\tNot Found")
                       debug.debugMsg(tabStr + "\t\t\tNot Found")
                       if(!obj1.hasOwnProperty('count')) //if the model doesn't even exist!!
                       {
                           debug.debugMsg(tabStr + '\t\t\t\t', lvl1,'=', JSON.stringify(obj1,null,2))
                           debug.debugMsg(tabStr + "\t\t\t\tno model found at",lvl1,"...creating and copying",lvl1,"into it")

                           //console.log(JSON.stringify(obj1,null,2))
                           obj1 = Functions.getNewObject("ZListModel.qml",null)
                           obj1.append(obj2)
                           //console.log(JSON.stringify(obj1,null,2))

                           debug.debugMsg(tabStr + "\t\t\t\t\t", '===== end =====')
                           return
                       }
                       else
                       {
                            debug.debugMsg(tabStr + "\t\t\t\tappending",obj2[o].id,'to',lvl1)
                            obj1.append(obj2[o])
                       }
                   }
               }
               else {       //overwrite stuffs!
                    debug.debugMsg(tabStr+ "\t\t\t",lvl2 + '/' + o, 'has no id.')
                    if(obj1.hasOwnProperty('count'))
                    {
    //                    console.log(tabStr + "\t\t\t\t\t", 'Overwriting model at', lvl1, 'with', lvl2)
                        debug.debugMsg(tabStr + "\t\t\t\t\t", 'Overwriting model at', lvl1, 'with', lvl2)
                        debug.debugMsg(tabStr + "\t\t\t\t\t", '===== end =====')
                        obj1.clear()
                        obj1.append(obj2)
                        return
                    }
                    else if(obj1.toString().indexOf('ModelObject') === -1 && !isArray(obj1) && typeof obj1 === 'object')
                    {
                        if(prev && prev[lvl1]){

                            //one level
    //                        for(o in obj2){
    //                            if(obj2[o] !==)
    //                        }

                            prev[lvl1] = obj2
                            return
                        }
    //                    console.log(rootObject, "PUFF JS OBJECTS SURVIVED", lvl1)
                        return
                    }
                    else
                    {
    //                    console.log(tabStr + "\t\t\t\t\t", 'Setting', lvl1,'/',o,'=',obj2[o])
                        debug.debugMsg(tabStr + "\t\t\t\t\t", 'Setting', lvl1,'/',o,'=',obj2[o])

                        //equality check
                        if(obj1[o] !== obj2[o])            obj1[o] = obj2[o]
    //                    else                               console.log(lvl1 + '/' + o , 'is the same, so skipping it')
                    }
               }

           }
       }
   }


   /*! fn: get item by <id> if it exists in model <lm>. lm can be a string name or a model. \hr */
   function getById(lm, id)
   {
       return getByProperty(lm, 'id', id)
   }

   /*! fn: if prop is an array, we will deal with it differently! We will recurse thru to find the item!
   valid examples of using this function are: __addData. BE WARNED THAT THIS MAY NOT HAVE THE BEST PERFORMANCE FOR HUGE LISTS.
                                                         IN THE WORST CASE IT WILL DO, n * prop.length comparisons, where n is the number of items in the model!
    (1)   getByProperty('workOrders','jobNumber',26400)
    (2)   getByProperty('vehicles',['details','stockNumber'],UC-770) \hr */
   function getByProperty(lm, prop, value, changeFunc){
       if(typeof lm === 'string')
            lm = getModel(lm)

       if(lm !== null && typeof lm !== 'undefined')
       {
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

//                            if(changeFunc){
//                                console.log('comparing', value, ' @@@@ ',  changeFunc(elem[thisProp])   )
//                            }
//                            console.log("COMPARING", elem[thisProp], value)

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
