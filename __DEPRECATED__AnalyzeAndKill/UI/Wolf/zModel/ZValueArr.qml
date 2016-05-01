import QtQuick 2.0
import Zabaat.UI.Wolf 1.0
import "Functions.js" as Functions

// ZValueArr, Ver 1.0 , 11/19/2014 by SSK
// Creates a list of ZBindVal objects and puts them in the Item id : nest.
// Allows for binding to a list of values based on a field name
Item
{
    id : rootObject

    Item { id : nest  } //The container of ZBindVals


    signal zValueArr_arrChanged(int index, var value)       //This signal says which index changed in the arr and what is the new value


    property var    arrObj        : null                     // The array of values located at arrObjStr, fieldName
    property var    zModel        : null                     // The zModel this ValueArr is bound to
    property string arrObjStr     : ""                       // The location at which this ValueArr is bound to in the ZModel
    property string fieldName     : ""                       // The fieldName at which this ValueArr is bound to in the ZModel
    property bool enableArrObjStr : true                     // Gives us the ability to control emits on arrObjStr changed
                                                             // A change can occur from within this object
                                                             // ArrObjStr is autoset to "" if we set it to "root" since both are
                                                             // considered synonymous
    property alias    arr         : nest.children            // A convenient way to access nest.children from the outside
    property int    nestLen       : -1                       // A convenient way to access nest.children.length from the outside


    onArrObjStrChanged :
    {
        if(enableArrObjStr && zModel != null)
        {
            arrObj = null
            update()
        }
    }
    onZModelChanged:
    {
        arrObj    = null
        update()

        if(zModel != null && zModel.model != null)
            zModel.modelChanged.connect(renew)
    }
    onFieldNameChanged   : update()




    //This function is called when the model inside the zModel changes (such as an add is done to it or a deletion)
    //This is NOT called when the model has a value changed but rather when the length of the values change or the type
    function renew()
    {
        arrObj = null
        update()
    }


    //Updates this ValueArr object
    //If arrObj is null, it follows these rules :
    //      If arrObjStr is "" or "root" ,                                       sets arrObj = zModel.getVal(null)
    //                                                                                         which is the same as saying zModel.model
    //      Else if arrObjStr is something more complex such as "0,attributes" , sets arrObj = model[0][attributes]
    //
    //After it is done assigning the arrObj, it now reinstantiates nest.children (the list of ZBindVals)
    //      The total number of ZBindVals created is equal to the length of the arrObj (the number of properties at arrObjStr in Zmodel)
    //      Each ZBindVal is bound to <arrObjStr,fieldName>
    function update()
    {
        if(zModel != null && typeof zModel !== 'undefined' && zModel.model != null && typeof zModel.model !== 'undefined')
        {
            if(arrObj == null)
            {
                if(arrObjStr == "root" || arrObjStr == "")
                {
                    enableArrObjStr = false
                        arrObjStr = ""
                    enableArrObjStr = true

                    arrObj = zModel.getVal(null)    //get the model at the root!!
                }
                else
                {
                    arrObj = zModel.getVal(arrObjStr.split(","))
                }
            }

            if(arrObj != null && typeof arrObj !== 'undefined')
            {
                nest.children = []
                if(nestLen == -1)
                    nestLen = Qt.binding(function() { return arr.length } )

                for(var i = 0; i < arrObj.length; ++i)
                {
                    var bindVal = Functions.getNewObject("ZBindVal.qml",nest)
                    bindVal.zModel  = zModel

                    if(arrObjStr != "")         bindVal.bindStr = arrObjStr + "," + i + "," + fieldName
                    else                        bindVal.bindStr = i + "," + fieldName

                    bindVal.index   = i

                    bindVal.valChangedLocal.connect(handleChange)
                    bindVal.valChangedExternal.connect(handleChange)
                    bindVal.doConnect()
                }
            }
        }
    }

    //Propagates the zValueArr_arrChanged signal upward.
    //This is to notify any object subscribing to this ValueArr's changes
    function handleChange(index)    { zValueArr_arrChanged(index,arr[index].val) }





}
