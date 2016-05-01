import QtQuick 2.0
import Zabaat.UI.Wolf 1.0
import "Functions.js" as Functions

// ZComboBox, Ver 1.0 , 11/19/2014 by SSK
// Builds on top of ZValueArr which uses a list of ZBindVals

// This combobox is not generic in the sense that it does not just SHOW the values in a valueArr
// The main idea behind this combobox item is to be able to do linking between ZModel objects
// NOTE : init needs to turned on manually after setting all the properties of this object!
Rectangle
{
    id : rootObject
    width : 250
    height : 64
    border.width: 3
    border.color: "black"

    property var    linkedZModel         : null                     //The ZModel which holds the actual values
    property alias  valuesField          : valuesArr.fieldName      //The name of the values field (this will most likely be some form of id)
    property var    displayFields        : null                     //The array containing the fields that are to be displayed in the combobox
                                                                    //Each element in this array dynamically creates a ZValueArr

    property string arrObjStr            : ""                       //The location string where all the displayFields / valuesArr lives in
                                                                    //the linkedZModel

    property var       zModel : null                                //The ZModel which wants to use the linkedZModel
    property string    zfkStr : ""                                  //The ZFK string for this combobox (the linker string)
                                                                    //This is ALWAYS in the format of <BindStr>,<Value>
                                                                    //where the object containing <Value> always has a property called "ZFK"

    property bool init : false                                      //Allows to disable some loopage on setting properties
                                                                    //Set this to true after you have set all the properties. Needs to be
                                                                    //done manually!

    property string index     : "-1"                                //Used in ZSheetView, do not need to set this otherwise!
    property string myType    : "ZComboBox"                         //Allows for a fast way of knowing what type of object this is
    property alias currentIndex :  cmbBox.currentIndex              //The current selected index of this combobox




    Item { id : arrayContainer }                                    //Contains the list of ZValueArr Objects
                                                                    //As listed in the displayFields property
                                                                    //Each index in each of the ZValueArr list corresponds to an index
                                                                    //of the valuesArr

    ZValueArr    { id : valuesArr  }                                //Contains the list of actual values that the object is looking for

    //This solitary ZBindVal is responsible for listening to changes occuring to this combobox's currentValue
    //Without it, we have no way of telling if anything other than ourself (this combobox) changed its value
    ZBindVal
    {
        id      : currentVal

        onValChanged:
        {
            init = false
            setCurrentIndexTo(val)
            init = true
        }
    }

    //The Base Graphical Element on which this combobox is made
    ZComboBox
    {
        id: cmbBox
        width  : parent.width  - parent.border.width
        height : parent.height - parent.border.width
        anchors.centerIn: parent
    }

    //Call renew() if the displayField is changed (remake the combobox from scratch)
    onDisplayFieldsChanged: if(init) renew()

    //Call renew() if the arrObjStr is changed and update all the ZValueArr objects to look at this new arrObjStr
    onArrObjStrChanged:
    {
        if(init)
        {
            valuesArr.arrObjStr  = arrObjStr
            renew()
            for(var i = 0; i < arrayContainer.children.length; ++i)
                arrayContainer.children[i].arrObjStr = arrObjStr
        }
    }

    //Call renew() if the LinkedZModel is changed and update all the ZValueArr objects to look at this new arrObjStr
    onLinkedZModelChanged:
    {
        if(init)
        {
            valuesArr.zModel  = linkedZModel
            renew()
            for(var i = 0; i < arrayContainer.children.length; ++i)
                arrayContainer.children[i].zModel = linkedZModel
        }
    }

    //Tells the zModel (not the linkedZModel) that the value changed. It uses the valuesArr in combination with the index
    //to determine this value!
    onCurrentIndexChanged:
    {
        if(init)
        {
            valuesArr.update()
            var newVal = valuesArr.arr[currentIndex].val
            zModel.setVal(zfkStr.split(","),newVal)
        }
    }


    //Remakes the combobox
    //  Reinstatiates the list of ZValueArr objects in arrayContainer. Binds them each to a corresponding fieldName in the displayFields array
    //  Re-updates()  the ZValueArr valuesArr.
    //  Re-updates()  the ZBindVal  currentVal.
    function renew()
    {
        if(linkedZModel != null && linkedZModel.model != null && displayFields != null)
        {
            arrayContainer.children = []
            for(var i = 0; i < displayFields.length; ++i)
            {
                var dispArr       = Functions.getQmlObject(["QtQuick 2.0", Functions.spch("../zModel")] , "ZValueArr{}", arrayContainer  )

                //Functions.getQmlObject(["QtQuick 2.0", Functions.spch("../zModel")] ,"ZModel{}", linkedObjContainer)

                        //getNewObject("zComponents/zModel/ZValueArr.qml",arrayContainer)
                dispArr.arrObjStr = arrObjStr
                dispArr.fieldName = displayFields[i]
                dispArr.zValueArr_arrChanged.connect(updateMe)
                dispArr.nestLenChanged.connect(updateMe)
                dispArr.zModel    = linkedZModel
            }

            valuesArr.arrObjStr = arrObjStr
            valuesArr.fieldName = valuesField
            valuesArr.zModel = linkedZModel

            valuesArr.update()
            updateMe()
        }
        currentVal.zModel = rootObject.zModel
        currentVal.bindStr = zfkStr
        currentVal.doConnect()
    }


    //Clears the combobox and then fills it using the ZValueArr list in arrayContainer
    //Each index in each ZValueArr (in arrayContainer) is used to make a string that is added to the combobox's display model
    function updateMe()
    {
        if(linkedZModel != null && typeof linkedZModel !== 'undefined' && linkedZModel.model != null && typeof linkedZModel.model !== 'undefined')
        {
            cmbBox.model.clear()
            for(var j = 0; j < valuesArr.arr.length; ++j)
            {
                var str = ""
                for(var i = 0; i < arrayContainer.children.length; ++i)
                {
                    if(typeof arrayContainer.children[i].arr[j] !== 'undefined')
                        str += arrayContainer.children[i].arr[j].val + " "
                    else
                        str += "N/A" + " "
                }
                cmbBox.model.append({TEXT: str}   )
            }
        }
    }

    //This function uses the valueArr to determine what index is selected (compares the val to all the values in the valuesArr)
    function setCurrentIndexTo(val)
    {
        for(var i = 0; i < valuesArr.arr.length; ++i)
        {
            if(valuesArr.arr[i].val == val)
                currentIndex = i
        }
    }



}

