import QtQuick 2.0
import Zabaat.Misc.Global 1.0

/*!
    \brief Kind of the same concept as ZDynamicForm. Very configurable and let's us produce quick ListViews without much effort!
    If an array or an object is provided as the model (and NOT a QQMlListModel), it will get copied up by this class and remade
    into a QQMlListModel. Any changes to the original array/object will not change this ListView. Provide a QQmlListModel if you want
    bindings
	\inqmlmodule Zabaat.UI.Wolf 1.0
	\code
		ZBase_ListView
		{
			id : lv
			model : modelArr
			ordering : ["firstName","lastName"]
			anchors.centerIn: parent
			displayFunctions : ({firstName : function(obj) { return obj.toUpperCase() } } )
			typeArr : ({
						   numbers : { type : 'ZLifeBar', importArr : ['Zabaat.UI.HUD.GameElements 1.0'], valueField : 'value', override : { total : 100, width : 400} }
					   })
			title : "Testing"
		}
	\endcode
*/
Column
{
    id : rootObject
    property var self : this
    width : 300
    height: 500

    readonly property alias searchStr :simpleSearch.text

    property string sectionProperty : ""
    property alias listSpacing: lv.spacing
    property alias model: lv.model


    property var header : headerItem
    onHeaderChanged: if(header) header.parent = headerContainer

    /*! allows auto building of query object on typing! */
    property bool    searchOnEntry : true

    /*!  Enable/disable advanced query builder (ZLogicalList)  */
    property bool     advancedSearch      : false

    /*!  Enable/disable search box and advanced query builder  */
    property bool     haveSearch      : true

    /*!  Ptr to the our searchBox  */
    property alias  simpleSearchBoxPtr : simpleSearch

    /*!  Ptr to the our searchBtn */
    property alias  searchButtonPtr : searchBtn

    /*! Ptr to the getDelegateInstanceAt Function */
    property var getDelegateInstanceAt : lv.getDelegateInstanceAt

    /*! Ptr to the count attribute in listView */
    readonly property alias count : lv.count


    /*!  Pointer to listView  */
    property alias      lvPtr : lv

    /*! The title of this listView, makes the header visible if this is not blank (and appears in the header obviously)  */
    property alias title : lv.title

    /*! The status of this Component. Starts off at Component.Loading and ends at Component.Ready */
    property alias status : lv.status

    /*! The highlight color used in this view. A lighter version of this color is used for the highlight bar and if the objects have color property, they will be assigned this on click  */
    property alias highlightColor : lv.highlightColor

    /*! The height of each row in the list view  */
    property alias cellHeight : lv.cellHeight

    /*! The color of the border around the rows in the listView. Defaults to ZGlobal.style.accent  */
    property alias borderColor : lv.borderColor

    /*! The title of this listView, makes the header visible if this is not blank (and appears in the header obviously)  */
    property alias  borderWidth : lv.borderWidth

    /*! Determines the order in which the fields will appear on the ZDynamicForm(s). If some fields are left out, there no guarantees in which order they will appear.
       \code
        //In this example, the ZDynamicForm guarantees that it will draw firstName and then lastName first. All the rest of the fields may be drawn at random.
        ordering : ["firstName", "lastName"]
       \endcode
    */
     property alias ordering: lv.ordering

    /*!
        Allows us to override the default ZTextBox type of the dynamic form for any field! Defaults to empty array.
        \code
        //The type object contains the following
        //<type>  is the QML type (found in Zabaat.UI.Wolf) . Should not contain .qml at the end. valid examples are ZTextBox, ZTimePicker, etc etc
        //<valueField> is the property where value should be shoved in (and read from!)
        //<labelField> is the name where labels should be shoved in (field names such as firstName, etc)
        //<override> lets us inject stuff into this component on the form and not populate it from the model! Essentially allows access to the object's qml properties such as width, height, color, etc.

        typeArr : ({
                    firstName : { type : 'ZButton' , valueField : 'text', labelField : 'labelName' }
                    lastName  : { type : null }     //makes this field invisible in the form
                    favFoods  : { type : 'ZComboBoxQt', override { derp : 'herp', slurp : 'jurp' } }
                  )}
        \endcode
    */
    property alias  typeArr : lv.typeArr

    /*! Allows for custom handling of how certain fields look. This is useful if you don't want to use the typeArr property for these fields and want them to just appear in ZTextBox instead
        \code
        //The field value is passed in as obj to the functions defined on the respective functions defined on the field names (clockIn, clockOut in this case)
        displayFunctions:  { clockIn : function(obj) { return Qt.formatTime(obj, "hh:mm AP") } ,
                            clockOut : function(obj) { return Qt.formatTime(obj, "hh:mm AP") } }
        \endcode
    */
    property alias      displayFunctions    : lv.displayFunctions

    /*!
    Allows us to exclude fields in the ZListView that will be generated
        \code
         exclusionArr: ["updatedAt","createdAt","lastEntry"]
        \endcode
    */
    property alias   exclusionArr       : lv.exclusionArr

    /*!
    Allows us to only include things we want!
        \code
         exclusionArr: ["updatedAt","createdAt","lastEntry"]
        \endcode
    */
    property alias   validArr           : lv.validArr


    /*!
    Allows us to exclude fields when searching! By default this points to the exclusionArr!
        \code
         searchExclusionArr: ["updatedAt","createdAt","lastEntry"]
        \endcode
    */
    property var   searchExclusionArr : lv.exclusionArr

    property var uniqueProperties       : ['title','highlightColor','cellHeight','borderColor','borderWidth','odering','typeArr','displayFunctions','exclusionArr','model','spacing','listSpacing']
    property var uniqueSignals          : ({})


    property var delegate : delCmp
    property var sectionDelegate : sectionDelCmp
    property alias currentIndex : lv.currentIndex


    property bool scanEntireModelForFields : false

    property var doSimpleSearch : function(str){
        simpleSearch.text = str
        if(!rootObject.searchOnEntry)
            simpleSearchRow.doSimpleQuery()
    }


    Row
    {
        width  : headerItem.width + searchItem.width + spacing
        height : searchItem.height > headerContainer.height ? searchItem.height : headerContainer.height
        spacing : 5
        z : 100

        Item
        {
            id : headerContainer
            width : rootObject.header  ? rootObject.header.width : 0
            height : rootObject.header ? rootObject.header.height : 0

            ZBase_Text {
                id : headerItem
                width   : lv.width
                height  : text.length > 0 ? lv.cellHeight/2 : 0
                text    : lv.title
                visible : lv.title.length > 0 && rootObject.header === headerItem
                color        : Qt.lighter(lv.borderColor)
                outlineColor : lv.borderColor
                outlineThickness:  1
                showOutlines: true
                fontColor    : Qt.darker(lv.borderColor)
                dText.font: ZGlobal.style.text.heading2
            }
        }



        Item
        {
            id : searchItem
            width :
            {
                if(haveSearch)
                {
                    if(advancedSearch)  return queryBuilder.width
                    else                return simpleSearchRow.width
                }
                return 0
            }
            height :
            {
                if(haveSearch)
                {
                    if(advancedSearch)  return queryBuilder.height
                    else                return simpleSearchRow.height
                }
                return 0
            }


            ZBase_LogicalList
            {
                id : queryBuilder
                opacity : advancedSearch && haveSearch ? 1 : 0
                width :  rootObject.width/2
                rowHeight: cellHeight/2
                actualValueField : 'varName'
                model : privates.varArr
                enabled : opacity
                onQueryChanged: lv.query2(queryObj)
            }

            Row
            {
                id : simpleSearchRow
                width : simpleSearch.width + spacing + searchBtn.width
                height: simpleSearch.height

                ZBase_TextBox
                {
                    id      : simpleSearch
                    opacity : !advancedSearch && haveSearch ? 1 : 0
                    width :  rootObject.width/2
                    height : cellHeight/2
                    labelName : ""
                    enabled : opacity
                    onTextChanged: if(searchOnEntry)  simpleSearchRow.doSimpleQuery()
                }

                ZBase_Button
                {
                    id : searchBtn
                    opacity : simpleSearch.opacity
                    width   : simpleSearch.width/3
                    height  : simpleSearch.height
                    btnText : ""
                    showIcon : true
                    fontAwesomeIcon: "\uf002"
                    enabled : opacity
                    onBtnClicked: simpleSearchRow.doSimpleQuery()
                }

                function doSimpleQuery()
                {
                    if(simpleSearch.text.length > 0)
                    {
                        var queryObjs = []
                        var strArr = simpleSearch.text.split(' ')
                        for(var s = 0; s < strArr.length; s++)
                        {
                            var val = strArr[s]
                            if(val.length > 0 && val != ' ')
                            {
                                for(var m in privates.modelFields)
                                {
                                    if(ZGlobal._.indexOf(rootObject.searchExclusionArr, privates.modelFields[m], false) == -1)
                                    {
                                        if(!queryObjs[s])
                                            queryObjs[s] = []

                                        queryObjs[s].push({fieldName : privates.modelFields[m], value : val, op : 'contains', connector : 'OR'})
                                        //queryObj.push({fieldName : privates.modelFields[m], value : val, op : '==', connector : 'OR'})
                                    }
                                }
                            }
                        }



                        var indexArr = []
                        for(var q = 0; q < queryObjs.length; q++)
                        {
                            if(ZGlobal.functions.isUndef(queryObjs[q]))
                                continue

                            if(queryObjs[q].length > 0)
                            {
                                queryObjs[q][queryObjs[q].length - 1].connector = ''
                                var tempArr = ZGlobal._.values(lv.query(queryObjs[q]))
                                if(q > 0 )
                                {
                                    var result = ZGlobal._.intersection(tempArr,indexArr)
                                    indexArr = result
                                }
                                else
                                    indexArr = tempArr
                            }
                        }

                        lv.hideAll()
                        lv.adjustIndices(indexArr)
                    }
                    else
                        lv.showAll()
                }

            }
        }
    }

    ListView
    {
        id : lv
        width : rootObject.width
        height : rootObject.height
        clip  : lv.title.length > 0

        Item  { id : lmContainer  }

        property string   title               : ""
        property int      status              : Component.Loading
        property color    highlightColor      : ZGlobal.style.info
        property int      cellHeight          : 40
        property color    borderColor         : ZGlobal.style.text.color1
        property int      borderWidth         : 1
        property var      ordering            : []
        property var      typeArr             : []
        property var      displayFunctions    : []
        property var      exclusionArr        : []
        property var      validArr            : []

        section.property: rootObject.sectionProperty
        section.criteria: ViewSection.FullString
        section.delegate: rootObject.sectionDelegate


        onModelChanged: if(model && !privates.mutex)
                        {
                            if(model.toString().toLowerCase().indexOf('listmodel') === -1)
                            {
                                privates.mutex = true

                                var lm = ZGlobal.functions.getQmlObject(['QtQuick 2.0'], 'ListModel{}', lmContainer)
                                var newOne = model
                                if(typeof model.length === 'undefined'){ //we got an object instead bro!!!
                                    newOne = ZGlobal._.toArray(newOne)
                                    console.log(model.toString(), "you gave me an array, objectifiying it", JSON.stringify(newOne,null,2))
                                    for(var i = 0; i < newOne.length ; i++){
                                        lm.append(newOne[i])
                                    }
                                }
                                else
                                    lm.append(newOne)

                                model = lm
                                privates.mutex = false
                            }

                            privates.generateModelFields()

                            if(ordering && ordering.length > 0)
                            {
                                privates.sortData()
                            }
                            else
                            {
                                privates.setVarArr()
                                //queryBuilder.model = privates.varArr
                                lv.status = Component.Ready
                            }
                        }

        onOrderingChanged    : if(ordering && ordering.length > 0)
                                   privates.sortData()
        Component.onCompleted: {
            lv.forceActiveFocus()
            privates.sortData()
        }

        focus : true
        Keys.onPressed :
        {
            if     (event.modifiers & Qt.ShiftModifier)       privates.shiftModifier = true
            if     (event.modifiers & Qt.ControlModifier)     privates.ctrlModifier = true

            event.accepted = true
        }

        //TODO : Fix this later. You need to release both keys (if both pressed) to register a release event!!
        Keys.onReleased:
        {
            if     (event.modifiers & !Qt.ShiftModifier)      privates.shiftModifier = false
            if     (event.modifiers & !Qt.ControlModifier)    privates.ctrlModifier  = false
            if     (!event.modifiers)                         privates.shiftModifier = privates.ctrlModifier = false

            event.accepted = true
        }


        highlight: Rectangle{
            id             : highlightRect
            visible        : lv.currentIndex != -1 && privates.selectedArr.length != 0
            y              : lv.currentItem.y
            z              : 100 + lv.count
            width          : lv.width
            height         : lv.cellHeight
            color          : "transparent"
            border.color   : lv.highlightColor
            border.width   : 1
        }


        function getDelegateInstanceAt(index){
            for(var i = 0; i < lv.contentItem.children.length ; i++)
            {
                var child = lv.contentItem.children[i]
                if(child.imADelegate && child._index === index)
                    return child
            }
            return null
        }
        function hideAll() {
//            console.log('hideAll called')
            for(var i = 0; i < model.count; i++)
            {
                var del = getDelegateInstanceAt(i)
                if(del)
                    hideDelegate(del)
            }
        }
        function showAll() {
//            console.log('showAll called')
            if(ZGlobal.functions.isUndef(model))
                return

            for(var i = 0; i < model.count; i++)
            {
                var del = getDelegateInstanceAt(i)
                if(del)
                    showDelegate(del)
            }
        }
        function adjustIndices(indexArr) {
            var totalIndices = new Array(lv.model.count)
            for(var i in indexArr)
            {
                var del = getDelegateInstanceAt(indexArr[i])
                if(del)
                {
                    showDelegate(del)
                    totalIndices.splice(indexArr[i],1)
                }
            }

            for(i in totalIndices)
            {
                del = getDelegateInstanceAt(i)
                hideDelegate(del)
            }
        }
        function delHasState(del, state){
            if(del === null)
                return false

            for(var s in del.states)
            {
                if(del.states[s].name === state)
                    return true
            }
            return false
        }
        function hideDelegate(del){
//            console.log('hiding delegate', del)
            if(delHasState(del,'minimized'))    del.state = 'minimized'
            else                                del.height = 0
        }
        function showDelegate(del){
            if(delHasState(del,'minimized'))    del.state = ''
            else                                del.height = rootObject.cellHeight
        }
        function query(queryObj)
        {
            if(model && model.count > 0 )
            {
                var indexArr = {}
                for(var i = 0; i < model.count; i++)
                {
                    var delInstance = getDelegateInstanceAt(i)
                    if(queryObj && queryObj.length > 0)
                    {
                        var elem = afterDisplayFunctions(model.get(i))  //we want to search on what is shown, not what is actual!
                        for(var q = 0; q < queryObj.length ; q++)
                        {
                            var boolThis = queryElem(elem[queryObj[q].fieldName], queryObj[q])
                            //var boolNext = (q + 1 != queryObj.length - 1) ? queryElem(elem[queryObj[q + 1].fieldName], queryObj[q + 1]) : true

                            if(queryObj[q].connector === "")
                            {
                                if(boolThis)   indexArr[i] = i
                                else           break

                                break
                            }
                            else if(queryObj[q].connector === "OR")
                            {
                                if(boolThis)
                                {
                                    indexArr[i] = i
                                    break
                                }   //continue on if one side of the predicate is false!!
                            }
                            else if(queryObj[q].connector == "AND")
                            {
                                if(!boolThis)
                                {
                                    break
                                }   //continue on if predicate is true only!!
                            }
                        }
                    }
                    else
                    {
                        showAll()
                        return indexArr
                    }
                }
                return indexArr
            }
        }

        function query2(queryObj)
        {
            if(model && model.count > 0 )
            {
                //console.log('RUNNING QUERY', JSON.stringify(queryObj,null,2))
                for(var i = 0; i < model.count; i++)
                {
                    var delInstance = getDelegateInstanceAt(i)
                    if(queryObj && queryObj.length > 0)
                    {
                        var elem = afterDisplayFunctions(model.get(i))  //we want to search on what is shown, not what is actual!
                        for(var q = 0; q < queryObj.length ; q++)
                        {
                            var boolThis = queryElem(elem[queryObj[q].fieldName], queryObj[q])
                            //var boolNext = (q + 1 != queryObj.length - 1) ? queryElem(elem[queryObj[q + 1].fieldName], queryObj[q + 1]) : true

                            if(queryObj[q].connector == "")
                            {
                                if(boolThis)   showDelegate(delInstance)// delInstance.height = rootObject.cellHeight
                                else           hideDelegate(delInstance)//delInstance.height = 0

                                break
                            }
                            else if(queryObj[q].connector == "OR")
                            {
                                if(boolThis)
                                {
                                    showDelegate(delInstance)
                                    //delInstance.height = rootObject.cellHeight
                                    break
                                }   //continue on if one side of the predicate is false!!
                            }
                            else if(queryObj[q].connector == "AND")
                            {
                                if(!boolThis)
                                {
                                    hideDelegate(delInstance)
                                    //delInstance.height = 0
                                    break
                                }   //continue on if predicate is true only!!
                            }
                        }
                    }
                    else
                        showDelegate(delInstance)
                        //delInstance.height = rootObject.cellHeight
                }
            }
        }

        //field, op, value, connector (in a querySegment) {op : '==' }, {op : '!='}, {op : '>'}, {op : '>='}, {op : '=<'}, {op : '<'}, {op :'contains'}, {op :'startsWith'} ,{op :'endsWith'}
        function queryElem(elemValue, querySegment)
        {
            var type = elemValue == null ? null : typeof elemValue
            if(type != null)
            {
//                console.log('dealing with',type, elemValue)
                //figure out what value is!
                if(type === 'string')           //most likely dealing with a string
                {
                    switch(querySegment.op)
                    {
                        case '=='            : if(elemValue.toLowerCase() == querySegment.value.toLowerCase()) return true; return false;
                        case '!='            : if(elemValue.toLowerCase() != querySegment.value.toLowerCase()) return true; return false;
                        case '>'             : if(elemValue.toLowerCase() >  querySegment.value.toLowerCase()) return true; return false;
                        case '>='            : if(elemValue.toLowerCase() >= querySegment.value.toLowerCase()) return true; return false;
                        case '<='            : if(elemValue.toLowerCase() <= querySegment.value.toLowerCase()) return true; return false;
                        case '<'             : if(elemValue.toLowerCase() <  querySegment.value.toLowerCase()) return true; return false;
                        case 'contains'      : if(elemValue.toLowerCase().indexOf(querySegment.value.toLowerCase()) != -1)    return true; return false;
                        case 'startsWith'    : if(elemValue.toLowerCase().indexOf(querySegment.value.toLowerCase()) == 0 )    return true; return false;
                        case 'endsWith'      : if(elemValue.toLowerCase().indexOf(querySegment.value.toLowerCase(), elemValue.length - querySegment.value.length) != -1 )   return true; return false;
                    }
                }
                else if(type === 'number')
                {
                    switch(querySegment.op)
                    {
                        case '=='            : if(elemValue == querySegment.value) return true; return false;
                        case '!='            : if(elemValue != querySegment.value) return true; return false;
                        case '>'             : if(elemValue >  querySegment.value) return true; return false;
                        case '>='            : if(elemValue >= querySegment.value) return true; return false;
                        case '<='            : if(elemValue <= querySegment.value) return true; return false;
                        case '<'             : if(elemValue <  querySegment.value) return true; return false;
                        case 'contains'      : if(elemValue.toString().toLowerCase().indexOf(querySegment.value.toString().toLowerCase()) != -1)    return true; return false;
                        case 'startsWith'    : if(elemValue.toString().toLowerCase().indexOf(querySegment.value.toString().toLowerCase()) == 0 )    return true; return false;
                        case 'endsWith'      : if(elemValue.toString().toLowerCase().indexOf(querySegment.value.toString().toLowerCase(), elemValue.toString().length - querySegment.value.toString().length) != -1 )   return true; return false;
                    }
                }
            }

            return false
        }


        function afterDisplayFunctions(elem)
        {
            var modElem = {}
            for(var e in elem)
            {
                if(lv.displayFunctions[e])     modElem[e] = lv.displayFunctions[e](elem[e])
                else                           modElem[e] = elem[e]
            }
            return modElem
        }


        delegate :  rootObject.delegate


        Component {
            id : sectionDelCmp
            ZBase_Text {
                width   : lv.width/2
                height  : lv.cellHeight/2
                text    : section
                visible : lv.title.length > 0
                color        : Qt.lighter(lv.borderColor)
                outlineColor : lv.borderColor
                outlineThickness:  1
                showOutlines: true
                fontColor    : Qt.darker(lv.borderColor)
                dText.font: ZGlobal.style.text.heading2
            }
        }

        Component {
            id : delCmp
            Item {
                id : delItemRoot
                Component.onCompleted: evaluate()
                width       : lv.width
                height      : lv.cellHeight

                property bool imADelegate : true
                property int _index : index
                function evaluate()
                {
//                    console.log('evaluating new delegate', lv.model.get(index).name)
                    var text = null
                    if(ZGlobal.functions.isUndef(privates.modelFields) || privates.modelFields.length === 0)
                        privates.generateModelFields()

                    for(var k = 0; k < privates.modelFields.length; k++) {
                        text = lv.model.get(index)[privates.modelFields[k]]
                        if(text !== null && typeof text !== 'undefined' && ZGlobal._.indexOf(lv.exclusionArr, privates.modelFields[k], false ) === -1)
                        {
                            var cmpName    = 'ZText'
                            var valueField = 'text'
                            var importArr  = ['QtQuick 2.4', 'Zabaat.UI.Wolf 1.1']
                            var typeInfo   = privates.getTypeInfo(privates.modelFields[k])

                            if(typeInfo)
                            {
                                cmpName = typeInfo.type
                                valueField = typeInfo.valueField

                                if(typeInfo.importArr)
                                {
                                    for(var t in typeInfo.importArr)
                                        importArr.push(typeInfo.importArr[t])
                                }
                            }

                            if(cmpName && valueField)
                            {
                                var delObj = ZGlobal.functions.getQmlObject(importArr, cmpName + "{ property string __fieldName : ''; property bool __overrideWidth : false; }", cmpRow)
                                    delObj.__fieldName = privates.modelFields[k]
                                //console.log(lv.model.get(index)[this.__fieldName])
                                delObj[valueField]  =   text

                                //Qt.binding(function()  { if(lv.displayFunctions[this.__fieldName]) return lv.displayFunctions[this.__fieldName](lv.model.get(index)[this.__fieldName])
                                   //                                                                                      return lv.model.get(index)[this.__fieldName] })

                                delObj.height       = Qt.binding(function() { return this.parent.height  })
                                if(delObj.hasOwnProperty('color'))          delObj.color        = Qt.binding(function() { return privates.colorFunc(index)   })
                                if(delObj.hasOwnProperty('outlineColor'))   delObj.outlineColor = Qt.binding(function() { return lv.borderColor      })

                                //finally, we override stuffs if we got an override command :D
                                if(typeInfo && typeInfo.override)
                                {
                                    for(var o in typeInfo.override)
                                    {
                                        delObj[o] = typeInfo.override[o]
                                        if(o === 'width')
                                            delObj.__overrideWidth = true
                                    }
                                }
                            }

                        }
                    }

                    //Now let's readjust their widths! If we weren't given an override to it!
                    for(var c = 0; c < cmpRow.children.length; c++) {
                        var child = cmpRow.children[c]
                        if(!child.__overrideWidth)
                            child.width = Qt.binding(function() { return (lv.width - lv.borderWidth) / cmpRow.children.length } )
                    }

                    delItemRoot.width = Qt.binding(function() { return cmpRow.getChildrenWidth()  } )

                }

                Row
                {
                    id : cmpRow
                    width  : parent.width
                    height : parent.height
                    anchors.centerIn: parent

                    function getChildrenWidth()
                    {
                        var width = 0
                        for(var c in children)
                        {
                            var child = children[c]
                            width += child.width
                        }
                        return width
                    }
                }


                //Guess we has to manually add borders cause this shiz be queerifyingly queer :P
                Rectangle {
                    id     : topBorder
                    width  : parent.width
                    height : lv.borderWidth
                    color  : lv.borderColor
                    visible : parent.height > 0
                    anchors.bottom: parent.top
                }

                Rectangle{
                    id     : bottomBorder
                    width  : parent.width
                    height : lv.borderWidth
                    color  : lv.borderColor
                    visible : parent.height > 0
                    anchors.top: parent.bottom
                }

                Rectangle {
                    id     : leftBorder
                    width  : lv.borderWidth
                    height : parent.height
                    color  : lv.borderColor
                    visible : parent.height > 0
                    anchors.left: parent.left
                }

                Rectangle {
                    id     : rightBorder
                    width  : lv.borderWidth
                    height : parent.height
                    color  : lv.borderColor
                    visible : parent.height > 0
                    anchors.right: parent.right
                }

                MouseArea
                {
                    anchors.fill: parent;
                    enabled : parent.height > 0
                    onClicked: {
                        if(!privates.shiftModifier && !privates.ctrlModifier)
                        {
                            privates.selectedLen = -1;
                            privates.selectedArr = [];
                            privates.selectedArr.push(index);
                            privates.shiftIndex  = -1;
                            privates.selectedLen = 1;
                        }
                        else if(privates.shiftModifier)  privates.shiftFunc(index);
                        else if(privates.ctrlModifier)   privates.ctrlFunc(index);

                        lv.currentIndex = index;
                        lv.forceActiveFocus()
                    }
                }
            }

        }




        QtObject
        {
            id : privates
            property bool     mutex               : false
            property bool     shiftModifier       : false
//            onShiftModifierChanged: console.log(shiftModifier)

            property bool     ctrlModifier        : false
            property int      shiftIndex          : -1
            property var      selectedArr         : []
            property int      selectedLen         : 0
            property var      modelFields         : []
            property var      varArr              : []


            function generateModelFields(){
                if(model.count && model.count > 0)
                {
                    var itrLen = scanEntireModelForFields ? model.count : 1

                    for(var i = 0; i < itrLen; i++)      //we run this only once to build privatees.modelFIelds
                    {
                        if(!privates.modelFields)
                            privates.modelFields = []

                        var m = model.get(i)
                        if(ZGlobal._.isArray(validArr) && validArr.length > 0){
                            exclusionArr         = searchExclusionArr = ZGlobal.functions.getProperties(m, validArr)
                            privates.modelFields = validArr
                        }
                        else{
                            for(var k in m)
                            {
                                if(k !== 'objectName'        &&   k !== 'objectNameChanged'    &&
                                   k.indexOf("__") === -1    &&   typeof m[k] !== 'function'  &&  ZGlobal._.indexOf(privates.modelFields,k,false) === -1)
                                {
                                    privates.modelFields.push(k)
                                }
                            }
                        }
                    }
                }
            }

            function sortData(){
                if(model)
               {
                   //now let's deal with the ordering
                   if(lv.ordering && lv.ordering.length > 0)
                   {
                       var temp = ZGlobal._.sortBy(privates.modelFields,function(element)
                       {
                           var index = ZGlobal._.indexOf(lv.ordering, element,false)
                           if(index != -1)
                               return index
                           return lv.ordering.length
                       })
                       privates.modelFields = temp
                   }
               }
               setVarArr()
                //queryBuilder.model = privates.varArr
               lv.status = Component.Ready
            }

            function setVarArr()
            {
                var temp = []
                for(var i = 0; i < modelFields.length; i++)
                {
                    if(ZGlobal._.indexOf(rootObject.searchExclusionArr, modelFields[i], false) == -1)
                        temp.push({varName : modelFields[i]})
                }
                varArr = temp
                //console.log(JSON.stringify(varArr,null,2))
            }

            function ctrlFunc(index){
                for(var s in selectedArr)
                {
                    if(selectedArr[s] == index)
                    {
                        selectedArr.splice(s,1)
                        selectedLen--
                        return
                    }
                }

                selectedArr.push(index)
                selectedLen++
            }

            function shiftFunc(index){
                if(privates.shiftIndex == -1)
                    privates.shiftIndex = lv.currentIndex

                selectedArr = []
                selectedArr.push(lv.shiftIndex)
                selectedLen = 1

                if(privates.shiftIndex > index)
                {
                    for(var i = privates.shiftIndex; i >= index; i--)
                    {
                        selectedArr.push(i)
                        selectedLen++
                    }
                }
                else
                {
                    for(i = privates.shiftIndex; i <= index; i++)
                    {
                        selectedArr.push(i)
                        selectedLen++
                    }
                }
            }

            function colorFunc(index) {
                for(var s = 0; s < selectedLen; s++)
                {
                    if(selectedArr[s] == index)
                        return Qt.lighter(lv.highlightColor)
                }

                return 'white'
            }

            function getTypeInfo(key)
            {
                for(var t in typeArr)
                {
                    if(t === key)
                        return typeArr[t]
                }
                return null
            }

        }

        function getSelectedArr()
        {
            var objArray = []
            for(var i = 0; i < privates.selectedArr.length; i++)
               objArray.push( lv.model.get(privates.selectedArr[i]))
            return objArray;
        }
    }



}




/*





*/
