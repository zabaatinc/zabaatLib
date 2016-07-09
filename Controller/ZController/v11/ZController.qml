import QtQuick 2.5
//Contains dynamically generated list models at runtime !!

/*!
   \brief Class that handles models quite well. Is used in XhrController and SocketIOController.
   \inqmlmodule Zabaat.Controller 1.1 \hr
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
    Item {
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


        property Component modelFactory : Component  {
            id: modelFactory
            ListModel{
                dynamicRoles: true
            }
        }

        WorkerScript {
            id : worker
            source    : "HappyWorker.js"
            onMessage : if(messageObject && messageObject.type) {
                switch(messageObject.type) {
                    case 'add' :
                        var time  = messageObject.time;
                        var name  = messageObject.name;
                        if(messageObject.isNew) {
                            priv.checkCallbacks(name)        //check if anything has requested this model!
                            rootObject.newModelAdded(name, ++priv.modelCount); //emit that a new model was added!
                            console.log("op on" , name, 'resulted in' , messageObject.count , 'elems & took', time , "ms")
                        }
                        if(queue.length > 0){
                            var obj = queue[0]
                            queue.splice(0,1);
//                            if(obj.name === 'user'){
//                                var current = getById('user', obj.data.id)
//                                console.log("--------------")
//                                console.log("current:", JSON.stringify(current,null,2))
//                                console.log("new:", obj.data)
//                                for(var d in obj.data){
//                                    console.log(d, JSON.stringify(obj.data[d]))
//                                }
//                                console.log("--------------")
//                            }
                            console.log("@@@@@@@@@@@@@@@@@@@@@@ QUEUE REQUEST ")
                            worker.sendMessage(obj);
                        }

                        break;
                }
            }

            property var queue : []


        }


        Item {
            id : container
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
        else {
            var o = { _obj : obj , _prop : prop }
            if(priv.modelCbs[name])       priv.modelCbs[name].push(o)
            else                          priv.modelCbs[name] = [o]


            if(!dontAutoRequest)
                sendGetModelRequest(name)       //TODO , see if we already have a request!
            return null
        }
    }


    /*! fn: Returns whether the passed in param is an array \hr */
    function isArray(obj) {
        return toString.call(obj) === '[object Array]'
    }

   /*! fn: Adds model with <name> and data <model> .
        Hands off actually adding the model to worker.
        Will add new model if it doesn't exist. Otherwise, will insert/update an existing model \hr */
   function addModel(name, data, cb)  {
       if(name === null || typeof name === 'undefined')
           return console.error("no name provided to ZController.addModel", name)

       var tabStr    = arguments.length == 3 ? arguments[2] : ""
       var modelName = name
       var id        = ""

       if(modelTransformerFunctions && modelTransformerFunctions[name]){
           //transform the data cause we got some hotshot model here that needs custom treatment!
           console.log(rootObject, 'modelTransformerFunction(',name,',',data,")")
           modelTransformerFunctions[name](data)
       }


       //Lets first check if the name has '/' . correct the name and figure out id if we haven't provided one.
       //this is very deprecated but just here in case we need it.
       if(name.indexOf('/') !== -1)  {
           var arr   = name.split("/")
           modelName = arr[0]
           id        = arr[1]

           //add an id field to this bro!!
           if(data.id === null || typeof data.id === 'undefined')
               data.id = id
       }

       //get lm or get a new one if we don't have it
       var isNew = false;
       var lm = priv.models[modelName]

       //doesnt exist, create a new one
       if(!lm) {
           isNew = true;
           lm = modelFactory.createObject(container);
           lm.objectName = modelName
           priv.models[modelName] = lm                                 //add this new model to our list
       }

       //send it off to the worker to add it!
       var obj = { type  : "add",
           lm     : lm,
           name   : modelName,
           data   : data,
           isNew  : isNew }

       if(worker.queue.length === 0) {
            worker.sendMessage(obj)
       }
       else
           worker.queue.push(obj);

   }


   /*! fn: get item by <id> if it exists in model <lm>. lm can be a string name or a model. \hr */
   function getById(lm, id)  {
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
