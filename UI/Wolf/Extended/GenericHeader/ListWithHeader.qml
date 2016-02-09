import QtQuick 2.4
import Zabaat.Misc.Global 1.0
import "../../"
import Zabaat.UI.Fonts 1.0

Item {
    id : rootObject
    signal doubleClicked(int index, var delegate, var modelItem)
    signal add()
    signal remove(int idx, var modelItem)
    signal edit  (int idx, var modelItem)

    property string title  : ""
    property var    fields : null
    property var    fields_names               : []
    property var    fields_displayFuncs        : ({})
    property var    fields_inverseDisplayFuncs : ({})
    property var    fields_font                : ({})
    property var    fields_widths              : ({})
    property var    fields_labels              : ({})
    property string fields_labelPosition       : ""
    property var    fields_alignments          : ({})
    property alias    model                    : lv.model
    property alias    editor                   : le
    property var    currentItem                : null
    property bool   haveEditor              : false
    property alias haveAdd                  : addBtn.visible
    property alias haveDelete               : deleteBtn.visible

    property bool   showIndices             : false
    property var    indexComponent          : null
    property string indexValueField         : "text"
    property bool headerHasBoxOnLeft : true

    GenericHeader_AdvancedProperties { id : adv }

    property int    total      : -1
    property int    cellHeight : 40

    onFields_namesChanged: if(fields && fields_names)  _header.model = _header.blankModel(fields_names)

    //aliases
    property alias  list         : lv
    property alias  header       : _header
    property alias  currentIndex : lv.currentIndex
    property alias  count        : lv.count
    property alias  advanced     : adv

    property alias  boxToTheLeft   : _headerBox.visible

    Item {
        id : myItem
        Component.onCompleted: ZGlobal.functions.fitToParent_Snug(this)



        ListView {
            id : lv
            width  : _header.width
            height : Math.min(maxHeight, potentialHeight)  //potentialHeight < maxHeight ? contentHeight : maxHeight
            clip   : rootObject.clip
            anchors.top: headerRow.bottom
            model : null

//            onContentYChanged: console.log("ContentY", contentY)

            property int maxHeight       : rootObject.height - (cellHeight * 2) + cellHeight/2
            property int potentialHeight : model ? modelType === 'array' ? model.length * cellHeight : model.count * cellHeight : 0
            property var modelType       : null
            onModelChanged: {
                console.log("HEY MY MODEL CHANGED")

                le.model       = null
                le.targetIndex = -1

                if(model) {
                    modelType = ZGlobal.functions.getType(model)
//                    console.log("M O D E L T Y P E ===" , modelType)
                }
            }

            function getme(idx){
                if(modelType === null) //TODO , make this better. double checking
                {
                    modelType = ZGlobal.functions.getType(model)
                }

                if(modelType === null || modelType === 'undefined')
                    return null

                if(modelType === 'listmodel')    return model.get(idx)
                else                             return model[idx]
            }

            onCurrentIndexChanged: {
                if(model === null || model.count === 0)
                    rootObject.currentItem =  null

                if(currentIndex !== -1) {
                    rootObject.currentItem = getme(currentIndex)
                }

            }
            delegate : GenericHeader {
                id      : delegate
                width   : lv.width
                height  : cellHeight

                property int _index       : index
                property bool imADelegate : true

                fields                    : rootObject.fields
                fields_widths             : rootObject.fields_widths
                fields_displayFuncs       : rootObject.fields_displayFuncs
                fields_inverseDisplayFuncs: rootObject.fields_inverseDisplayFuncs
                advanced {
//                    fields_typeOverride      : adv.fields_typeOverride
                    fields_override          : adv.fields_override
                    global_override          : adv.global_override
//                    fields_valueField        : adv.fields_valueField
//                    fields_addtlQml          : adv.fields_addtlQml
//                    fields_enabled           : adv.fields_enabled ? adv.fields_enabled : rootObject.fields
//                    fields_ignoreProperties  : adv.fields_ignoreProperties
//                    fields_dontBind          : adv.fields_dontBind
//                    itemType                 : adv.itemType
//                    valueField               : adv.valueField
//                    additionalItemProperties : adv.additionalItemProperties
//                    itemIsEnabled            : adv.itemIsEnabled
                }

                color    : lv.currentIndex === index ? ZGlobal.style.info         : 'transparent'
                fontColor: lv.currentIndex === index ? ZGlobal.style.text.color2 : ZGlobal.style.text.color1

                onClicked       : lv.currentIndex = index
                onDoubleClicked :{
                    lv.currentIndex = index
                    rootObject.doubleClicked(index, delegate, model)
                    if(haveEditor)
                        le.iSelect(delegate)
                }

                model : lv.modelType ? lv.getme(index) : null
                Loader {
                    width  : cellHeight
                    height : cellHeight

                    anchors.right: parent.left
                    sourceComponent: rootObject.showIndices ?  (rootObject.indexComponent ? rootObject.indexComponent : indexComponent) : null
                    onLoaded :{
                        item[rootObject.indexValueField] = Qt.binding(function() { return delegate._index })
                    }
                }


            }
        }
        ZTextBox {
            id : total
            width  : parent.width
            height : cellHeight
            anchors.top      : lv.top
            anchors.topMargin: lv.contentHeight + height/2
            labelName : ""
            state : 'left'
            dTextInput.horizontalAlignment: Text.AlignRight
            dTextInput.font: ZGlobal.style.text.heading2
            visible : rootObject.total !== -1

            outlineVisible: false
            enabled       : false
            text          : moneyFunc(rootObject.total)
            color         : "transparent"
            fontColor     : 'black'
        }
        LineEditor {
            id : le
            width                    : _header.width
            height                   : cellHeight * 2
            visible                  : targetIndex !== -1 && haveEditor

            property int targetIndex   : -1
            property var oldModelItem  : null

            fields                       : rootObject.fields
            fields_widths                : rootObject.fields_widths
            fields_displayFuncs          : rootObject.fields_displayFuncs
            fields_inverseDisplayFuncs   : rootObject.fields_inverseDisplayFuncs
            advanced {
                fields_typeOverride      : adv.fields_typeOverride
                fields_override          : adv.fields_override
                global_override          : adv.global_override
                fields_valueField        : adv.fields_valueField
                fields_addtlQml          : adv.fields_addtlQml
                fields_enabled           : adv.fields_enabled ? adv.fields_enabled : rootObject.fields
                fields_ignoreProperties  : adv.fields_ignoreProperties
                fields_dontBind          : adv.fields_dontBind
                itemType                 : adv.itemType
                valueField               : adv.valueField
                additionalItemProperties : adv.additionalItemProperties
                itemIsEnabled            : adv.itemIsEnabled
            }

            function iSelect(delItem){
                targetIndex = delItem._index
                x = Qt.binding(function(){ return delItem.mapToItem(myItem).x } )
                y = Qt.binding(function(){ return delItem.mapToItem(myItem).y } )   //TODO MAKE TIS SCROLL

                model = ZGlobal._.clone(delItem.model)
            }

            onClose: targetIndex = -1
            onSave: {
                rootObject.edit(targetIndex, le.filledModel(true))
                targetIndex = -1
            }
        }


        Row {
            id : headerRow
            width : parent.width + cellHeight /2  + spacing
            height : cellHeight
            spacing : 5

            GenericHeader {
                id : _header
                width : parent.width - cellHeight
                height : cellHeight

                fields         : rootObject.fields
                fields_widths  : rootObject.fields_widths
                onFieldsChanged: if(fields && fields_names)   model = blankModel(fields_names)
                color          : ZGlobal.style.accent

                ZText{
                    id : _headerBox
                    height : width
                    width : parent.height
                    text : ""
                    showOutlines: true
                    color : parent.color
                    outlineColor: 'black'
                    anchors.right: parent.left
                    outlineTop.visible: false
                    outlineRight.visible: false
                    visible: headerHasBoxOnLeft
    //                outlineBottom.visible: false
                }

            }
            Column {
                id : _headerBtns
                spacing : 5
                ZButton {
                    id : addBtn
                    width : cellHeight / 2
                    height : cellHeight / 2
                    text : ""
                    icon : FontAwesome.plus
                    onBtnClicked : add()
                }

                ZButton {
                    id : deleteBtn
                    width : cellHeight / 2
                    height : cellHeight / 2
                    text : ""
                    icon : FontAwesome.trash
                    onBtnClicked : remove(lv.currentIndex, lv.getme(lv.currentIndex))
                    defaultColor : ZGlobal.style.danger
                }
            }
        }

    }

    Component {
        id: indexComponent

        ZTextBox {
            labelName : ""
        }
    }


    function moneyFunc(a){
        return "$" + ZGlobal.functions.moneyify(a/100)
    }

}

