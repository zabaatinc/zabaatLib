import QtQuick 2.0
//import "../zBaseComponents"

// ZBindVal, Ver 1.0 , 11/19/2014 by SSK
// This is essentially the smallest part of binding to a zModel (model extension)
// All other parts are built on top of this.
// Note : DOES NOT AUTO CALL doConnect() which is essential. It connects to the zModel.
//        The reason behind this is to allow the graphical components built on top of this
//        to be able to handle when the connection starts!
Item
{
    id : rootObject
    property var    zModel       : null     //The REFERENCE to the zModel this bindVal belongs to

    property var    idStr        : null
    property string bindStr      : ""       //The path where this value lives. e.g, "0,lastName"
    property int    index        : -1       //Useful for zSheetView, nothing else

    //NO TOUCHY!
    property var    bindArrStr   : []       //Could be done away with but we save this for performance, since we may have to do this several times
                                            //zModel expects getVal's param as an array (instead of string)

    property bool   allowSignals : true     //this var allows us to change the value of this bindVal without emitting a signal that it changed
                                            //this is useful when we are changing based on receiving a signal. That way we don't emit a signal
                                            //cause the change is in response to a signal coming in.


    property var val          : "derp"      //there's a reason why this isnt a string! It could change into an object or an array.
                                            //so textboxes bound to this bindVal will know to handle a value type change.

    signal bindingChanged (string idStr, var value, bool changeType)
    signal valChangedLocal   (int index)    //Emit this when the val change is local (on this machine)
    signal valChangedExternal(int index)    //Emit this when the val change is not local (external)

    onBindStrChanged:  if(rootObject) bindArrStr = bindStr.split(",")   //The reason for null checks are because signals & slots
                                                                                //seem to exist for a bit longer after an object is destroyed.
                                                                                //I know. Sounds dumb.

    onValChanged:
    {
        if(zModel && val != "N/A" &&  allowSignals)    zModel.setVal(bindArrStr,val,0) //Tells the zModel that this value changed!
    }
//    Component.onCompleted:  if(rootObject != null && zModel != null && typeof zModel !== 'undefined') doConnect()

    //Makes the connection between the two global model messages and retrieves the value at the bindStr location:
    //1) modelMsg_MemberChanged             to  modelMemberChanged
    //2) modelMsg_ConfirmMemberChanged      to  confirmModelMemberChanged
    function doConnect()
    {
        if(rootObject && zModel)
        {
            //No other bindVal has registered a callback to bind to this part of the model!
            var f  = function(chgVal) { localValChange(chgVal)    }
            var f2 = function(chgVal) { externalValChange(chgVal) }

            if(!zModel.localOnChangeEvents[bindStr])                zModel.localOnChangeEvents[bindStr]   = [f]
            else                                                    zModel.localOnChangeEvents[bindStr].push(f)

            if(!zModel.externalOnChangeEvents[bindStr])             zModel.externalOnChangeEvents[bindStr]   = [f2]
            else                                                    zModel.externalOnChangeEvents[bindStr].push(f2)

//            modelMsg_MemberChanged.connect(modelMemberChanged)
//            modelMsg_ConfirmMemberChanged.connect(confirmModelMemberChanged)
            val = zModel.getVal(bindArrStr)
        }
    }


    function localValChange(chgVal)
    {
        allowSignals = false
        val = chgVal
        valChangedLocal(index)

        if(rootObject["idStr"])
            bindingChanged(rootObject.idStr, val, 0)


        allowSignals = true
    }

    function externalValChange(chgVal)
    {
        allowSignals = false
        val = chgVal
        valChangedExternal(index)

        if(rootObject["idStr"])
            bindingChanged(rootObject.idStr, val, 1)

        allowSignals = true
    }


    //Handles changing this bindVal on new signal coming in (if the bindStr and model Name of the signal match)
    //Does this change without emitting a new valChanged
    //Very similar to confirmModelMemberChanged, just emits varChangedLocal instead of varChangedExternal
    function modelMemberChanged(modelName, str,chgVal)
    {
        if(rootObject != null)
        {
            allowSignals = false
            if(zModel.modelName == modelName &&  bindStr == str)
            {
                val = chgVal
                valChangedLocal(index)
            }
            allowSignals = true
        }
    }

    //Handles changing this bindVal on new signal coming in (if the bindStr and model Name of the signal match)
    //Does this change without emitting a new valChanged
    //Very similar to modelMemberChanged, just emits varChangedExternal instead of varChangedLocal
    function confirmModelMemberChanged(modelName, str,chgVal)
    {
        if(rootObject != null)
        {
            allowSignals = false
            if(zModel.modelName == modelName && bindStr == str)
            {
                val = chgVal
                valChangedExternal(index)
            }
            allowSignals = true
        }
    }



}
