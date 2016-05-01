import QtQuick 2.0
import "Functions.js" as Functions
// ZModelHolder, Ver 1.0 , 11/19/2014 by SSK
// Uses a list of ZModels in order to easily link them together and use them in conjunction

Item
{
    property var map        : null                      //This is the map that defines how all the models are hooked up together!
    property var models     : []                        //This has all our models!
    property bool debugMode : false                      //Prints debug messages! if it is on!
    property alias bindings : zbinder

    ZBindings
    {
        id : zbinder
    }


    //Adds a new ZModel to the modelContainer list
    //name - name of the new ZZodel to be added
    //model - data/model of the new ZModel
    function addModel(name,model)
    {
        var obj       = Functions.getNewObject("ZModel.qml",null)
        obj.modelName = name
        obj.model     = model

        if(!models)
            models = []


        models[name]    = obj
        zbinder.zModels = models

        debugMsg(typeof models[name], typeof zbinder.zModels[name], typeof obj)

        zbinder.refresh()
        //zbinder.printAll()
        debugMsg("ZModelHolder.addModel(<modelName>): model",name,"added to model Array")
    }


    //Updates a ZModel
    //name          - the name of the ZModel
    //type          - the type of update. Options are:
    //              - "update": This will create new values if the updateStr does not exist within the currentModel
    //              - "delete": Deletes the object in the model pointed to by the updateStr
    //
    //updateStr     - where this update is occuring in the Zmodel's models
    //updatePortion - the value of the update. Not used in a delete case
    function updateModel(name,type,updateStr,updatePortion)
    {
//       for(var i = 0; i < models.length; i++)
//       {
           if(models[name])
           {
               var obj   = models[name]
               var model = obj.model

               var bindArr = updateStr
               if(typeof updateStr === 'string')
                   bindArr = updateStr.split(",")

               if(type == 'update')
               {
                   //Create the properties if needed!
                   var buildArr = []

                   for(var b = 0; b < bindArr.length; ++b)
                   {
                        if(typeof model[bindArr[b]] === 'undefined')
                        {
                            buildArr[buildArr.length] = bindArr[b]

                            if(Object.prototype.toString.call(model) === '[object Array]')
                                model.splice(bindArr[b],0,({}))
                            else
                                obj.setVal(buildArr,"N/A",1)
                        }
                        model = model[bindArr[b]]
                   }
                   obj.setVal(bindArr,updatePortion)
               }
               else if(type == 'del' || type == 'delete')
               {
                    obj.delVal(bindArr)
               }

               return
           }
//       }
    }


    //Returns the ZModel whose name matches the <name> parameter
    //returns null if this name doesnt exist in our list
    function getModel(name)
    {
        if(models[name])      return models[name]
        else
        {
            debugMsg("ZModelHolder.getModel(<modelName>): model",name,"does not exist in our ZModelHolder")
            return null
        }
    }

    //Deletes the model whose name matches the <name> parameter
    //Returns true if delete was successful and a model was found. Returns false otherwise.
    function deleteModel(name)
    {
        if(models[name])
        {
            models[name].destroy()
            debugMsg("ZModelHolder.deleteModel(<modelName>): model",name,"destroyed")
            return true
        }
        debugMsg("ZModelHolder.deleteModel(<modelName>): model",name,"destruction failed. It doesn't exist!")
        return false
    }

    //A debugging function. Prints the ZModel specified by the parameter <name>.
    function printModel(name)
    {
        if(models[name])
            recursivePrint(models[name].model,"")
    }

    //Recursively prints an object to its deepest levels
    function recursivePrint(obj, tabStr)
    {
        var str = ""
        for(var key in obj)
        {
            if(Object.prototype.toString.call(obj[key]) === '[object Array]'  ||
               Object.prototype.toString.call(obj[key]) === '[object Object]' ||
               typeof obj[key] === 'object')
            {
                recursivePrint(obj[key],tabStr + "\t")
            }
            else
                str += "(" + key + ":" + obj[key] + ") "
        }
        console.log(tabStr + str)
    }

    //Tricky little feller! Uses the implicit arguments variable (in each js function) to act nicely like console.log
    function debugMsg()
    {
        if(debugMode)
        {
            var str = ""
            for(var i = 0; i < arguments.length; i++)
                str += arguments[i] + " "
            console.log(str)
        }
    }


    signal modelMsg_MemberChanged       (string modelName, string location, var val)
    signal modelMsg_ConfirmMemberChanged(string modelName, string location, var val)





}
