import QtQuick 2.0
import Zabaat.UI.Wolf 1.0
import "Functions.js" as Functions

Item
{
    id : rootObject

    // Properties that CAN/SHOULD be assigned to ###################################
    width : 500
    height : 1000

    onZModelChanged:
    {
        if(zModel != null && zModel.model != null && parentRootObject == null)
        {
            zModel.modelChanged_AddAt.connect(handleAdd)
            zModel.modelChanged_RemAt.connect(handleRem)
        }
    }



    function resolveSheetView(locationArr)
    {
        if(crumbsArr != null)
        {
            var j = 2
            do
            {
                var str = "root,"

                for(var i = 0; i < locationArr.length - j; ++i)
                    str += locationArr[i] + ","

                str = str.substring(0,str.length-1)
                str = getCondensedCStr(str)
//                console.log(str)

                if(typeof crumbsArr[str] !== 'undefined')
                    return crumbsArr[str]

                j--
            }while(j >= 0)
        }
        return null;
    }



    function handleAdd(locationArr)
    {
        var obj = resolveSheetView(locationArr)
        if(obj != null)
        {
            //lets see if we ended up adding any new titles to this mess

            //If this looks real gay, its cause it is.
            //titleRow = obj.children[2]
            //dataCells = obj.children[3].children[0]

            var objTitleRow  = obj.children[2]
            var objDataCells = obj.children[3].children[0]
            var maxDataLen   = 0

            var titleLen = objTitleRow.arrLen
            objDataCells.updateTitles()

//            console.log(titleLen, obj.children[2].rootArr.length)
            if(titleLen != objTitleRow.arrLen)  //add a new column
            {
                objDataCells.updateColNum(objDataCells.children.length )    //add a new column!???
                for(var C in objDataCells.children)
                {
                    var child = objDataCells.children[C]

                    if(child.arr.length > maxDataLen)
                        maxDataLen = child.arr.length
                }
            }
            else
            {
                var len = locationArr.length
                for(C in objDataCells.children)
                {
                    child = objDataCells.children[C]

                    if(child.arr.length > maxDataLen)
                        maxDataLen = child.arr.length

                    locationArr[len] = child.title

                    child.arr[child.arr.length] = zModel.getVal(locationArr)
    //                    child.addNewItem(child.arr.length - 1)
                }
            }


            //after all the changes are done, we should see that all the column lengths match!!
            for(var K in objDataCells.children)
            {
                child = objDataCells.children[K]
                while(child.arr.length < maxDataLen)
                {
                    child.addEmptyItem(child.arr.length)
                    showArr[child.arr.length] = true
                }
            }

        }

    }


    function recursiveDelete(obj,curPos)
    {
        if(obj != null)
        {
            var objTitleRow  = obj.children[2]
            var objDataCells = obj.children[3].children[0]
            var maxDataLen   = 0

            if(typeof obj.titles !== 'undefined')
            {
                var oldTitles
                for(var i = 0; i < obj.titles.length; ++i)
                    oldTitles[i] = obj.titles[i]

                objDataCells.updateTitles()

                //find a column to delete
                if(oldTitles.length != obj.titles.length)
                {
                    for(i = 0; i < oldTitles.length; ++i)
                    {
                        var found = false
                        for(var j = 0; j < obj.titles.length; ++j)
                        {
                           if(oldTitles[i] == obj.titles[j])
                           {
                               found = true
                               break
                           }
                        }

                        if(!found)
                        {
                            //delete this column!!
                            for(var C in objDataCells)
                            {
                                var child = objDataCells[C]
                                if(child.title == oldTitles[i])
                                    child.destroy()
                            }
                        }
                    }
                }
            }
            else
            {
                for(C in objDataCells)
                {
                    delete objDataCells[C]
                }
            }

            if(objDataCells.length < 1)
            {
                //we need to now remove the button to this page now!!
                var prevPage = resolveSheetView(locationArr.splice(locationArr.length - 2,1))

                var prevTitleRow = prevPage.children[2]
                var prevColumns  = prevPage.children[3].children[0]

                for(C in prevColumns)
                {
                    child = prevColumns[C]
                    var btn = child.getBtnTo(obj)
                    if(btn != null)
                    {
                        btn.destroy()
                    }
                }
            }
        }
    }


    function handleRem(locationArr)
    {
        var obj = resolveSheetView(locationArr)
        rootRenew() //CLASSIEST WAY TO HANDLE DELETION


//        recursiveDelete(obj,locationArr)
    }


    property var crumbsArr : null       //CRUMBS STR as index and sheets as values (this is shared across all sheets!)

    property var zModel    : null
    property var rootArr
    property alias rot: sheetContainer.rotation

    property int cellHeight : 60
    property int spacing    : 2

    property alias  titleBGKColor : titleRow.bgkColor
    property alias  titleTXTColor : titleRow.textColor
    property int    titleFNTSize  : 16

    property bool  boxesEnabled : false
    property color dataBGKColor : "white"
    property color dataTXTColor : "black"
    property int   dataFNTSize  : 14

    // Properties DONT TOUCH!!! ####################################################

//    property int rootArr.length

    property string propertyIndex   : ""
    property string propertyName    : ""
    property alias  crumbsStr       : breadCrumbs.text


    property var   parentSheet          : null
    property var   parentRootObject     : null
    property alias sheetSelfie          : thisSheet


    property var   titles       : []
    property var   showArr      : []

    property var additionalFunctions : null
    property bool allowChange : false

    ///Deprecated perhaps
    function set(arr, changeVal)
    {
        if(parentRootObject == null)
        {
            var obj = rootArr
            var x
            for(x = 0; x < arr.length -1 ; x++)
            {
                obj = obj[arr[x]]
            }
            obj[arr[x]] = changeVal
        }
        else
        {
            var newArr = []
            var numInsert = 0

            if(Object.prototype.toString.call( rootArr ) === '[object Array]')
            {
                newArr[0]  = propertyName
                numInsert  = 1
            }
            else
            {
                newArr[0]  = propertyIndex
                newArr[1]  = propertyName
                numInsert = 2
            }

            for(var i = 0; i < arr.length; ++i)
                newArr[i + numInsert] = arr[i]

            parentRootObject.set(newArr,changeVal)
        }
    }

    onRootArrChanged: rootUpdate()



    function rootRenew()
    {
        titles = []
        dataCells.children = []
        sheetContainer.children = []

        rootUpdate()

    }

    function rootUpdate()
    {
        if     (Object.prototype.toString.call( rootArr ) === '[object Array]')        rootArr.length = scrolly.totalDegrees = rootArr.length
        else if(Object.prototype.toString.call( rootArr ) === '[object Object]')       rootArr.length = scrolly.totalDegrees = Object.keys(rootArr).length


        if(crumbsArr == null)
        {
            crumbsArr = []
            crumbsArr[getCondensedCStr(crumbsStr)] = sheetSelfie
            allowChange = true
        }
        dataCells.update()
    }


    function getCondensedCStr(crumbs)
    {
        var cStr = crumbs
        while(cStr.indexOf(">>") != -1)
            cStr = cStr.replace(">>", ",")

        while(cStr.indexOf("»") != -1)
            cStr = cStr.replace("»", ",")

        while(cStr.indexOf(" ") != -1)
            cStr = cStr.replace(" ", "")
        return cStr
    }


    Item
    {
        id : thisSheet
        anchors.fill : parent


        ZTextBox
        {
            id : breadCrumbs
            text : parentRootObject == null ? "root" : ""
            fontSize: titleFNTSize - 2
            anchors.left: parent.left
            anchors.leftMargin: parent.width/2 - width/2
            color : "transparent"
            fontColor: "green"
            border.color: "transparent"

            onTextChanged:
            {
                if(allowChange)
                {
                    allowChange = false

                    while(text.indexOf(",") != -1)
                        text = text.replace(","," » ")

                    allowChange = true
                }
            }

            ZButton
            {
                anchors.top: parent.top
                anchors.topMargin: -height

                anchors.left : parent.left
                anchors.leftMargin: parent.width/2 - width/2

                id : crumbsBtn
                width : 32
                height : 32
                fontSize : 8
                btnText : "$"
                onBtnClicked:
                {
                    var parentCStr = getCondensedCStr(parent.text)

                    if(crumbsArr != null && typeof crumbsArr[parentCStr] !== 'undefined' && crumbsArr[parentCStr] != thisSheet)
                    {
                        crumbsArr[parentCStr].visible = true
                        thisSheet.visible = false
                    }

                    allowChange = false
                        breadCrumbs.text = crumbsStr
                    allowChange = true
                }
            }
        }

        Row
        {
            id : queryAndBtnRow
            x  : rootObject.width/2 - width/2
            anchors.top: breadCrumbs.bottom

            ZButton
            {
                id : backBtn
                width   : rootObject.width/4
                visible : parentSheet != null
                btnText : "<="
                onBtnClicked:
                {
                    thisSheet.visible    = false
                    parentSheet.visible  = true
                }
            }

            ZTextBox
            {
                id : queryBox
                width   : rootObject.width/2.5
                onTextChanged:
                {
                    if(text != null && (typeof text !== 'undefined') && /\S/.test(text))
                    {
                        //hide all
                        for(var i = 0; i < showArr.length; ++i)
                            showArr[i] = false

                        //let the columns run their searches on this text (and change the universal showArr)
                        for(i = 0; i < dataCells.children.length;++i)
                            dataCells.children[i].queryFunc(text)

                        scrolly.totalDegrees = getNumVisibleCells()
                    }
                    else
                    {
                        for(i = 0; i < showArr.length; ++i)
                            showArr[i] = true

                        for(i = 0; i < dataCells.children.length;++i)
                            dataCells.children[i].color_normalizeAll()

                        scrolly.totalDegrees = rootArr.length
                    }
                    for(i = 0; i < dataCells.children.length;++i)
                        dataCells.children[i].updateShow()
                }
            }
        }


        ZTitleRow
        {
            id          : titleRow
            width       : rootObject.width - scrolly.height - 5
            height      : cellHeight
            anchors.top : queryAndBtnRow.bottom
            x           : scrolly.height
            bgkColor    : "#00aa00"
            textColor   : "white"

            Behavior on x   {  NumberAnimation  {  duration : 600; easing.type: Easing.OutBounce  }   }
            Behavior on y   {  NumberAnimation  {  duration : 600; easing.type: Easing.OutBounce  }   }
        }


        Rectangle
        {
            id : clipRect
            color : "transparent"
            anchors.top: titleRow.bottom
            width : parent.width
            height : parent.height
            clip : true

            Item
            {
                id     : dataCells
                x      : scrolly.height
                width  : titleRow.width / titleRow.children.length
                height : dataCells.children.length * cellHeight

                Behavior on x   {  NumberAnimation  {  duration : 600; easing.type: Easing.OutBounce  }   }
                Behavior on y   {  NumberAnimation  {  duration : 600; easing.type: Easing.OutBounce  }   }

                function update()
                {
                    if(rootArr != null && rootArr.length > 0)
                    {
                        //populate titles
                        updateTitles()

                        //lets make a show array that will be PSEUDO bound to every column in this sheet view
                        for(var s = 0; s < rootArr.length; ++s)
                            showArr[s] = true

                        //since we are dealing with columns, we will build our array in a vertical manner
                        for(var i = 0; i < titles.length; i++)
                            updateColNum(i)
                    }
                }

                function updateColNum(i)
                {
                    var colArr   = []
                    var index    = 0
                    var dataObj  = Functions.getNewObject("ZColumn_Text.qml",dataCells)
                    dataObj.title = titles[i]

                    if(Object.prototype.toString.call( rootArr ) === '[object Array]')
                    {
                        dataObj.isObj = false
                        for(var j = 0; j < rootArr.length; ++j)
                        {
                            if(rootArr[j].hasOwnProperty(titles[i]))
                                colArr[index] = rootArr[j][titles[i]]
                            else
                                colArr[index] = "N/A"
                            index++
                        }
                    }
                    else if(Object.prototype.toString.call( rootArr ) === '[object Object]')
                    {
                        dataObj.isObj = true
                        if(rootArr.hasOwnProperty(titles[i]))
                            colArr[index] = rootArr[titles[i]]
                        else
                            colArr[index] = "N/A"
                        index++
                    }


                    dataCells.children[i].showArr          = rootObject.showArr
                    dataCells.children[i].x                = Qt.binding(function() {return titleRow.getXOf(i)})
                    dataCells.children[i].sheetParent      = rootObject
                    dataCells.children[i].sheetSelf        = thisSheet
                    dataCells.children[i].sheetContainer   = sheetContainer

                    dataCells.children[i].cellHeight       = Qt.binding(function() { return cellHeight}      )
                    dataCells.children[i].width            = Qt.binding(function() { return dataCells.width} )
                    dataCells.children[i].spacing          = Qt.binding(function() { return spacing} )
                    dataCells.children[i].arr              = colArr
                    dataCells.children[i].update()

//                      dataCells.children[i].init = true
                }


                function updateTitles()
                {
                    titles          = []
                    var titleNum    = 0
                    var usedTitles  = []

                    for(var i = 0; i < rootArr.length; ++i)
                    {
                        if(Object.prototype.toString.call( rootArr ) === '[object Array]')
                        {
                            for(var key in rootArr[i])
                            {
                               if(!usedTitles.hasOwnProperty(key))
                               {
                                   titles[titleNum] = key
                                   usedTitles[key] = key
                                   titleNum++
                               }
                            }
                        }
                        else if(Object.prototype.toString.call( rootArr ) === '[object Object]')
                        {
                            for(key in rootArr)
                            {
                               if(!usedTitles.hasOwnProperty(key))
                               {
                                   titles[titleNum] = key
                                   usedTitles[key] = key
                                   titleNum++
                               }
                            }
                        }
                        titleRow.arr = titles
                        titleRow.update()
                    }
                }
            }

        }
        ZScrollBar
        {
            id              : scrolly
            height          : 15
            width           : dataCells.height > clipRect.height ? clipRect.height : dataCells.height
            buttonsVisible  : true
            totalDegrees    : typeof rootArr !== 'undefined' ? rootArr.length : 0            //doesnt get auto assigned as the children change, so we have to use
                                                                                             //onChildrenChanged property off the ScrollBar. look below.
            x   : height - cmpSize/4
            y   : clipRect.y + cmpSize

            rot : 90

            onScrollBarChanged:  dataCells.y = - index * (cellHeight + spacing)
        }





    }

    Item
    {
        id : sheetContainer
        anchors.fill: parent
        visible : true
    }



    function getNumVisibleCells()
    {
        var count = 0
        for(var i = 0; i < showArr.length; ++i)
        {
            if(showArr[i])
                count++
        }
        return count
    }



}
