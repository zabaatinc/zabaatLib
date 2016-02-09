import Zabaat.UI.Wolf 1.1
import QtQuick 2.4
import QtQuick.Controls 1.3
import Zabaat.Misc.Util 1.0
import "../Global"

FocusScope {
    id : lineAdder
    width : 400
    height : 1000


    property color labelBgColor   : "#555555"
    property color labelTextColor : "white"
    property alias total          : mainTotalBox.val
    property string title         : "Credit Cards"
    property string delegateTitle : "Derp"
    property double moneyModifier : 100

    property int cellHeight : height/ 8
    property var model : null
    onModelChanged: {
        if(model){
            var itr = new ZIterator.ZIterator(model)
            while(itr.hasNext()){
                var item = itr.next()

                if(typeof item === 'number')                  lineAdder.appendLine(item)
                else if(ZGlobal.functions.isDef(item.amount)) lineAdder.appendLine(item.amount)
                else if(ZGlobal.functions.isDef(item.value))  lineAdder.appendLine(item.value)
            }
        }
    }

    ZText {
        id : titleBox
        width  : parent.width * (1/3)
        height : parent.cellHeight/2
        text   : parent.title

        outlineLeft.visible: true
        outlineTop.visible: true
        outlineRight.visible: true
        outlineBottom.visible: true
        outlineColor: 'black'
        outlineThickness: 1
        color : lineAdder.labelBgColor
        fontColor: lineAdder.labelTextColor

    }
    ListView {
        id : lv
        property bool rowMutex : false
        anchors.top: titleBox.bottom
        clip : true

        width : parent.width
        height : parent.height - totalsItem.height - titleBox.height

        Component.onCompleted:  lineAdder.appendLine(0)
        snapMode:                 ListView.SnapToItem
        highlightRangeMode:       ListView.ApplyRange

        model : ListModel {
            id : lm
        }

        function focusNext(idx){
            if(idx + 1 < lv.model.count) {
                var item = ZGlobal.functions.getDelegateInstance(lv, idx + 1)
                if(item) {
                    item.dTextInput.forceActiveFocus()
                }
            }
        }
        function focusPrev(idx) {
            if(idx - 1 < lv.model.count) {
                var item = ZGlobal.functions.getDelegateInstance(lv, idx - 1)
                if(item) {
                    item.dTextInput.forceActiveFocus()
                }
            }
        }

        property int nextFocusTarget : -1

        onCountChanged : {
            if(count > 0 && !rowMutex) {
                if(nextFocusTarget !== -1 && nextFocusTarget >= 0 &&  nextFocusTarget < count){
                    var item = ZGlobal.functions.getDelegateInstance(lv, nextFocusTarget)
                    if(item) {
                        item.dTextInput.forceActiveFocus()
                        nextFocusTarget = -1
                    }
                }
                else if(nextFocusTarget === -2)
                {
                    totalEditor.forceActiveFocus()
                    nextFocusTarget = -1
                }
            }
        }
        delegate : ZTextBox {
            id : delItem
            width  : parent.width
            height : lineAdder.cellHeight

            property bool imADelegate : true
            property int _index : index
            property double _value : value
            property bool hasInit : false


            state                : 'left'
            labelName            : label
            text                 : _value / moneyModifier


            outlineVisible       : false
            haveLabelRect        : true
            labelColorBg         : ZGlobal.style.accent
            labelColor           : ZGlobal.style.text.color2
            activeFocusOnTab     : true
            Keys.onDownPressed   : lv.focusNext(index)
            Keys.onUpPressed     : lv.focusPrev(index)
            onFocusChanged: if(focus) {dTextInput.selectAll() ; lv.currentIndex = index ;  }
            onAccepted: {
                if(index === lv.model.count - 1 )
                {
                    lv.nextFocusTarget = index + 1
                    lineAdder.appendLine(0)
                }
                else
                    lv.focusNext(index)

            }


            property double oldVal : 0
            property double val    : Number(text) * moneyModifier

            property bool textMutex : false
            onTextChanged:
            {
                if(!textMutex) {
                    textMutex = true

                    if(isNaN(text))
                        text = ZGlobal.functions.numbersOnly(text)

                    var num = Number(text)
                    if(num === null){
                        text = "0"
                        num = 0
                    }

                    lv.model.get(index).amount = num
                    textMutex = false
                }

            }
            onValChanged:  if(mainTotalBox && ZGlobal.functions.isDef(mainTotalBox.z)) {
                               mainTotalBox.val -= oldVal
                               mainTotalBox.val += val
                               oldVal = val
                               mainTotalBox.z    = 999
                           }


        }
    }

    Item {
        id : totalsItem
        width : parent.width
        height : lineAdder.cellHeight
        anchors.top : lv.bottom

        ZTextBox {
            id : totalEditor
            width : parent.width
            height : lineAdder.cellHeight

            labelName : "Total ($)"
            state : "left"
            haveLabelRect        : true
            labelColorBg         : ZGlobal.style.accent
            labelColor           : ZGlobal.style.text.color2
            outlineVisible: false
            text : "0"

            property double val : Number(text) * moneyModifier

            z : mainTotalBox.z === 0 ? 999 : 0
            visible : z === 999

            property bool mutex : false
            onValChanged : {
                if(!mutex){
                    if(val !== null && !isNaN(val)) {
                        if(lv.model.count > 1 || lv.model.count === 0){
                            lineAdder.resetAll()
                            lv.rowMutex = true
                            lv.nextFocusTarget = -2
                            lv.model.get(0).value = val

                            lv.rowMutex = false
                        }
                        else
                        {
                            lv.rowMutex = true
                            lv.model.get(0).value = val
                            lv.rowMutex = false
                        }
                    }
                }
            }


            onAccepted : if(mainTotalBox && ZGlobal.functions.isDef(mainTotalBox.z))
                            mainTotalBox.z = 0
        }
        ZTextBox {
            id : mainTotalBox
            width : parent.width
            height : lineAdder.cellHeight

            labelName : "Total ($)"
            state : "left"
            haveLabelRect        : true
            labelColorBg         : ZGlobal.style.accent
            labelColor           : ZGlobal.style.text.color2
            outlineVisible: false
            isEnabled: false
            z : 999
            visible : z === 999

            property double val : 0
            text : ZGlobal.functions.moneyify(val/moneyModifier)
            onClick: {
                z = 0

                totalEditor.mutex = true
                totalEditor.text = text
                totalEditor.mutex = false

                totalEditor.dTextInput.forceActiveFocus()
                totalEditor.dTextInput.selectAll()
            }
        }
    }

    function setTotal(total){
        totalEditor.text = total
    }
    function resetAll() {
        lv.model.clear()
        appendLine(0)
        mainTotalBox.val = 0
    }
    function formObject() {
        var retObj = []
        if(lv.model) {
            var itr = new ZIterator.ZIterator(lv.model)
            while(itr.hasNext()){
                retObj.push(itr.next().amount * moneyModifier)
            }
        }
        return retObj
    }
    function appendLine(val){
        if(lv && lv.model)
            lv.model.append({label :lineAdder.delegateTitle + " " + lv.model.count, value : val })
    }
}
