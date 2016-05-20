import QtQuick 2.0
import "Functions.js" as Functions
Item
{
    id : rootObject
    width : 1000
    height: 500

    property var zModel : null
    property var startArr : ["root"]

    //onzModelChanged: sheetView.zModel = rootObject.zModel
    onZModelChanged  : update()
    onStartArrChanged: update()

    function update()
    {
        if(zModel != null)
        {
            linkedObjContainer.children = []

            var zModel_Fruit = Functions.getQmlObject(["QtQuick 2.0", Functions.spch("../zModel")] ,"ZModel{}", linkedObjContainer)
            zModel_Fruit.modelName  = "fruit"
            zModel_Fruit.model      = fruitModel

            var mdl1 = Functions.getQmlObject(["QtQuick 2.0", Functions.spch("../zModel")] ,"ZModel{}", linkedObjContainer)
            mdl1.modelName  = "color"
            mdl1.model      = colorModel




            if((startArr == null || typeof startArr === 'undefined' ) || (startArr.length == 1 && (startArr[0] == "root" || startArr[0] == "")))
            {
                sheetView.zModel = zModel
                sheetView.rootArr  = zModel.model
            }
            else
            {
                var obj = zModel.model
                var str = "root,"
                var crumbsStr = "root » "
                for(var i = 0; i < startArr.length; ++i)
                {
                    obj = obj[startArr[i]]

                    if(i != startArr.length -1)
                    {
                        str       += startArr[i] + ","
                        crumbsStr += startArr[i] +" » "
                    }
                    else
                    {
                        str       += startArr[i]
                        crumbsStr += startArr[i]
                    }
                }


                sheetView.crumbsStr = crumbsStr
                sheetView.crumbsArr = []
                sheetView.crumbsArr[str] = sheetView.sheetSelfie
                sheetView.zModel    = zModel
                sheetView.rootArr = obj
                sheetView.allowChange = true


            }
//            sheetView.zModel   = zModel
        }
    }

    function recursivePrint(obj)
    {
        for(var key in obj)
        {
            if(Object.prototype.toString.call(obj[key]) === '[object Array]'  ||
               Object.prototype.toString.call(obj[key]) === '[object Object]' ||
               typeof obj[key] === 'object')
            {
                recursivePrint(obj[key])
            }
            else
                console.log(key,":",obj[key])
        }
    }


    function getComboBox(name,field,display,currentVal,zfkStr,parent)
    {
//        console.log(name,field,display,currentVal,zfkStr)
        var obj = null
        for(var i = 0; i < linkedObjContainer.children.length; ++i)
        {
            if(linkedObjContainer.children[i].modelName == name)
            {
                obj = linkedObjContainer.children[i]
            }
        }

        if(obj == null)
            return null

        var COMBO = Functions.getNewObject("ZComboBox.qml",parent)


        COMBO.linkedZModel  = obj
        COMBO.zModel        = zModel
        COMBO.arrObjStr     = "root"
        COMBO.valuesField   = field
        COMBO.displayFields = display

        COMBO.zfkStr        = zfkStr
        COMBO.renew()

        COMBO.setCurrentIndexTo(currentVal)
        COMBO.init          = true

        return COMBO
    }

    ZSheetView
    {
        id                 : sheetView
        anchors.fill       : parent
        additionalFunctions: functions


        //this is a way of having functions inside an object!
        property var functions:
        ({
            getComboBox :(function (name,field,display,currentVal,zfkStr,parent) { return getComboBox(name,field,display,currentVal,zfkStr,parent) }),
        })


    }


    property var colorModel: [
                                {name: ZGlobal.style.danger    , R:"255" , G:"0"   ,  B: "0"  },
                                {name: "Green"  , R:"0"   , G:"255" ,  B: "0"  },
                                {name: "Blue"   , R:"0"   , G:"0"   ,  B: "255"},
                                {name: "Yellow" , R:"255" , G:"255" ,  B: "0"  } ]

    property var fruitModel: [
                                {name: "apple"    , ID:"0" },
                                {name: "orange"   , ID:"1" },
                                {name: "grape"    , ID:"2" },
                                {name: "mango"    , ID:"3" } ]









    Item
    {
        id : linkedObjContainer
    }



}
