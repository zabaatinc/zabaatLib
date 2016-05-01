import QtQuick 2.0

// ZModel, Ver 1.0 , 11/19/2014 by SSK
// Built on top of a model object, which is an array of objects in javascript.
// These objects may contain other arrays, value or more objects.

// This item is the herald for all changes to the model within
// Pass this object as a reference to anything that wants to subscribe to the model within
Item
{
    property string modelName : ""          //The name of this zModel
    property var model        : null        //The data of this zModel

    signal modelChanged_AddAt(var locationArr)  //Emits this when a new item is added to the model    . The new item is added   at locationArr
    signal modelChanged_RemAt(var locationArr)  //Emits this when a new item is removed from the model. The new item is removed at locationArr

    //This property is for convenience as well as passing the functions to objects that use zModel
    property var functions:
    ({
        set :(function (arr,val) { setVal(arr,val)    } ),
        get :(function (arr)     { return getVal(arr) } )
    })

    //Returns the value at the location defined by <arr> in the model.
    //arr - the location of the var in the model of whose value to return. e.g., ["0","lastName"] would return root's 0th element's lastName.
    //      Returns "N/A" if arr is not a valid path through the model.
    function getVal(arr)
    {
        if(arr == null || typeof arr === 'undefined' || arr.length == 0)
            return model

        var obj = model
        var i
        for(i = 0; i < arr.length - 1; ++i)
        {
            if(obj != null && obj[arr[i]] != null)
            {
                obj = obj[arr[i]]
            }
            else
                return "N/A"
        }


        if(typeof obj === 'undefined' || typeof obj[arr[i]] === 'undefined')
            return "N/A"
        else
            return obj[arr[i]]
    }

    //Sets the value to <val> to the variable path specified by the <arr>
    //arr - location of this value in the model. e.g., ["0","lastName"]
    //    - If this path does not exist in the model, a new one will be created and the modelChanged() and modelChanged_addAt(arr)
    //      will be emitted
    //val - the new value for this object
    //type - 0 means value was changed locally, everything else means that the value was changed by external sources (web, server, etc)
    function setVal(arr,val,type)
    {
        if(model)
        {
            var obj = model
            var i

            var str = ""
            for(i = 0; i < arr.length - 1; ++i)
            {
                obj = obj[arr[i]]
                str += arr[i] + ","
            }

            if(typeof obj[arr[i]] === 'undefined')
            {
                obj[arr[i]] = val
                str += arr[i]

                modelChanged()
                modelChanged_AddAt(arr)
            }
            else
            {
                obj[arr[i]] = val
                str += arr[i]

                if(type == 0)
                {
                    if(localOnChangeEvents[str])
                    {
                        for(var lFunc in localOnChangeEvents[str])
                            localOnChangeEvents[str][lFunc](val)

                    }

//                    modelMsg_MemberChanged(modelName,str,val)
                }
                else if(externalOnChangeEvents[str])
                {
                    for(var eFunc in externalOnChangeEvents[str])
                        localOnChangeEvents[str][eFunc](val)
                }


//                    modelMsg_ConfirmMemberChanged(modelName,str,val)
            }
        }
    }

    //Deletes the variable/object pointed to by <arr>
    //arr - points to the object/var to delete in the model
    //    - successful deletion will emit modelChanged_RemAt(arr) signal
    function delVal(arr)
    {
        if(model != null && typeof model !== 'undefined')
        {
            console.log("del called on")
            for(var a in arr)
                console.log(arr[a])

            var obj = model
            var i

            var str = ""
            for(i = 0; i < arr.length - 1; ++i)
            {
                obj = obj[arr[i]]
                str += arr[i] + ","
            }

            delete obj[arr[i]]
            modelChanged_RemAt(arr)
        }
    }



    //Event Arrays. One for external and one for internal changes! The external changes are deemed to be server side and reflect the current state of things in reality.
    property var localOnChangeEvents    : ({})
    property var externalOnChangeEvents : ({})



}
