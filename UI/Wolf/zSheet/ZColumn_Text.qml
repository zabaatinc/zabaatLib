import QtQuick 2.0
import Zabaat.UI.Wolf 1.0
import "Functions.js" as Functions

Rectangle
{
    id      : rootObject
    height  : col.children.length * (spacing + cellHeight)

    property int spacing      : 2
    property int cellHeight   : 60

    property color fontColor    : "black"
    property int   fontSize     : 12
    property bool  isEnabled    : true
    property color bgkColor    : "white"

    property color localChangeColor : "purple"
    property color searchColor      : "yellow"

    property string title           : ""

    property var   arr          : []
    property var   showArr      : null


    property var  sheetParent       : null
    property var  sheetSelf         : null
    property var  sheetContainer    : null

    property bool init           : false
    property bool isObj          : false

    onArrChanged     : if(init) populateChildren()




    function updateShow()       { col.updateShow()          }
    function update()           { col.update()              }
    function queryFunc(query)
    {
        //the weird part is the regex test for at least ONE CHAR OF NON whiteSpace
        if(query != null && (typeof query !== 'undefined') && /\S/.test(query))
        {
            for(var i = 0; i < arr.length; ++i)
            {
                if(arr[i] != "N/A" && typeof arr[i] === 'string' && arr[i].indexOf(query) !== -1)
                {
                    col.children[i].color = Qt.binding(function() { return searchColor } )
                    showArr[i] = true
                }
                else if(isCell(i))
                    col.children[i].color = Qt.binding(function() { return bgkColor } )
            }
        }
    }

    function addEmptyItem(i)
    {
        arr[i] = 'undefined'
        col.newCell(i)
    }

    function addNewItem(i) { col.addNewItem(i) }
    function removeItem(i)
    {
        arr.splice(i,1)
        col.update()
    }

    function color_normalizeAll()
    {
        for(var i = 0; i < col.children.length; ++i)
        {
            if(isCell(i))
                col.children[i].color = Qt.binding(function() { return bgkColor } )
        }
    }


    function isCell(i)
    {
        console.log(i,typeof col.children[i])
        return col.children[i].hasOwnProperty("myType") && col.children[i].myType == "ZCell"
    }


    Item
    {
        id : tempContainer
    }


    Column
    {
        id : col
        anchors.fill: parent
        spacing : rootObject.spacing



        function update()
        {
            if(arr != null && typeof arr !== 'undefined')
            {
                if(children.length != arr.length)
                    populateChildren()
                else
                {
                    for(var i = 0; i < arr.length; ++i)
                    {
                        if(isCell(i))
                        {
                            col.children[i].text = arr[i]
                            col.children[i].border.color = "black"
                        }
                    }
                }
            }
        }



        function newSheet(i)
        {
            var sheet          = Functions.getNewObject("ZSheetView.qml",sheetContainer)

            sheet.width        = sheetParent.width
            sheet.height       = sheetParent.height
            sheet.rot          = sheetParent.rot


            sheet.parentSheet           = sheetSelf
            sheet.parentRootObject      = sheetParent
            sheet.additionalFunctions   = sheetParent.additionalFunctions
            sheet.zModel                = sheetParent.zModel


            if(!isObj)
                sheet.crumbsStr            = sheetParent.crumbsStr + " » " +  i  +  " » " + title
            else
                sheet.crumbsStr            = sheetParent.crumbsStr + " » " + title


            sheetParent.crumbsArr[sheet.getCondensedCStr(sheet.crumbsStr)] = sheet.sheetSelfie
            sheet.crumbsArr = sheetParent.crumbsArr



            sheet.sheetSelfie.visible      = false
            sheet.rootArr                  = arr[i]

            sheet.propertyName = title
            sheet.propertyIndex  = i



            sheet.allowChange = true


            var btn       = Functions.getNewObject("ZVisBtn.qml",col)
            btn.target    = sheet.sheetSelfie
            btn.self      = sheetSelf


            btn.btnText   = Qt.binding(function()   { return ".." + sheet.rootArr.length       }       )

            btn.width     = Qt.binding(function()   { return width                     }       )
            btn.height    = Qt.binding(function()   { return cellHeight                }       )
            btn.textColor = Qt.binding(function()   { return fontColor                 }       )
            btn.fontSize  = Qt.binding(function()   { return fontSize                  }       )
        }


        function newCell(i)
        {
            var obj = Functions.getNewObject("ZCell.qml",col)
            obj.width     = Qt.binding(function()   { return width                     }       )
            obj.height    = Qt.binding(function()   { return cellHeight                }       )

            obj.fontColor = Qt.binding(function()   { return fontColor                 }       )
            obj.fontSize  = Qt.binding(function()   { return fontSize                  }       )
            obj.isEnabled = Qt.binding(function()   { return isEnabled                 }       )
            obj.color     = Qt.binding(function()   { return bgkColor                  }       )

            obj.index      = i

            //Determining the bindStr!!
            obj.bindStr    = getBindStr(i)
            obj.zModel     = sheetParent.zModel


//            obj.doConnect() //binds!
            obj.iChanged.connect(textChange)
            obj.iChangedType.connect(cellTypeChange)
        }


        function getBindStr(i)
        {
            var arr = sheetParent.crumbsStr.split(" » ")
            var bindStr = ""

            for(var j = 1 ; j < arr.length; ++j)    //start from 1 to ignore the root!
                bindStr += arr[j] + ","


            if(isObj)       bindStr += title
            else            bindStr += i + "," + title
            return bindStr
        }


        function cellTypeChange(index,value)
        {
            console.log("cellType changed",index)
            arr[index] = value

            for(var i = children.length - 1; i > index; --i)
            {
                children[i].parent = tempContainer
            }

            var oldObj = col.children[index]
            oldObj.iChanged.disconnect(textChange)
            oldObj.iChangedType.disconnect(cellTypeChange)
            oldObj.parent = null
            oldObj.destroy()

            var newItem = addNewItem(index)

            for(i = tempContainer.children.length - 1; i > -1 ; --i)
            {
                console.log(tempContainer.children[i].text)
                tempContainer.children[i].parent = col
            }

//            for(i = 0; i < children.length; ++i)
//                console.log(i,typeof children[i])

        }

        function textChange(index,value) { arr[index] = value }



        function populateChildren()
        {
            if(arr != null && typeof arr !== 'undefined')
            {
                children          = []
                for(var i = 0; i < arr.length; ++i)
                    addNewItem(i)
            }
        }


        function addNewItem(i)
        {
            if(Object.prototype.toString.call( arr[i] ) === '[object Array]'  )
               newSheet(i)

            else if(Object.prototype.toString.call( arr[i] ) === '[object Object]')
            {
                if(arr[i].hasOwnProperty('ZFK'))
                {
                    //in this case, we will make a dropdown box (combobox)
                    var zfkStr = getBindStr(i) + ",value"
                    var box    = sheetParent.additionalFunctions.getComboBox(arr[i].ZFK, arr[i].field , arr[i].display, arr[i].value, zfkStr, col)

                    if(typeof box == 'undefined')
                        box.destroy()
                    else if(box != null)
                    {
                        box.width     = Qt.binding(function()   { return width                     }       )
                        box.height    = Qt.binding(function()   { return cellHeight                }       )
                        box.index     = i
                        box.z         = -i
                    }
                }
                else
                    newSheet(i)
            }
            else
               newCell(i)
        }

        function updateShow()
        {
            if(showArr != null)
            {
                for(var i = 0; i < showArr.length; ++i)
                {
                    if(arr != null && arr.length > 0)
                    {
                        if(typeof children[i] !== 'undefined')
                            children[i].visible = showArr[i]
                    }
                }
            }
        }

    }


    function getBtnTo(obj)
    {
        for(var C in col.children)
        {
            var child = col.children[C]
            if(child.hasOwnProperty("btnText")) //is a button
            {
                if(child.target == obj)
                    return child
            }
        }
        return null
    }



}
