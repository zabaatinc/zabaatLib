import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls.Private 1.0
import QtQuick.Controls.Styles 1.3
import Zabaat.Misc.Global 1.0
import Zabaat.Misc.Util 1.0


/*! \brief Uses Qt's Combobox and provides some extra features. Takes in setupObj and shows all the values (of the properties therein) delimited by spaces.
           Normally this will hide the actual value field.
    \inqmlmodule Zabaat.UI.Wolf 1.0
    \code
        ZBase_ComboBoxQt
        {
            setupObj : [
                         { id : 0, firstName: 'Brett' , lastName: 'Ansite'},
                         { id : 1, firstName: 'Shahan', lastName: 'Kazi'}
                       ]
            actualValueField: 'id'
            initIndex : 1
            showValueField: true
        }
    \endcode
*/


//TODO, note the bug with ScrollView is From QT. It's a known issue. https://bugreports.qt.io/browse/QTBUG-40552
//If the model for the combobox is too large and thus requires scrolling, it will complain about null!
FocusScope{
    id : rootObject

    onFocusChanged: if(loader.item){
                          if(focus) {
                              loader.item.focus = true
                          }
                          else {
                              if(autoFillOnLostFocus && loader.item && ZGlobal.functions.isDef(loader.item.selectedIndex)){
                                  findAndSet(loader.item.dispText,null,true)
                              }
                              loader.item.focus = false
                          }
                    }


    property int status : Component.Loading
    property var self : this

    state : labelState
//    onVisibleChanged : console.log("combobox visibility changed", visible)


    /*! The property in the setupObj's objects that is the actual meaningful value. This will be reported in the answer property and not the other fields.*/
    property string actualValueField : "id"

    /*! The index at which to initate this combobox at (sets the currentIndex to this number when the combobox is made). SET THIS to -1 to not autoselect the first item. BRETT*/
    property int initIndex : 0

    /*! The val at which to initate this combobox at (sets the currentIndex to this number when the combobox is made)*/
    property string initVal : ""
//    onInitValChanged: console.log('my initval changed, i so gay', initVal)

    property var uniqueProperties : ['setupObj','actualValueField','initIndex','labelName','showValueField']
    property var uniqueSignals    : ({})


    /*! Makes the actualValueField visible in the combobox's line items. Defaults to false because most of the time this will be something like id.*/
    property bool showValueField : false


    /*! these are hidden from combobox displaying them */
    property var hiddenFields   :  []
//    onHiddenFieldsChanged: console.log('hiddenFields', hiddenFields)

    /*! these are the only fields the combobox will show. Essentially the other side of the coin of hiddenFields */
    property var showOnlyFields  : []
    property alias validArr      : rootObject.showOnlyFields
    onShowOnlyFieldsChanged      : if(setupObj && !myInitTimer.running) init()
    onShowValueFieldChanged      : if(setupObj && !myInitTimer.running) init()
    onSetupObjChanged            : if(setupObj && !myInitTimer.running) init()
//    onSetupObjCountChanged: {
//        if(setupObjCount !== -1)
//            init()
//    }

    Timer {
        id : myInitTimer
        interval : 100
        repeat : false
        running : true
        onTriggered : {
            if(rootObject.setupObj)
                rootObject.init()
        }

    }


    signal inputChanged(string text)
    signal accepted(string text)

    property bool activeFocusOnPress : true

    property string labelName    : ""                          /*! The label name to show under the combobox*/
    property string dropDownIcon : "\uf150"
    property real   labelMargin  : 5


    property color  textColor          : ZGlobal.style.text.color1
    property color  secondaryTextColor : ZGlobal.style.text.color2
    property color  labelColor         : ZGlobal.style.text.color1
    property color  color              : ZGlobal.style.text.color2
    property color  hoverColor         : ZGlobal.style.info

    property font   font               : ZGlobal.style.text.normal
    property string fontFamily         : ZGlobal.style.text.normal.family
    property int    fontSize           : ZGlobal.style.text.normal.pointSize
    property color  labelColorBg       : ZGlobal.style.accent
    property bool   haveLabelRect      : false


    property string labelState         : ""
    property int    maxPopupHeight     : height * 5

    property var    validator          : null

    property bool   customComboBox          : false
    property var    customComboboxComponent : null

    property alias  searchProperties        : _searchProperties
    property alias  search_key              : _searchProperties.key
    property alias  search_softSearch       : _searchProperties.softSearch
    property alias  search_searchHidden     : _searchProperties.searchHidden

    property bool   inputResponsiveOnStart  : false
    property bool   dropUp                  : false
    property bool   autoFillOnLostFocus     : false

    property string delimiter : ' '
    property bool   debug : false
    property double inputAreaRatio          : 2/3

    /*! The value that is reported when the user changes the currentIndex of the combobox. This is taken using actualValueField. If actualValueField is empty, this will report the entire text of the selected combobox line*/
    property string answer    : ""

    /*! The full jsObject or modelObject or array Object that is selected */
    property var  currentItem : null

    /*! The current index that is selected */
    property int    currentIndex            : 0
    onCurrentIndexChanged: {
        if(currentIndex > -1 && ZGlobal.functions.isDef(setupObj)){
            var item = privates.isListModel ? setupObj.get(currentIndex) : setupObj[currentIndex]
            if(ZGlobal.functions.isDef(item)){
//                console.log("OH THE ITEM IS DEFINED", actualValueField, JSON.stringify(item,null,2))
                if(typeof item !== 'object'){
                    answer = item
                }
                else if(actualValueField.length > 0){
                    var val = item[actualValueField]
                    if(ZGlobal.functions.isDef(val))
                        answer = val
                    else
                        answer = "im an undefined game and watch"
                }
                else
                    answer = 'N/A'

                currentItem = item
            }
            else{
                console.log("NO ITEM FOUND HERE. CAN U DIE NOW. GEE THANKS", currentIndex)
            }
        }
    }


    property var    listSelectionOnlyAddsTheseProperties : null
    property var    setupObj    : []
    property bool   canEdit     : true
    property var    queueFuncs  : []

    function init() {
        privates.model         = []

        if(ZGlobal.functions.isUndef(setupObj)) {
            if(loader.item)
                loader.item.model = null

            loader.sourceComponent = null
            return
        }

        rootObject.status = Component.Loading

        if(delimiter === "")
            delimiter = ' '


        privates.isListModel = !ZGlobal._.isArray(setupObj)
        var lenProperty = privates.isListModel ? 'count' : 'length'

        //iterate thru the model or array
        for(var i = 0; i < setupObj[lenProperty]; i++) {
            var elem = privates.isListModel ? setupObj.get(i) : setupObj[i]
            var str = ""

            //handle showOnlyFields. Builds hiddenFields and excludes showOnlyFields from it!
            if(i === 0 && ZGlobal._.isArray(showOnlyFields) && showOnlyFields.length > 0){
                hiddenFields = ZGlobal.functions.getProperties(elem, showOnlyFields)
            }

            if(typeof elem !== 'string') {
                for(var k in elem)
                {
                    if(ZGlobal._.indexOf(hiddenFields, k, false) === -1 && (showValueField || k !== actualValueField ) && (typeof elem[k] === 'string' || typeof elem[k] === 'number' ) )
                        str += elem[k] + delimiter
                }
                str = str.slice(0, -delimiter.length)
            }
            else
                str = elem

            if(str === '')
                str = i     //there's something wrong with your hidden fields or fields in general if this ever happens!

            privates.model.push(str)
        }


        var sourceCmp = !customComboBox ? qtCombobox : customComboboxComponent ? customComboboxComponent : customComponent
        if(ZGlobal.functions.isUndef(loader.item) || loader.sourceComponent !== sourceCmp)
            loader.sourceComponent = sourceCmp
        else
        {
            loader.item.model        = privates.model
            rootObject.currentIndex  = Qt.binding(privates.indexBinder)

            setIndex(-1)
            if(initIndex !== -2){
                if(initVal !== "")      privates.loadInitVal(initVal)
                else                    setIndex(initIndex)
            }

            rootObject.status = Component.Ready
        }

        if(queueFuncs.length > 0){
//            ZGlobal.functions.printObject(setupObj)
            for(var q = queueFuncs.length -1 ; q >= 0; q--){
                if(typeof queueFuncs[q] === 'function')
                    queueFuncs[q]();

                queueFuncs.splice(q,1)
            }
        }

    }
    function selectAll() {
        if(loader.item && loader.item.selectAll){
            loader.item.selectAll()
        }
    }
    function findAndSet(value, key_optional, softSearch, searchHidden){
        if(ZGlobal.functions.isUndef(key_optional))     key_optional = null
        if(ZGlobal.functions.isUndef(softSearch))       softSearch   = null
        if(ZGlobal.functions.isUndef(searchHidden))     searchHidden = null

        if(!softSearch) {
            var ind = getIndexOf(value, key_optional, softSearch, searchHidden)
            if(ind !== -1){
                if(loader.item) {
                    if(ZGlobal.functions.isDef(loader.item.selectedIndex))   loader.item.selectedIndex = ind
                    else                                                     loader.item.currentIndex  = ind
                }
                else{
                    initIndex = ind
                }
                return ind
            }
        }
        else {
            //first search if there's an exact match even if we are going to do a softSearch
            //that takes precedence over soft matches!
            ind = getIndexOf(value, key_optional, false, searchHidden)
            if(ind === -1)
                ind = getIndexOf(value, key_optional, true, searchHidden)

            if(ind !== -1){
                if(loader.item){
                    if(ZGlobal.functions.isDef(loader.item.selectedIndex))   loader.item.selectedIndex = ind
                    else                                                     loader.item.currentIndex  = ind
                }
                else{
                    initIndex = ind
                }
                return ind
            }
        }

        return -1
    }
    function getIndexOf(value, key_optional, softSearch, searchHidden){


//        var itr = new ZIterator.ZIterator(setupObj)
//        while(itr.hasNext()){
//            var item2 = itr.next()
//                console.log(JSON.stringify(item2,null,2))
//        }

        if(ZGlobal.functions.isUndef(value))
            return -1

        if(ZGlobal.functions.isUndef(setupObj))            return -1
        if(ZGlobal.functions.isUndef(softSearch))          softSearch = false


        var lenProperty = privates.isListModel ? 'count' : 'length'
        var valStr      = value.toString().toLowerCase()

//        console.log("FINDING", value , "in:", key_optional, softSearch, searchHidden)
        for(var s = 0; s < setupObj[lenProperty]; s++){
            var item = privates.isListModel ? setupObj.get(s) : setupObj[s]
//            console.log(JSON.stringify(item,null,2))

            if(ZGlobal.functions.isUndef(item))
                continue

            if(typeof item !== 'object' ){
                if(privates.delSearcher(item, valStr, softSearch))
                    return s
            }
            else if(ZGlobal.functions.isDef(key_optional) && ZGlobal.functions.isDef(item[key_optional])) {
                if(privates.delSearcher(item[key_optional],valStr, softSearch))
                    return s
            }
            else{
                for(var i in item){
                    if(!searchHidden && ZGlobal._.isArray(hiddenFields) && ZGlobal._.indexOf(hiddenFields,i,false) !== -1)
                        continue

                    if(!ZGlobal.functions.isUndef(item[i]) && typeof item[i] !== 'object' && privates.delSearcher(item[i], valStr, softSearch))
                        return s
                }
            }



        }
        return -1
    }
    function setIndex(idx, finalize){
//        console.log("SET INDEX CALLED", idx)
//        if(idx === -1)
//            console.trace()

        var lenProp = privates.isListModel ? "count" : "length"

        if(setupObj && idx < setupObj[lenProp] && loader.item){
            if(ZGlobal.functions.isDef(loader.item.selectedIndex))  {       //selected idx can be negative cause we so cUL
                loader.item.selectedIndex = idx
            }
            if(idx >= 0){
                loader.item.currentIndex = idx
//                console.log("SELECTED IDX" , idx, loader.item.currentIndex)
            }
        }

        if(finalize)
            initIndex = -20
    }
    function isListOpen() {
        if(loader.item) {
            if(customComboBox)         return loader.item.lvVisible
            return loader.item.dropdownVisible
        }
        return false
    }
    function setText(str){
        console.log(loader.sourceComponent === customComboboxComponent)
        console.log(loader.item)
        if(loader.sourceComponent === customComponent && loader.item){
            loader.item.dispText = str
        }
    }

    Loader{
        id : loader
        width : rootObject.width
        height : rootObject.height
        visible : parent.visible
        enabled : parent.visible
        sourceComponent: null
        onLoaded: {
            item.model               = privates.model
            item.width               = Qt.binding(function() { return loader.width } )
            item.height              = Qt.binding(function() { return loader.height } )

            rootObject.currentIndex  = Qt.binding(privates.indexBinder)

            setIndex(-1)
            if(initIndex != -2) {
                if(initVal !== "")                privates.loadInitVal(initVal)
                else                              setIndex(initIndex)
            }


            rootObject.status = Component.Ready
        }

        property var setLater : null
    }
    QtObject {
        id : privates

        property var model : []
        property bool isListModel : false
        function delSearcher(item1, item2, softSearch){
//            console.log(softSearch)
//            console.log(item1, item2, softSearch)
            item1 = item1.toString().toLowerCase()
//            console.log(item1, item2)

            if(item1 == item2)
                return true
            else if(softSearch){
                var ind = ZGlobal.functions.contains(item1, item2)
//                console.log(item1,item2, ind)
                if(ind !== -1)
                    return true
            }

            return false
        }
        function loadInitVal(initVal){
//            console.trace()
            if(initVal !== ""){
                var ind = getIndexOf(initVal, _searchProperties.key, false, true)
                if(ind !== -1)
                    initIndex = ind
            }

            if(ZGlobal.functions.isDef(loader.item.selectedIndex))   loader.item.selectedIndex = loader.item.currentIndex = initIndex
            else                                                     loader.item.currentIndex = initIndex

//            console.log('loading initVal')
        }
        function indexBinder(){
            if(loader.item) {
                if(ZGlobal.functions.isDef(loader.item.selectedIndex))
                    return loader.item.selectedIndex;
                else
                    return loader.item.currentIndex;
            }

            return -1;
        }
    }
    QtObject {
        id : _searchProperties
        property var key           : null
        property bool softSearch   : true
        property bool searchHidden : false
    }
    Component{
        id : qtCombobox
        ComboBox
        {
            id : comby
            activeFocusOnPress : rootObject.activeFocus
            width : 100
            height : 400

            property string labelName           : rootObject.labelName
            property string dropDownIcon        : rootObject.dropDownIcon
            property string labelState          : rootObject.labelState
            property color  textColor           : rootObject.textColor
            property color  secondaryTextColor  : rootObject.secondaryTextColor
            property color  labelColor          : rootObject.labelColor
            property color  color               : rootObject.secondaryTextColor
            property color  hoverColor          : rootObject.hoverColor
            property font   font                : rootObject.font
            property string fontFamily          : rootObject.fontFamily
            property int    fontSize            : rootObject.fontSize
            property bool   haveLabelRect       : rootObject.haveLabelRect
            property color  labelColorBg        : rootObject.labelColorBg
            property real   labelMargin         : rootObject.labelMargin
            property int    maxPopupHeight      : rootObject.maxPopupHeight
            focus                               : rootObject.focus
            property bool  dropdownVisible      : comby.__popup.__popupVisible
            enabled : rootObject.enabled

            function __click(){
                comby.__popup.toggleShow()
            }

            Keys.onEnterPressed : __click()
            Keys.onReturnPressed: __click()
            Keys.onSpacePressed : __click()


            style : ComboBoxStyle{
                id : style
                background: Item {
                    width   : style.control ?  style.control.width : comby.width
                    height  : style.control ?  style.control.height : comby.height

                    property bool   hovered  : style.control ? style.control.hovered : false
                    property bool   pressed  : style.control ? style.control.pressed : false


                    ZBase_TextBox{
                        id : btn
                        anchors.fill: parent
                        text          : style.control ? style.control.currentText : "N/A"
                        fontColor     : style.control.textColor
                        border.color  : style.control.focus                  ? style.control.hoverColor     : 'black'
                        color         : style.control && style.control.focus ? style.control['hoverColor']  : style.control['color']
                        font.family   : style.control ? style.control.fontFamily : "Courier"
                        font.pointSize: style.control ? style.control.fontSize   : 12
                        enabled : false
                        haveLabelRect : style.control       ? style.control.haveLabelRect : false
                        state         : style.control       ? style.control.labelState : ''
        //                onStateChanged: console.log(state)
                        labelName     : style.control ? style.control.labelName : ''
                        outlineVisible: false
                    }
                    ZBase_Text{
                        color : 'transparent'
                        fontColor           : btn.fontColor
                        text                : style.control.dropDownIcon
//                        enabled : comby.enabled

                        property string _state : btn.state
                        dText.font.family     : style.control ? style.control.fontFamily : "Courier"
                        fontSize: style.control ? style.control.fontSize : 12
                        anchors.right         : parent.right
                        anchors.rightMargin   : _state === 'right' ? btn.dLabelRect.width + 3  : 3
                        anchors.top           : parent.top
                        anchors.topMargin     : _state === 'top'  ? btn.dLabelRect.height : 0

                        height                : btn.dInputBg.height
                        width                 : dText.paintedWidth

                    }

                }

                label : Item{}
                font           : style.control.font
                selectionColor : style.control.hoverColor

                property Component __dropDownStyle : MenuStyle {
                    id : menuStyle
                    __maxPopupHeight : comby.maxPopupHeight
                    __menuItemType   : 'comboboxitem'
                    __backgroundColor : 'transparent'

//                    font : ZGlobal.style.text.normal

                    itemDelegate.background: ZBase_TextBox{
                        text : styleData.text
                        color :  styleData.selected ? style.control['hoverColor']  : style.control['color']
                        fontColor :  styleData.selected ? style.control.secondaryTextColor : style.control.textColor
                        width : comby.width
                        height : style.control.height/2
                        labelName : ""

                        outlineVisible: false
                        enabled : false
                        border.width: 0
                        fontFamily: style.control.fontFamily
                        font.pointSize: style.control.fontSize

                        labelColorBg  : style.control       ?  style.control.labelColorBg : 'green'
                    }

                    itemDelegate.label:
                        Item {  width : style.control.width;  height : style.control.height/2  }
                }


            }

            MouseArea{
                anchors.fill: parent
                onClicked : comby.__click()
            }
        }



    }
    Component {
        id : customComponent
        FocusScope{
            id : col
            width : loader.width
            height : loader.height

            //the default one is a searcher
            property string labelName           : rootObject.labelName
            property string dropDownIcon        : rootObject.dropDownIcon
            property string labelState          : rootObject.labelState
            property color  textColor           : rootObject.textColor
            property color  secondaryTextColor  : rootObject.secondaryTextColor
            property color  labelColor          : rootObject.labelColor
            property color  labelColorBg        : rootObject.labelColorBg

            property color  color               : rootObject.color
            property color  hoverColor          : rootObject.hoverColor
            property font   font                : rootObject.font
            property string fontFamily          : rootObject.fontFamily
            property int    fontSize            : rootObject.fontSize
            property bool   haveLabelRect       : rootObject.haveLabelRect
            property bool   activeFocusOnPress  : rootObject.activeFocus
            property real   labelMargin         : rootObject.labelMargin
            property int    maxPopupHeight      : rootObject.maxPopupHeight
            property alias  model               : lv.model
            property alias  selectedIndex       : lv.selectedIndex
            property alias  currentIndex        : lv.currentIndex
            property bool   rootFocus           : rootObject.focus
            property var    validator              : rootObject.validator
            property bool   dropUp                 : rootObject.dropUp
            property bool   canEdit                : rootObject.canEdit
            property var    listSelectionOnlyAddsThese : rootObject.listSelectionOnlyAddsTheseProperties
            property string delimeter                  : rootObject.delimiter
            property alias  dispText                   : btn.text
            property alias  lvVisible : lv.visible
            property bool   autoFillOnLostFocus         : rootObject.autoFillOnLostFocus
            property double inputAreaRatio              : rootObject.inputAreaRatio

            function selectAll() {
                btn.dTextInput.selectAll();
                focusTimer.start()
            }

            enabled : rootObject.enabled
            onFocusChanged : {
                if(focus)
                    focusTimer.start()     //something else is stealing focus. //DERP find a way to remove this timer!
                else{

                }

            }

            Timer {
                id : focusTimer
                interval : 100
                repeat : false
                running : false
                onTriggered: btn.dTextInput.forceActiveFocus()
            }

            Item    {
                id : searcherBox
                width   : col.width
                height  : col.height

                ZBase_TextBox{
                    id : btn
                    anchors.fill: parent
                    color       : col.color
                    fontColor   : col.textColor
                    haveLabelRect : col.haveLabelRect
                    labelColor    : col.labelColor
                    labelColorBg  : col.labelColorBg
                    inputAreaRatio: col.inputAreaRatio
                    state         : col.labelState
                    font.family   : col.fontFamily ? col.fontFamily : "Courier"
                    font.pointSize: col.fontSize
                    labelName     : col.labelName
                    border.color  : col.focus ? col.hoverColor : 'black'
                    outlineVisible: false
                    dTextInput.validator: col.validator ? col.validator : null
                    property bool mutex     : false //col.inputResponsiveOnStart ? false : true
                    property string oldText : ""
                    property string chgText : ""


                    onCursorPositionChanged: show()
                    onClick                : show()
                    onTextChanged          : {
                        if(!mutex){
                            chgText   = text
                            lv.showLv = true
                            btn.focus = true
                            rootObject.inputChanged(chgText)
                            findAndSet(chgText, true)
                        }
                    }
                    onAccepted: accept()
                    isEnabled: canEdit

                    Keys.onUpPressed    : up()
                    Keys.onDownPressed  : dn()

                    function show()  {
                        if(!mutex)
                            lv.showLv = true
                    }
                    function accept(){
                        if(!mutex){
                            mutex = true

                            if(lv.currentItem){
                                findAndSet(chgText)
                                selectedIndex = lv.currentIndex
                                text = btn.oldText = lv.getText(lv.currentIndex)
                                rootObject.accepted(text)
                            }

                            lv.showLv = false
                            mutex = false
                        }
                    }
                    function up()    { show(); if(lv.currentIndex - 1 >= 0)             {lv.currentIndex-- ; chgText = lv.getText(lv.currentIndex);  }}
                    function dn()    { show(); if(lv.currentIndex + 1 <= lv.count - 1)  {lv.currentIndex++ ; chgText = lv.getText(lv.currentIndex);  }}
                    function findAndSet(text, onlyCurrentIndex){
                        var index = rootObject.getIndexOf(text, _searchProperties.key, false, _searchProperties.searchHidden)
                        if(index === -1 && _searchProperties.softSearch)
                            index = rootObject.getIndexOf(text, _searchProperties.key, true, _searchProperties.searchHidden)

                        if(index !== -1)
                        {
                            if(onlyCurrentIndex)  lv.currentIndex = index
                            else                  lv.currentIndex = lv.selectedIndex = index

                            return true
                        }
                        return false
                    }
                }
                ZBase_Text{
                    property string _state : btn.state
                    color                  : 'transparent'
                    fontColor              : btn.fontColor
                    fontSize               : btn.font.pointSize
                    dText.font.family: col.fontFamily
                    text                   : col.dropDownIcon

                    anchors.right         : parent.right
                    anchors.rightMargin   : _state === 'right' ? btn.dLabelRect.width + 3  : 3
                    anchors.top           : parent.top
                    anchors.topMargin     : _state === 'top'  ? btn.dLabelRect.height : 0

                    height                : btn.dInputBg.height
                    width                 : dText.paintedWidth

                    onHovered             : border.width = 2
                    onUnhovered           : border.width = 0
                    onClicked             : lv.showLv = !lv.showLv
                    visible : col.enabled
                }
            }
            ListView{
                id : lv
                width         : parent.width
                height        : col.maxPopupHeight
                clip          : true
                highlightMoveVelocity: height * 10000

                y : col.dropUp ? -height : btn.height
//                anchors.top   : !col.dropUp ? searcherBox.bottom : undefined
//                anchors.bottom: col.dropUp  ? searcherBox.top    : undefined

                cacheBuffer: lv.contentHeight > 0 ?  lv.contentHeight * 1000 : lv.height > 0 ? lv.height : 1000
                property bool showLv : false
                property int  selectedIndex : -1

                onSelectedIndexChanged: {
//                    console.log(selectedIndex)
                    if(selectedIndex !== -1 && btn.text !== lv.model[currentIndex] && ZGlobal.functions.isDef(lv.model[currentIndex])){
                        btn.mutex = true;
                        btn.text = btn.oldText = lv.model[currentIndex];
                        btn.mutex = false;
                    }
                }
                snapMode: ListView.SnapToItem
                enabled         : visible
                visible         : showLv && (col.rootFocus && col.focus)

                function getText(index) {
                    if(col.listSelectionOnlyAddsThese === null || typeof col.listSelectionOnlyAddsThese === 'undefined'){
                        return ZGlobal._.isArray(lv.model) ? lv.model[index] : lv.model.get(index)
                    }
                    else {
                        var item    = privates.isListModel ? setupObj.get(index) : setupObj[index]
                        var newText = ""
                        if(ZGlobal._.isArray(col.listSelectionOnlyAddsThese)){
                            for(var i = 0; i < col.listSelectionOnlyAddsThese.length; i++)
                            {
                                var prop = col.listSelectionOnlyAddsThese[i]
                                newText  = item[prop] + col.delimeter
                            }
                            newText = newText.slice(0, -col.delimeter.length)
                        }
                        else if(typeof col.listSelectionOnlyAddsThese === 'string'){
                            newText = item[col.listSelectionOnlyAddsThese]
                        }
                        return newText
                    }
                }

                focus         : false

                onFocusChanged: if(focus)
                                    btn.focus = true

                delegate : ZBase_Text{
                    width : lv.width
                    height : 40

                    property bool imADelegate : true
                    property int  _index      : index
                    color     : lv.selectedIndex === index ? Qt.lighter(col.hoverColor) : lv.currentIndex === index ? col.hoverColor : 'white'
                    text      : lv.model[index]
                    fontColor : lv.currentIndex === index ?  col.secondaryTextColor : col.textColor
                        //lv.selectedIndex === index ? Qt.lighter(col.hoverColor) : col.textColor//col.textColor
                    fontSize: col.fontSize
                    dText.font.family: col.fontFamily

                    border.width: 0
                    onClicked: {
//                        console.log("CLICKIYT CLICKY")
                        lv.currentIndex = lv.selectedIndex = _index
                        btn.text = btn.oldText = lv.getText(index)
                        lv.showLv = false

                    }

                    onHovered: lv.currentIndex = _index
                    Component.onCompleted: {
//                        lv.height = col.maxPopupHeight
                        //this has the job of setting the text up!
                        if(lv.selectedIndex !== -1 && lv.selectedIndex === index && ZGlobal.functions.isDef(lv.model[currentIndex]))
                        {
                            btn.mutex = true;
                            btn.text = btn.oldText = lv.model[currentIndex];
                            btn.mutex = false;
                        }
                    }
                }
            }
            Rectangle {
                id           : lvRect
                width        : parent.width
                height       : lv.contentHeight === 0 ? 0 : lv.contentHeight > lv.height ? lv.height : lv.contentHeight
                visible      : height > 0  && lv.visible
                border.width : 3
                color        : 'transparent'
                anchors.top  : lv.top
            }




        }
    }





}


