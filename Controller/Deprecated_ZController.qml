import QtQuick 2.0
import "Functions.js" as Functions
import Zabaat.Misc.Debug 1.0
//Contains dynamically generated list models at runtime !!

Item
{
    id : rootObject
    signal sendUpdateRequest(string mapStr, string value)
    signal sendGetModelRequest(string modelName)

    property var externalDebugFunc : null
    property bool debugMode: true
    property alias debug : _debug

    QtObject
    {
        id : _debug
        function debugMsg()
        {
            if(debugMode)
            {
                var str = ""
                for(var i = 0; i < arguments.length; i++)
                    str += arguments[i] + " "

                if(externalDebugFunc)                    externalDebugFunc(str)
                else                                     console.log(str)
            }
        }

        function bypass()
        {
            if(externalDebugFunc)
            {
                var str = ""
                for(var i = 0; i < arguments.length; i++)
                    str += arguments[i] + " "
                externalDebugFunc(str)
            }
        }
    }

    //Retrieves a value from a model based on a server string (e.g "customers", "1/firstName")
    function get(model, mapStr)
    {
        var mdl = getModel(model)
        if(mdl)
        {
            if(mdl.map[mapStr])
                return mdl.map[mapStr].get()
        }
        return "N/A"
    }

    //Sets a value from a model based on a server string ( will also do the send Request! e.g "customers", "1/firstName", "derpMan")
    //That is from within the bindy located at map[mapStr].set function
    function set(model, mapStr, value, dontSend)
    {
        var mdl = getModel(model)
        if(mdl)
        {
            debug.debugMsg(model,"found...looking for", mapStr,"now")
            if(mdl.map[mapStr])
            {
                mdl.map[mapStr].set(value, dontSend)
                debug.debugMsg(model + mapStr, "is now", value)
                return true
            }
        }
        return false
    }

    function removeFromMap(modelName, str)  {   priv.removeFromMap(modelName,str)  }

    Item
    {
        id : priv
        property var models        : []
        property var modelCbs      : []         //These are callbacks for the entire models!
//        property var modelQueryCbs : []         //These are callbacks for subsets of models (queries such as customers, 1, vehicles) using getModelQuery function

        function createMap(modelName, lm, obj, mapStr, memMapStr)
        {
            var lenProp = obj.count ? "count" : "length"
            //console.log(mapStr)

            for(var i = 0; i < obj[lenProp]; ++i)
            {
                var le = obj.count ? obj.get(i) : obj[i]

                for(var k in le)
                {
                    var type = Object.prototype.toString.call(le[k] )
                    //console.log(type)
                    if((type === '[object Number]' || type === '[object String]') && k !== 'id' && k != 'objectName')
                    {
                        var theKey = le.id ?  mapStr + le.id + "/" + k : mapStr + i + "/" + k
                        var bindy  = Functions.getNewObject("Bindy.qml",null)

                        bindy.modelName = modelName
                        bindy.ptr  = le
                        bindy.prop = k
                        bindy.serverLocation = theKey
                        bindy.sendRequestFunction = function(mapStr, value) { sendUpdateRequest(mapStr,value) }

                        lm.map[theKey] = bindy
                        lm.memoryMap[memMapStr + i + "/" + k] = lm.map[theKey]
                    }
                    else if(type === '[object Object]')
                    {
                        if(le.id)      createMap(modelName, lm, le[k], mapStr + le.id + "/" + k + "/"  , memMapStr + i + "/" + k + "/" )
                        else           createMap(modelName,lm, le[k], mapStr + i + "/" + k + "/"      , memMapStr + i + "/" + k + "/" )
                    }
                }
            }
        }

        //Checks callbacks for newly received models or model pieces
        //If we got something like "customers/1" , it will check for "customers/1" as well as "customers"
        function checkCallbacks(modelName)
        {
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

                    if(obj != null)
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

                modelCbs.splice(modelName,1)
            }

            //also check if we had a query callback available for this model!
//            checkQueryCallbacks(modelName, tabStr + "\t")
            debug.debugMsg(tabStr + "ZController.checkCallbacks(",modelName,")   end")
        }


        //Removes some entries from the model using Ids
        function removeFromMapUsingId(modelName, ids)
        {
            if(models[modelName])
            {
                var modelPtr = models[modelName]
                var markForDeletionArr = []

                //let's see if we have these inices
                if(typeof ids === 'string' || typeof ids === 'number')
                {
                    for(var i = 0; i < modelPtr.count; ++i)
                    {
                        var arr = modelPtr.get(i).split('/')
                        var mId = arr[1]


                        if(mId && mId == ids)
                            markForDeletionArr[i] = true
                    }
                }

                else
                {
                    for(i in ids)
                    {
                        for(var j = 0 ; j < modelPtr.count; j++)
                        {
                            arr = modelPtr.get(i).split('/')
                            mId = arr[1]

                            if(mId && mId == ids[i])
                                markForDeletionArr[j] = true
                        }
                    }
                }


                genericDelete(modelPtr, markForDeletionArr)
            }
        }

        //Do not call this method!! I guess it should be in priv!
        function genericDelete(modelPtr, markForDeletionArr)
        {
            //Now remove the marked indices from the map in modelPtr
            for(var m in markForDeletionArr)
                delete modelPtr.map[m]

            //Flush the mark for deletion array
            markForDeletionArr = []

            //Let's find the indices of items that need removed from memoryMap in modelPtr
            //This can be found by looking at the value of the items within. If its null or if it's dying property is set to true,
            //We mark it for deletion
            for(m in modelPtr.memoryMap)
            {
                if(modelPtr.memoryMap[m] == null || modelPtr.memoryMap[m].dying)  //This needs to be deleted!
                {
                    markForDeletionArr[m] = true

                    //lets remove this from the actual listModel as well!
                    var arr = m.split("/")
                    if(arr.length > 0)
                    {
                        //If it contained slashes, that means that we are not deleting the root level indices
                        //but rather the properties within

                        //Start at the rootLevel and work your way down to the property being deleted
                        var obj = modelPtr
                        for(var p = 0; p < arr.length - 1; ++p)
                        {
                            var type = typeof arr[p]
                            if(typeof obj.get === 'function')    obj = obj.get(arr[p])
                            else                                 obj = obj[arr[p]]
                        }

                        //Delete this property, setting to null or undefined doesn't update the view cause it doesn't know
                        //what to do!
                        obj[arr[p]] = "derpifined"
                    }
                }
            }

            for(m in markForDeletionArr)
                delete modelPtr.memoryMap[m]


            //This function will remove all uneeded entries!!
            verifyModel(modelPtr)
        }

        function removeFromMap(modelName, str)
        {
            if(models[modelName])
            {
                var modelPtr = models[modelName]        //this is the ptr to our model. Just for convenience, we use modelPtr
                var markForDeletionArr = []             //we will keep re-using this array. It stores the indices we need to delete in other arrays


                //Let's find the indices of items that need removed from map in modelPtr
                for(var m in modelPtr.map)
                {
                    if(m.indexOf(str) != -1)
                    {
                        modelPtr.map[m].dying = true
                        modelPtr.map[m].destroy()
                        modelPtr.map[m] = null

                        markForDeletionArr[m] = true
                    }
                }
                genericDelete(modelPtr, markForDeletionArr)

                debug.debugMsg("ZController -- removeFromMap(", modelName, "," , str , ")" , "finished")
            }
        }


        //Serves as cleanup
        function verifyModel(model)
        {
            var lenVar  = model.count ? "count" : "length"

            for(var j = model[lenVar] - 1; j > -1; --j)
            {
                var val = model.count ? model.get(j) : model[j]

                var count = 0
                for(var p in val)
                {
                    if(val[p])
                    {
                        var type = Object.prototype.toString.call(val[p])

                        if(type == '[object String]')
                        {
                            if(p != "id" && p != "objectName" && val[p] != "derpifined")
                            {
                                count++
                                break
                            }
                        }
                        else
                            verifyModel(val[p])
                    }
                }

                if(count == 0)
                    model.remove(j)

            }
        }
    }

    //Flat get model request. Use this if you're happy with a null return forever!
    function getModel(name)  {  if(priv.models[name])  return priv.models[name];  return null  }

    //Get model when it arrives. This will auto fill your model when it gets here locally. If you set the last param to true, we wont autorequest the server
    //For this model
    function getModelWhenItArrives(name, obj, prop, dontAutoRequest)
    {
        if(priv.models[name])   return priv.models[name]
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


   //Smart enough to know that if given customer/4, it will add 4 to customers model
   //This can occur if we have a callback that wanted customers/4 (using ZTextBox_Bindable) or a query of customers/4
   function addModel(name, model)
   {
       var tabStr = arguments.length == 3 ? arguments[2] : ""
       debug.debugMsg(tabStr + "-------------------------------------------------")
       debug.debugMsg(tabStr + "ZController.addModel(",name,",<model>)")
       debug.debugMsg(tabStr + "-------------------------------------------------")

       var modelName = name
       var id = ""

       //Lets first check if the name has '/'
       if(name.indexOf('/') != -1)
       {
           var arr   = name.split("/")
           modelName = arr[0]
           id        = arr[1]
       }

       //only add if we DONT have this model in our models
       if(!priv.models[modelName])
       {
           //console.log(modelName,"doesn't exist. Adding now")

            var lm = Functions.getNewObject("ZListModel.qml",null)
            lm.append(model)
            priv.createMap(modelName,lm,lm,"","", tabStr + "\t")        //creates a serverMap (map) and a memoryMap (memory to server map)
            priv.models[modelName] = lm                                 //add this new model to our list

            priv.checkCallbacks(modelName,tabStr + "\t")        //check if anything has requested this model!
       }
       else
       {
            debug.debugMsg(modelName,"already exists.gonna append to it instead!")
            appendToModel(modelName,model)        //otherwise, we append to this already existing model
       }
       debug.debugMsg(tabStr + "ZController.addModel(",modelName,")   end")
   }

   function appendToModel(name, data)
   {
       var tabStr = arguments.length == 3 ? arguments[2] : ""
//       debug.debugMsg(tabStr + "-------------------------------------------------")
//       debug.debugMsg(tabStr + "ZController.appendToModel(",name,",<data>)")
//       debug.debugMsg(tabStr + "-------------------------------------------------")

       //Let's see if we have this model
       if(priv.models[name])
       {
           if(data.id)  //this means that we got an object to append not an array of objects!!! hooray.
           {
               var modelPtr = priv.models[name]
               var found = false
               debug.debugMsg(tabStr + "\tZController.addModel -- model",name,"found. We wish to add id:",data.id,"to it...")

               //iterate over this model's list elements and change them according to the data?? or add to them according to the data!!
               for(var i = 0; i < priv.models[name].count; i++)
               {
                   if( priv.models[name].get(i).id &&  priv.models[name].get(i).id == data.id)
                   {
                       debug.debugMsg(tabStr + "\tZController.addModel -- id",data.id,"already exists. Modifying it...")

//                       console.log("running deepCopy")
                       var le = priv.models[name].get(i)


                       for(var d in data)
                       {
                           if(d != 'id')
                           {
                               if(typeof data[d] !== 'object')
                                   le[d] = data[d]
                               else if(le[d] == null || typeof le[d] === 'undefined')
                               {
                                   le[d] = Functions.getNewObject('ZListModel.qml',null)
                                   le[d].append(data[d])
                               }
                               else
                               {
                                   deepCopy2(le[d],data[d],d,d)
                                   debug.bypass("===================== deepCopy finished ========================")
                               }
                           }
                       }

                       found = true
                       break
                   }
               }

               if(!found)
               {
                   debug.debugMsg(tabStr + "\tZController.addModel -- Adding to existing list model...",name, data.id, "was not found. Adding it")
                   priv.models[name].append(data)
               }

               //we need to now refresh our map!
               debug.debugMsg(tabStr + "\tZController.addModel -- Creating map entries for added element...")
               priv.createMap(name, priv.models[name],priv.models[name],"","", tabStr + "\t")

               //check if anything has requested this model!
               priv.checkCallbacks(name,tabStr + "\t")

           }
           else //we got a list instead!! Let's append each object bropal!!
           {
               debug.debugMsg('data has no id!')

               for(var x in data)
                   appendToModel(name, data[x])
           }
       }
       else
       {
//           console.log(name,"doesnt exist.gonna add it instead!")
           addModel(name, data)     //let's add this model if we don't have it!
       }

       debug.debugMsg(tabStr + "ZController.appendToModel(",name,")   end")

   }



   function deepCopy2(obj1, obj2, lvl1, lvl2, tabStr)
   {
       if(!tabStr)       tabStr = ""

       debug.bypass(tabStr,'deepCopy(' + lvl1, ',' + lvl2 + ')')

       if(typeof obj2 !== 'object')
       {
           debug.bypass(tabStr+ "\t", lvl1,'is no object. Updating')
           obj1 = obj2
           return
       }



       for(var o in obj2)
       {
           debug.bypass(tabStr + "\t",'examiming',lvl2,'/',o)

           if(obj2[o].hasOwnProperty('id'))
           {
               debug.bypass(tabStr + "\t\tFinding", lvl2 + "/" + obj2[o].id)
               var elem = getById(obj1, obj2[o].id)  //this is TE 0
               if(elem != null)
               {
                   debug.bypass(tabStr + "\t\t\tFound")
                   for(var p in obj2[o])
                   {
                       if(typeof obj2[o][p] !== 'object')
                       {
                           //console.log(lvl1,'/',obj2[o].id,'/',p,'=',obj2[o][p])
                           debug.bypass(tabStr + "\t\t\t\t@@", lvl1,'/',obj2[o].id,'/',p,'=',obj2[o][p])
                           elem[p] = obj2[o][p]
                       }
                       else
                       {
                           //console.log('calling deepCpy on', lvl1 + '/' + obj2[o].id + '/' + p)
                           debug.bypass(tabStr + "\t\t\t\t", 'calling deepCpy on', lvl1 + '/' + obj2[o].id + '/' + p)
                           deepCopy2(elem[p], obj2[o][p], lvl1 + '/' + obj2[o].id + '/' + p, lvl2 + '/' + o + '/' + p, tabStr + "\t")
                       }
                   }

               }
               else
               {
                   debug.bypass(tabStr + "\t\t\tNot Found")
                   if(!obj1.hasOwnProperty('count')) //if the model doesn't even exist!!
                   {
                       debug.bypass(tabStr + '\t\t\t\t', lvl1,'=', JSON.stringify(obj1,null,2))
                       debug.bypass(tabStr + "\t\t\t\tno model found at",lvl1,"...creating and copying",lvl1,"into it")

                       //console.log(JSON.stringify(obj1,null,2))
                       obj1 = Functions.getNewObject("ZListModel.qml",null)
                       obj1.append(obj2)
                       //console.log(JSON.stringify(obj1,null,2))

                       debug.bypass(tabStr + "\t\t\t\t\t", '===== end =====')
                       return
                   }
                   else
                   {
                        debug.bypass(tabStr + "\t\t\t\tappending",obj2[o].id,'to',lvl1)
                        obj1.append(obj2[o])
                   }
               }
           }
           else //overwrite stuffs!
           {
                debug.bypass(tabStr+ "\t\t\t",lvl2 + '/' + o, 'has no id.')
                if(obj1.hasOwnProperty('count'))
                {
                    debug.bypass(tabStr + "\t\t\t\t\t", 'Overwriting model at', lvl1, 'with', lvl2)
                    debug.bypass(tabStr + "\t\t\t\t\t", '===== end =====')
                    obj1.clear()
                    obj1.append(obj2)
                    return
                }
                else
                {
                    debug.bypass(tabStr + "\t\t\t\t\t", 'Setting', lvl1,'/',o,'=',obj2[o])
                    obj1[o] = obj2[o]
                }
           }

       }

   }




   //Copy obj1 into obj2
   function deepCopy(obj1, obj2, lvl1, lvl2)
   {
       if(!lvl1)           lvl1 = ""
       if(!lvl2)           lvl2 = ""

       debug.bypass('comparing', lvl1,'and',lvl2)

       for(var d in obj2)
       {
           if(obj1[d] != null && typeof obj1[d] !== 'undefined' && obj1[d].hasOwnProperty('count')) //is a model
           {
               var type = Object.prototype.toString.call(obj2[d])
               debug.bypass(type)

               for(var i in obj2[d])
               {
                   if(obj2[d][i].hasOwnProperty('id'))
                   {
                       var element = getById(obj1[d], obj2[d][i].id)
                       if(element != null)   //if this thing has an id, we can hope to update it. Otherwise we are gonna just append.
                       {
                           for(var x in obj2[d][i])
                           {
                               if(element[x].hasOwnProperty('count')) //is a model
                               {
                                   debug.bypass(d + "." + obj2[d][i].id + "." + x + " is a model. DeepCpy again.") //,JSON.stringify(obj2[d][i],null,2))
                                   var obiwan = {}
                                   obiwan[x] = obj2[d][i][x]
                                   //obiwan = obj2[d][i][x]

                                   deepCopy(element, obiwan, lvl1 + '.' + d + '.' + x , lvl2 + '.' + d  + '.' + i + '.' + x)
                                   break
                               }
                               else
                               {
                                   //debug.bypass("Setting obj1." + d + "." + obj2[d][i].id  + "." + x + "=", obj2[d][i][x])
                                   element[x] = obj2[d][i][x]
                               }
                           }
                       }
                       else
                       {
                           //doesnt exist, make one!
                           obj1[d].append(obj2[d][i])
                       }
                   }
                   else
                   {
                       debug.bypass("obj2." + d + "." + i , " has no id. Wiping stuffs bro!")
                       obj1[d].clear()
                       obj1[d].append(obj2[d])
                       break
                   }
                }
           }
           else
           {
               //this is for standard objects!!
               debug.bypass(d,"is not a model//", typeof obj1, "//",  typeof obj1[d])

               if(typeof obj2[d] !== 'object')
                   obj1[d] = obj2[d]
               else //obj2[d] is an object or an array!
               {
                   if(obj1[d] == null || typeof obj1[d] === 'undefined')
                   {
                       console.log('creating new embedded model at',lvl1 + "." + d)
                       debug.bypass('creating new embedded model at',lvl1 + "." + d)
                       obj1[d] = Functions.getNewObject("ZListModel.qml",null)
                       //deepCopy(obj1[d],obj2[d], lvl1 + "." + d, lvl2 + '.' + d)

                       obj1[d].append(obj2[d])
                   }
                   else
                   {
                       debug.bypass("CALLING DEEP COPY ON the thinger!")
                       deepCopy(obj1[d], obj2[d], lvl1 + '.' + d, lvl2 + '.' + d)
                   }
               }
           }
       }
   }


   function getById(lm, id)
   {
       if(typeof lm !== 'undefined' &&  lm.hasOwnProperty('count') && lm.count > 0)
       {
           debug.debugMsg('getbyId', id)
           for(var i = 0; i < lm.count; i++)
           {
               var elem = lm.get(i)
               if(typeof elem.id !== 'undefined' && typeof elem.id !== null && elem.id == id)
                   return lm.get(i)
           }
       }
       return null
   }



    Item
    {
        id : deprecated

        //Smart enough to know that if given customer/4, it will add 4 to customers model
        function addModel_deprecated(name, model)
        {
           var tabStr = arguments.length == 3 ? arguments[2] : ""
           debug.debugMsg(tabStr + "-------------------------------------------------")
           debug.debugMsg(tabStr + "ZController.addModel(",name,",<model>)")
           debug.debugMsg(tabStr + "-------------------------------------------------")

            //it seems like we will always get root level model from this!!
           if(name.indexOf('/') == -1)  //we got a root level model
           {
               var lm = Functions.getNewObject("ZListModel.qml",null)
               lm.append(model)
               priv.createMap(name,lm,lm,"","", tabStr + "\t")      //creates a serverMap (map) and a memoryMap (memory to server map)
               priv.models[name] = lm               //add this new model to our list
           }
           else
           {
               //NOTE : we'll never get a length greater than 2 (meaning customers/1) according to Sir BRETT TunaWarrior Overlord
               var arr = name.split("/")
               var modelName = arr[0]
               var id        = arr[1]

               if( priv.models[modelName])
               {
                   var modelPtr = priv.models[modelName]

                   debug.debugMsg(tabStr + "\tZController.addModel -- model",modelName,"found. We wish to add id:",id,"to it...")
                   var found = false

                   for(var i = 0; i < priv.models[modelName].count; i++)
                   {
                       if( priv.models[modelName].get(i).id &&  priv.models[modelName].get(i).id == id)
                       {
                           debug.debugMsg(tabStr + "\tZController.addModel -- id",id,"already exists. Deleting it first...")
                           priv.removeFromMap(modelName, modelName + "/" + id,  tabStr + "\t")

                           debug.debugMsg(tabStr + "\tZController.addModel -- Adding to existing list model...")


                           modelPtr.set(i,model)
                           var le = modelPtr.get(i)

                           //we need to now refresh our map!
                           priv.createMap(modelName, priv.models[modelName],model,"","", tabStr + "\t")

                           found = true
                           break
                       }
                   }

                   if(!found)
                   {
                       debug.debugMsg(tabStr + "\tZController.addModel -- Adding to existing list model...",modelName)
                       priv.models[modelName].append(model)

                       //we need to now refresh our map!
                       debug.debugMsg(tabStr + "\tZController.addModel -- Creating map entries for added element...")

    //                   priv.models[modelName].map       = []
    //                   priv.models[modelName].memoryMap = []

                       priv.createMap(modelName, priv.models[modelName],priv.models[modelName],"","", tabStr + "\t")
                   }
               }
               else
               {
                   lm = Functions.getNewObject("ZListModel.qml",null)
                   lm.append(model)
                   priv.createMap(modelName,lm,lm,"","", tabStr + "\t")        //creates a serverMap (map) and a memoryMap (memory to server map)
                   priv.models[modelName] = lm                                //add this new model to our list
                   debug.debugMsg(tabStr + "\tAdding to new model",modelName)
               }

           }
           priv.checkCallbacks(name,tabStr + "\t")        //check if anything has requested this model!
           debug.debugMsg(tabStr + "ZController.addModel(",name,")   end")
        }

        //Get childModel that belongs to parentId in parentModel. This will generate a new model that is NOT connected
        //to the original child model. Perhaps add something like that. Or we can just wait for server to respond back and
        //we will auto update the root child model.
        function getModelQuery(parentModel, parentId, childModel, callingObj, callingObjPropName, dontCallback)
        {
            var tabStr = arguments.length == 3 ? arguments[2] : ""
            debug.debugMsg(tabStr + "-------------------------------------------------")
            debug.debugMsg(tabStr + "ZController.getModelQuery(",parentModel,",",parentId,",",childModel,")")
            debug.debugMsg(tabStr + "-------------------------------------------------")

            //here we search the childModel for parentId
            var parentField = parentModel.substr(0,parentModel.length - 1)
            debug.debugMsg(parentField)

            var cModel   = getModel(childModel)
            var retModel = []

            if(cModel)
            {
                var lm = Functions.getNewObject("ZListModel.qml",null)

                for(var i = 0; i < cModel.count; i++)
                {
                    var c = cModel[i]
                    if(c[parentField] && c[parentField] == parentId)
                    {
                        debug.debugMsg(tabStr + "\t", c.id, "belongs to", parentField, parentId)
                        retModel.push(c)
                    }
                }
                lm.append(retModel)                                     //Create the model
                priv.createMap(childModel,lm,lm,"","", tabStr + "\t")   //add map to this model.
                return lm
            }

            if(!dontCallback)
            {
                var o = { _obj : callingObj , _prop : callingObjPropName, _parentModel : parentModel, _parentId : parentId }
                if(priv.modelCbs[childModel])       priv.modelQueryCbs[childModel].push(o)
                else                                priv.modelQueryCbs[childModel]   = [o]
            }

            debug.debugMsg(tabStr + "ZController.getModelQuery(",parentModel,",",parentId,",",childModel,")   end")
            return null
        }


        function checkQueryCallbacks(modelName)
        {
            var tabStr = arguments.length == 2 ? arguments[1] : ""
            debug.debugMsg(tabStr + "-------------------------------------------------")
            debug.debugMsg(tabStr + "ZController.checkQueryCallbacks(",modelName,")")
            debug.debugMsg(tabStr + "-------------------------------------------------")

            if(modelQueryCbs[modelName])
            {
                debug.debugMsg(tabStr + "\t", modelQueryCbs[modelName].length, "query callback(s) found for", modelName)
                for(var i = modelQueryCbs[modelName].length - 1; i > -1; i--)
                {
                    var cbInfo = modelQueryCbs[modelName][i]
//                    var o = { _obj : callingObj , _prop : callingObjPropName, _parentModel : parentModel, _parentId : parentId }
                    var lm = getModelQuery(cbInfo._parentModel, cbInfo._parentId, modelName, cbInfo._obj, cbInfo._prop, false)
                    if(lm && lm.length > 0)
                    {
                        cbInfo._obj[cbInfo._prop] = lm
                        modelQueryCbs[modelName].splice(i,1)
                    }
                }

                if(modelQueryCbs.length <= 0)
                    modelQueryCbs.splice(modelName,1)
            }

            debug.debugMsg(tabStr + "ZController.checkQueryCallbacks(",modelName,")   end")
        }
    }


}
