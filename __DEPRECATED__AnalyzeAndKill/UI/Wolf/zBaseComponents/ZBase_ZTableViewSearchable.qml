import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import "./Functions.js" as Functions

import Zabaat.Misc.Util  1.0
import Zabaat.Misc.Global 1.0

Item
{
    id : rootObject
    property var self : this

    signal rowChanged(var changeRow, int index);
    signal hovered(int row, string role, var object);
    onWidthChanged: resizeColumns(rootObject.columnWidths)


    readonly property var currentItem : model && currentRow != -1 ? getElem(currentRow) : null


    property bool  exactSearch          : false
    property alias dynamicSortFilter    : sfpm.dynamicSortFilter
    property alias filterColumn         : sfpm.filterRole
    property alias status               : tableView.status
    property alias hideColumns          : tableView.hideColumns
    property alias cellColor            : tableView.cellColor
    property alias cellColor_Alternate  : tableView.cellColor_Alternate
    property alias tableViewPtr         : tableView
    property alias invalidColumns       : privates.invalidColumns
    property alias validColumns         : privates.validColumns
    property alias name                 : tableView.name



    property var columnOrdering  : []
    property var columnWidths    : []    //these should all add up to a total of 1 (these are widths relative to that of the row!)
    property var columnChoices   : ({})
    property var typeArr         : ({})
    property var uneditableRoles : []

    property int    currentRow      : -1
    property int    prevRow         : -1    //this is used to restore our current row back to this number when the model changes


    property bool   haveSearch      : true
    property bool   searchOnEntry   : true
    property var    model : null
    property bool   localEditing : true
    readonly property alias count : sfpm.count

    onModelChanged: init()


    function init(){
        if (ZGlobal.functions.isDef(model) && model !== 'null' ) {
            var zeroLen = false

            if(ZGlobal._.isArray(model))                                         zeroLen = model.length === 0
            else if(model.toString().toLowerCase().indexOf('listmodel') !== -1)  zeroLen = model.count === 0
            else                                                                 zeroLen = ZGlobal.functions.getProperties(model).length === 0


            if(zeroLen)
            {
                model.countChanged.connect(init)
                return
            }

            model.countChanged.disconnect(init)

            //clear the table!
            for(var i = tableView.columnCount - 1; i >=0 ; i--){
                console.log("clearing table")
                tableView.removeColumn(i)
            }

            var counter = 0;
            var elem
//            sfpm.source = null
//            sfpm.source = model


            if(typeof model.get !== 'function')        elem = model
            else                                       elem = model.get(0)

            if(typeof privates.existingColumns === 'undefined')
                privates.existingColumns = {}

            for (var k in elem)
            {
//                console.log('checking col',k)
                if(privates.validColumns && privates.validColumns.length > 0)
                {
                    if(ZGlobal._.indexOf(privates.validColumns,k,false) !== -1)
                    {
                        k = Functions.spch(k)
                        if(typeof privates.existingColumns[k] === 'undefined')
                        {
                            tableView.insertColumn(counter, Functions.getQmlObject(["QtQuick 2.4","QtQuick.Controls 1.3"],"TableViewColumn{role: "+ k +"  ; title: "+k+" ; width: 100; property bool imCol : true }",tableView))
                            privates.existingColumns[k] = true
                            counter++
                        }
                    }
                }
                else if (k !== 'objectName' && typeof elem[k] !== 'function' && (privates.columnExclusionCheck(k)) &&  ZGlobal._.indexOf(privates.modelFields,k,false) === -1)
                {
                    k = Functions.spch(k)
                    if(typeof privates.existingColumns[k] === 'undefined')
                    {
                        tableView.insertColumn(counter, Functions.getQmlObject(["QtQuick 2.0","QtQuick.Controls 1.3"],"TableViewColumn{role: "+ k +"  ; title: "+k+" ; width: 100; property bool imCol : true }",tableView))
                        privates.existingColumns[k] = true
                        counter++
                    }
                }
            }

//            if(typeof privates.existingColumns['commands'] === 'undefined')
//            {
//                tableView.insertColumn(counter, Functions.getQmlObject(["QtQuick 2.0","QtQuick.Controls 1.3"],"TableViewColumn{role: 'commands'  ; title: 'commands' ; width: 100; property bool imCol : true }",tableView))
//                privates.existingColumns['commands'] = true
//            }

            if(typeof rootObject.columnOrdering !== 'undefined' && rootObject.columnOrdering.length > 0)
                orderColumns()

            if(typeof rootObject.columnWidths !== 'undefined' && rootObject.columnWidths.length > 0)
                resizeColumns(rootObject.columnWidths)


            tableView.status = Component.Ready  //TODO - get READY only when the TableView is actually ready
        }
    }

    function restoreRowIndex(){
        if(prevRow !== -1)
            tableView.currentRow = prevRow
    }





    function doSimpleSearch(str){

        simpleSearch.text = str
        if(str.length === 0)
            str = "*"

        if(exactSearch)          sfpm.setFilterRegExp("^(" + str + ")$")
        else                     sfpm.setFilterWildcard(str)
    }

    property var editFunc : function(rowNumber, key, newValue)
    {
        //console.log(rowNumber, key, newValue)
        if(rootObject.model && rowNumber >= 0 && rowNumber < rootObject.model.count)
        {
            if(localEditing)
            {
                if(typeof rootObject.model.get(rowNumber)[key] !== 'undefined')
                {
                    var oldVal = rootObject.model.get(rowNumber)[key]
                    rootObject.model.get(rowNumber)[key] = newValue
                    //console.log(rowNumber, 'changed', key, '::', oldVal,  rootObject.model.get(rowNumber)[key])
                }
            }

            //build the rowObject
            var obj = {}
            var elem = rootObject.model.get(rowNumber)


            for(var e in elem)
            {
                if(ZGlobal._.indexOf(privates.invalidColumns, e, false) === -1)
                    obj[e] = elem[e]
            }

            obj[key] = newValue
            rowChanged(obj, rowNumber)
        }
//        else
//            console.log('no model or no such thing', rowNumber,  key)
    }

    property var externalAddFunc    : null
    property var deleteFunc : function(rowNumber)
    {
        var actualIndex = sfpm.getOriginalIndex(rowNumber)
        if(actualIndex !== -1)
            rootObject.model.remove(actualIndex)
    }




    // zcomponents reserved area
    property var uniqueProperties : ["pgWidth","pgHeight","model","headerHeight","hideColumns","cellColor","cellColor_Alternate"]
    property var uniqueSignals    : ({})
    signal isDying(var obj)
    Component.onDestruction: isDying(this)

    function orderColumns()
    {
        for(var i = 0; i < columnOrdering.length; i++)
        {
            var curIndex = getColumnIndex(columnOrdering[i])
            if(curIndex !== -1)
                tableView.moveColumn(curIndex,i)
        }

    }

    function resizeColumns(arr) //this will get called every time rootObject's width changes!
    {
        if(arr === null || typeof arr === 'undefined')
            return

        var sum = 0
        var uniformRest = null
        for(var i = 0; i < tableView.columnCount; i++)
        {
            if(i < arr.length)
            {
                tableView.getColumn(i).width = arr[i] * rootObject.width
                sum += arr[i]
            }
            else    //these are the extra columns!!
            {
                if(uniformRest == null){
                    var remaining = tableView.columnCount - i
                    uniformRest   =  (1 - sum)/remaining
                }

                if(uniformRest < 1)
                    tableView.getColumn(i).width = uniformRest * rootObject.width
            }
        }
    }

    function getColumnIndex(name)
    {
        for(var i = 0; i < tableView.columnCount; i++)
        {
            var col      = tableView.getColumn(i)
            var colName  = col.role

            if(colName[0] === '"')
                colName = colName.slice(1,-1)

            if(colName === name)
                return i
        }
        return -1
    }

    function getElem(rowNum)
    {
        if(rootObject.model != null && rowNum >= 0 && rowNum <= sfpm.count){
            if(typeof rootObject.model.get === 'function')
                return rootObject.model.get(sfpm.getOriginalIndex(rowNum))
            return backupModel.get(sfpm.getOriginalIndex(rowNum))
        }
        return null
    }




    QtObject{
        id : privates

        property bool filterUnderscoresInColumnNames: true  //stupid list model contains some weird properties like   '__0'   '__1'   so... we kill them if this is true

        property bool invalidColumnMutex : false
        property var invalidColumns: ["objectName","objectNameChanged"] //if for some reason you get weird default columns showing up in list models you can throw them in here
        onInvalidColumnsChanged:{
            if(!invalidColumnMutex){
                invalidColumnMutex = true

                if(ZGlobal._.indexOf(invalidColumns,"objectName",false) === -1)
                    invalidColumns.push("objectName")
                if(ZGlobal._.indexOf(invalidColumns,"objectNameChanged",false) === -1)
                    invalidColumns.push("objectNameChanged")

                invalidColumnMutex = false
            }
        }
        property var validColumns : []  //if this is not empty, it takes the place of invalidColumns when making columns!!

        property var existingColumns : ({})


        function columnExclusionCheck(k)
        {  //santize the columns that need supressed or stupid ones that are not worthy of life
            return  ZGlobal._.indexOf(hideColumns,k,false)             === -1 &&
                    ZGlobal._.indexOf(privates.invalidColumns,k,false) === -1 &&
                    (!privates.filterUnderscoresInColumnNames || !((k[0] === k[1]) &&  k[0] === "_"))
        }
    }



    ZBase_TextBox
    {
        id        : simpleSearch
        width     :  tableView.width/2
        height    : haveSearch? 40 : 0
        labelName : ""
        visible   : haveSearch
        enabled   : haveSearch
    }


    TableView
    {
        id     : tableView
        width  : rootObject.width
        height : rootObject.height - simpleSearch.height
        anchors.top:  rootObject.haveSearch ? simpleSearch.bottom : rootObject.top

        sortIndicatorVisible: true
        frameVisible: false
        onCurrentRowChanged:
        {
            rootObject.prevRow = rootObject.currentRow  //make our previous row thinger!
            rootObject.currentRow = currentRow;
        }


        property string name               : ""    //TODO - use this to setup the name of the table so it knows what settings to get for itself or something
        property int status                : Component.Loading
        property var hideColumns           : ["updatedAt","createdAt"]  //TODO - get these from some sort of JSON settings file or some such thing
        property bool sendOnChange         : true
        property color cellColor           : "transparent"
        property color cellColor_Alternate :  ZGlobal.style.hoverColor
        property var  fontData : ZGlobal.style.text.normal

        property int headerHeight : 40

        model : SortFilterProxyModel{
            id : sfpm
            source: {
                if(rootObject.model){
                    if(rootObject.model.toString().toLowerCase().indexOf('qqmllistmodel') !== -1)
                        return rootObject.model
                }
                return null
            }

            onRowsInserted: if(rootObject.status === Component.Ready ) restoreRowIndex()
            onRowsMoved   : if(rootObject.status === Component.Ready ) restoreRowIndex()
            onRowsRemoved : if(rootObject.status === Component.Ready ) restoreRowIndex()

            filterSyntax          : SortFilterProxyModel.RegExp
            filterCaseSensitivity : Qt.CaseInsensitive
            dynamicSortFilter     : true

            //            sortOrder: tableView.sortIndicatorOrder
            //            sortCaseSensitivity: Qt.CaseInsensitive
            //            sortRole: rootObject.model && rootObject.model.count > 0 && tableView.getColumn(tableView.sortIndicatorColumn) ? tableView.getColumn(tableView.sortIndicatorColumn).role : ""
        }

        ListModel{ id : backupModel }


        horizontalScrollBarPolicy : Qt.ScrollBarAlwaysOff
        verticalScrollBarPolicy : Qt.ScrollBarAlwaysOff


        style: TableViewStyle
        {
           id: defaultStyle

           property var headerDelegates : []

           activateItemOnSingleClick : true
           backgroundColor           : tableView.cellColor
           alternateBackgroundColor  : tableView.cellColor


           highlightedTextColor: "white"
           headerDelegate: Rectangle{
               id : headerDel
               Component.onCompleted : defaultStyle.headerDelegates.push(this)
               border.width: 1
               color  : ZGlobal.style.accent
               height : tableView.headerHeight + 5
               width  : tableView.getColumn(styleData.column) ? tableView.getColumn(styleData.column).width + 5 : 100
               property alias paintedHeight : te.paintedHeight
               Text{
                    id : te
                    font.family: ZGlobal.style.text.normal.family
                    font.pixelSize: 12
                    color : 'white'
                    text : styleData.value
                    wrapMode : Text.WrapAnywhere
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    width : headerDel.width
                    height : headerDel.height

                    onPaintedHeightChanged: {
                        var newMax = 16
                        for(var i = 0; i < defaultStyle.headerDelegates.length; i++){
                            var header = defaultStyle.headerDelegates[i]
                            if(header)
                                newMax = Math.max(newMax, header.paintedHeight)
                        }
                        tableView.headerHeight = newMax + 5
                    }
                }
           }
           rowDelegate: Rectangle{
                color : getElem(styleData.row) && getElem(styleData.row).state === 'voided' ? "orange" : styleData.row === rootObject.currentRow ? "lightBlue" : styleData.row % 2 == 0 ? "white" : "lightgray"
                height : tableView.fontData.pixelSize * 1.6
                z : -1
           }
           itemDelegate: Component { Item {
                id : delItem
                width : tableView.getColumn(styleData.column) ? tableView.getColumn(styleData.column).width + 5 : 100
                height : ti.font.pixelSize * 1.6
                opacity : getElem(rowNum) && getElem(rowNum).state === 'voided' ? 0.5 : 1

                property bool   imADelegate : true
                property int    rowNum      : styleData.row
                property string role        : tableView.getColumn(styleData.column) ? tableView.getColumn(styleData.column).role : ""// privates.columnMap[styleData.column] ? privates.columnMap[styleData.column] : ""

                Item{
                    id : clipItem
                    anchors.fill: delItem
                    clip : true
                    TextInput {
                        id : ti
                        text: typeof styleData.value !== "undefined" ? styleData.value : ""
                        visible: loaderEditor.item === null && delItem.role !== 'commands'
                        font.family: tableView.fontData.family
                        font.pointSize: tableView.fontData.pointSize
                        font.strikeout: rootObject.getElem(delItem.rowNum) != null && rootObject.getElem(delItem.rowNum).state === 'voided' ? true : false
                        width : delItem.width
                        height : delItem.height
                        enabled : false
                        anchors.centerIn: parent
                        horizontalAlignment: text.indexOf(".") !== -1 && !isNaN(text) ? Text.AlignRight : Text.AlignHCenter
                        verticalAlignment : Text.AlignVCenter
                    }
                }
                Loader    {
                    id: loaderEditor
                    anchors.fill: delItem
                    sourceComponent: {
                        if(delItem.opacity !== 1)
                            return null

                        if(ZGlobal._.indexOf(uneditableRoles, delItem.role, false) !== -1)
                            return null

                        if(styleData.row !== rootObject.currentRow)
                            return null

                        if(typeof rootObject.typeArr[delItem.role] !== 'undefined')
                            return customEditor

                        if(typeof rootObject.columnChoices[delItem.role] !== 'undefined')
                            return comboEditor

                        return editor
                    }

                    //The loader chooses one of the three Components or none. editor is a basic TextInput editor, comboEditor is a combobox and customEditor
                    //can use customTypes we define in typeArr at rootObject

                    Component {
                        id: editor

                        Item{

                            width : delItem.width
                            height : delItem.height
                            clip : true

                            TextInput {
                                width : delItem.width
                                height : delItem.height
                                id: textinput
                                text : styleData.value ? styleData.value : "N/A"
                                font.family: tableView.fontData.family
                                font.pointSize: tableView.fontData.pointSize
                                font.strikeout: rootObject.getElem(delItem.rowNum) &&  rootObject.getElem(delItem.rowNum).state === 'voided' ? true : false
                                horizontalAlignment: ti.horizontalAlignment
                                verticalAlignment : Text.AlignVCenter
                                onAccepted: rootObject.editFunc(sfpm.getOriginalIndex(delItem.rowNum), delItem.role, text)

                                MouseArea{
                                    anchors.fill: parent
                                    onClicked : { parent.forceActiveFocus(); parent.selectAll() }
                                    hoverEnabled: true
                                    onEntered: hovered(delItem.rowNum , delItem.role,  parent)
                                }
                            }
                        }
                    }
                    Component {
                        id : comboEditor
                        ZBase_ComboBoxQt{
                            id : combo
                            anchors.fill: parent
                            labelName: ""

                            Component.onCompleted: if(columnChoices[delItem.role])
                            {
                                console.log("im reloading again", delItem.role)
                                var key = columnChoices[delItem.role].hasOwnProperty('key')
                                initVal = styleData.value

                                var obj
                                if(key)
                                {
                                    showValueField   = false
                                    actualValueField = 'key'
                                    obj = columnChoices[delItem.role].arr

                                }
                                else
                                {
                                    showValueField = true
                                    actualValueField = "val"
                                    obj = []
                                    for(var a = 0; a < columnChoices[delItem.role].length; a++ )
                                        obj.push({val :columnChoices[delItem.role][a] })

                                }

                                 setupObj = obj
                            }

                            onAnswerChanged: if(status === Component.Ready) {
                                                 rootObject.editFunc(sfpm.getOriginalIndex(delItem.rowNum), delItem.role, answer)
                                             }
                        }
                    }
                    Component {
                        id : customEditor
                        Item{
                            id : customItem
                            Component.onCompleted: {
                                var typeData = rootObject.typeArr[delItem.role]
                                if(typeof typeData !== 'undefined')
                                {
                                    var component        = typeData.type ? typeData.type : "ZTextBox"
                                    if(component === null || component === 'null')
                                    {
                                        var simpleObject = ZGlobal.functions.getQmlObject(["QtQuick 2.0"], "Item { width : parent ? parent.width : 100 ; height : parent ? parent.height : 100; opacity : 0;
                                                                                                            property var hoverFunc : function () {};
                                                                                                            property string text : '';
                                                                                                            MouseArea { anchors.fill: parent; hoverEnabled : true; onEntered : hoverFunc(); }  } " , customItem)
                                        simpleObject.text = ti.text
                                        simpleObject.hoverFunc = function() {  hovered(delItem.rowNum , delItem.role,  simpleObject) }
                                        return
                                    }

                                    var importArr = ["QtQuick 2.0", "Zabaat.UI.Wolf 1.0"]
                                    if(typeof typeData.importArr === 'string' && ZGlobal._.indexOf(importArr, typeData.importArr, false) === -1)
                                        importArr.push(typeData.importArr)
                                    else if(typeof typeData.importArr === 'object')
                                    {
                                        for(var t in typeData.importArr){
                                            if(ZGlobal._.indexOf(importArr, typeData.importArr[t],false) === -1)
                                                importArr.push(typeData.importArr[t])
                                        }
                                    }


                                    var valueField       = typeData.valueField ? typeData.valueField : "text"
                                    var labelField       = typeData.labelField ? typeData.labelField : null
                                    var finishedSignal   = typeData.finishedSignal ? typeData.finishedSignal : "on"  + ZGlobal.functions.capitalizeFirstLetter(valueField) + "Changed"
                                    var simpleConnectStr = finishedSignal + ":connectFunc()";


                                    var object = ZGlobal.functions.getQmlObject(importArr, component + "{  width : parent ? parent.width : 100; height : parent ? parent.height : 100;
                                                                                                           property var connectFunc : function() {};
                                                                                                            "+ simpleConnectStr + "}" , customItem)

                                    object[valueField] = ti.text
                                    object.connectFunc = function()
                                                        {
                                                            try{ rootObject.editFunc(sfpm.getOriginalIndex(delItem.rowNum), delItem.role,object[valueField]) }
                                                            catch(e) {console.log(e)}
                                                        }

                                    if(labelField !== null)
                                        object[labelField] = ""

                                    if(typeData.override){
                                        for(var k in typeData.override){
                                            if(k === 'width')                                      customItem.width = typeData.override[k]
                                            else if(k === 'height')                                customItem.height = typeData.override[k]
                                            else if(typeof object[k] !== 'undefined')              object[k] = typeData.override[k]
                                        }
                                    }



                                }
                            }
                        }
                    }

                    onLoaded : {
                        if(sourceComponent === comboEditor){
                            //init it to the correct value
                            var value = styleData.value
                            if(value){

                            }
                        }
                    }


                }


            }}

        }

    }













}



