import Zabaat.UI.Wolf 1.1
import QtQuick 2.4
import QtQuick.Controls 1.3
import "../Global"



FocusScope {
    id : moneyAdder
    width : 400
    height : 1000

    property int cellHeight : height/ 8
    property var model : null
    onModelChanged: {
        if(model){
            var type = ZGlobal.functions.getType(model)

            var coins
            var cash

            //this should be an array of length two or an object with 2 properties (that contain arrays)
            if(type === 'array'){
                if(model[0])        coins = model[0]
                if(model[1])        cash  = model[1]
            }
            else if(type === 'object') {
                if(model.coins)     coins = model.coins
                if(model.cash)      cash = model.cash
            }
            else if(type === 'listmodel'){
                if(model.count > 0)     coins = model.get(0)
                if(model.count > 1)     cash = model.get(1)
            }

            resetAll()

            if(coins){
                centAdder.text    = coins[0] ? coins[0] : "0"
                nickelAdder.text  = coins[1] ? coins[1] : "0"
                dimeAdder.text    = coins[2] ? coins[2] : "0"
                quarterAdder.text = coins[3] ? coins[3] : "0"
            }

            if(cash) {
                dollarAdder.text        = cash[0] ? cash[0] : "0"
                fiveDollarAdder.text    = cash[1] ? cash[1] : "0"
                tenDollarAdder.text     = cash[2] ? cash[2] : "0"
                twentyDollarAdder.text  = cash[3] ? cash[3] : "0"
                fiftyDollarAdder.text   = cash[4] ? cash[4] : "0"
                hundredDollarAdder.text = cash[5] ? cash[5] : "0"
            }

        }
    }

    property color labelBgColor   : "#555555"
    property color labelTextColor : "white"
    property alias total          : mainTotalBox.val



    Row {
        id : moneyRow
        width : parent.width
        height : parent.height - totalsItem.height

        property bool rowMutex : false

        Column {
            width : parent.width /2 - parent.spacing
            height : parent.height

            ZText {
                height : moneyAdder.cellHeight /2
                width : parent.width * (1 - centAdder.inputAreaRatio)
                outlineLeft.visible: true
                outlineTop.visible: true
                outlineRight.visible: true
                outlineColor: 'black'
                outlineThickness: 1
                text : "Cents"
                color : moneyAdder.labelBgColor
                fontColor: moneyAdder.labelTextColor
            }
            ZTextBox {
                id : centAdder
                width  : parent.width
                height : moneyAdder.cellHeight

                state                : 'left'
                labelName            : '1c'
                text                 : "0"
                textInputStyle       : Qt.ImhDigitsOnly
                property double val  : Number(text)
                outlineVisible       : false
                haveLabelRect        : true
                labelColorBg         : ZGlobal.style.accent
                labelColor           : ZGlobal.style.text.color2
                activeFocusOnTab     : true
                Keys.onDownPressed   : nickelAdder.forceActiveFocus()
                Keys.onUpPressed     : quarterAdder.forceActiveFocus()
                onFocusChanged: if(focus) dTextInput.selectAll()
                onTextChanged        :
                {
                    text = ZGlobal.functions.numbersOnly(text)
                    if(!moneyRow.rowMutex && mainTotalBox && ZGlobal.functions.isDef(mainTotalBox.z))
                        mainTotalBox.z = 999
                }


            }
            ZTextBox {
                id : nickelAdder
                width  : parent.width
                height : moneyAdder.cellHeight

                state             : 'left'
                labelName         : '5c'
                text              : "0"
                textInputStyle    : Qt.ImhDigitsOnly
                property double val  : Number(text) * 5
                outlineVisible: false
//                    activeFocusOnTab: true
                Keys.onDownPressed: dimeAdder.forceActiveFocus()
                Keys.onUpPressed  : centAdder.forceActiveFocus()
                 haveLabelRect        : true
                 labelColorBg         : ZGlobal.style.accent
                 labelColor           : ZGlobal.style.text.color2
                onFocusChanged: if(focus) dTextInput.selectAll()
                onTextChanged        :
                {
                    text = ZGlobal.functions.numbersOnly(text)
                    if(!moneyRow.rowMutex && mainTotalBox && ZGlobal.functions.isDef(mainTotalBox.z))
                        mainTotalBox.z = 999
                }
            }
            ZTextBox {
                id : dimeAdder
                width  : parent.width
                height : moneyAdder.cellHeight

                state             : 'left'
                labelName         : '10c'
                text              : "0"
                textInputStyle    : Qt.ImhDigitsOnly
                property double val  : Number(text) * 10
                outlineVisible: false
//                    activeFocusOnTab: true
                Keys.onDownPressed: quarterAdder.forceActiveFocus()
                Keys.onUpPressed  : nickelAdder.forceActiveFocus()
                 haveLabelRect        : true
                 labelColorBg         : ZGlobal.style.accent
                 labelColor           : ZGlobal.style.text.color2
                onFocusChanged: if(focus) dTextInput.selectAll()
                onTextChanged        :
                {
                    text = ZGlobal.functions.numbersOnly(text)
                    if(!moneyRow.rowMutex && mainTotalBox && ZGlobal.functions.isDef(mainTotalBox.z))
                        mainTotalBox.z = 999
                }
            }
            ZTextBox {
                id : quarterAdder
                width  : parent.width
                height : moneyAdder.cellHeight

                state             : 'left'
                labelName         : '25c'
                text              : "0"
                textInputStyle    : Qt.ImhDigitsOnly
                property double val  : Number(text) * 25
                outlineVisible: false
//                    activeFocusOnTab: true
                Keys.onDownPressed: centAdder.forceActiveFocus()
                Keys.onUpPressed  : dimeAdder.forceActiveFocus()
                 haveLabelRect        : true
                onFocusChanged: if(focus) dTextInput.selectAll()
                onTextChanged        :
                {
                    text = ZGlobal.functions.numbersOnly(text)
                    if(!moneyRow.rowMutex && mainTotalBox && ZGlobal.functions.isDef(mainTotalBox.z))
                        mainTotalBox.z = 999
                }
            }
        }
        Column {
            width : parent.width /2 - parent.spacing
            height : parent.height

            ZText {

                height : moneyAdder.cellHeight/2
                width : parent.width * (1 - centAdder.inputAreaRatio)
                outlineLeft.visible: true
                outlineTop.visible: true
                outlineRight.visible: true
                outlineColor: 'black'
                outlineThickness : 1
                text : "Dollars"
                color : moneyAdder.labelBgColor
                fontColor: moneyAdder.labelTextColor
            }

            ZTextBox {
                id : dollarAdder
                width  : parent.width
                height : moneyAdder.cellHeight

                state                : 'left'
                labelName            : '$1'
                text                 : "0"
                textInputStyle       : Qt.ImhDigitsOnly
                property double val  : Number(text) * 100
                outlineVisible       : false
                 haveLabelRect        : true
                activeFocusOnTab     : true
                Keys.onDownPressed   : fiveDollarAdder.forceActiveFocus()
                Keys.onUpPressed     : hundredDollarAdder.forceActiveFocus()
                onFocusChanged: if(focus) dTextInput.selectAll()
                onTextChanged        :
                {
                    text = ZGlobal.functions.numbersOnly(text)
                    if(!moneyRow.rowMutex && mainTotalBox && ZGlobal.functions.isDef(mainTotalBox.z))
                        mainTotalBox.z = 999
                }
            }
            ZTextBox {
                id : fiveDollarAdder
                width  : parent.width
                height : moneyAdder.cellHeight

                state             : 'left'
                labelName         : '$5'
                text              : "0"
                textInputStyle    : Qt.ImhDigitsOnly
                property double val  : Number(text) * 500
                outlineVisible: false
//                    activeFocusOnTab: true
                Keys.onDownPressed: tenDollarAdder.forceActiveFocus()
                Keys.onUpPressed  : dollarAdder.forceActiveFocus()
                 haveLabelRect        : true
                onFocusChanged: if(focus) dTextInput.selectAll()
                onTextChanged        :
                {
                    text = ZGlobal.functions.numbersOnly(text)
                    if(!moneyRow.rowMutex && mainTotalBox && ZGlobal.functions.isDef(mainTotalBox.z))
                        mainTotalBox.z = 999
                }
            }
            ZTextBox {
                id : tenDollarAdder
                width  : parent.width
                height : moneyAdder.cellHeight

                state             : 'left'
                labelName         : '$10'
                text              : "0"
                textInputStyle    : Qt.ImhDigitsOnly
                property double val  : Number(text) * 1000
                outlineVisible: false
//                    activeFocusOnTab: true
                Keys.onDownPressed: twentyDollarAdder.forceActiveFocus()
                Keys.onUpPressed  : fiveDollarAdder.forceActiveFocus()
                 haveLabelRect        : true
                onFocusChanged: if(focus) dTextInput.selectAll()
                onTextChanged        :
                {
                    text = ZGlobal.functions.numbersOnly(text)
                    if(!moneyRow.rowMutex && mainTotalBox && ZGlobal.functions.isDef(mainTotalBox.z))
                        mainTotalBox.z = 999
                }
            }
            ZTextBox {
                id : twentyDollarAdder
                width  : parent.width
                height : moneyAdder.cellHeight

                state             : 'left'
                labelName         : '$20'
                text              : "0"
                textInputStyle    : Qt.ImhDigitsOnly
                property double val  : Number(text) * 2000
                outlineVisible: false
//                    activeFocusOnTab: true
                Keys.onDownPressed: fiftyDollarAdder.forceActiveFocus()
                Keys.onUpPressed  : tenDollarAdder.forceActiveFocus()
                 haveLabelRect        : true
                onFocusChanged: if(focus) dTextInput.selectAll()
                onTextChanged        :
                {
                    text = ZGlobal.functions.numbersOnly(text)
                    if(!moneyRow.rowMutex && mainTotalBox && ZGlobal.functions.isDef(mainTotalBox.z))
                        mainTotalBox.z = 999
                }
            }
            ZTextBox {
                id     : fiftyDollarAdder
                width  : parent.width
                height : moneyAdder.cellHeight

                state             : 'left'
                labelName         : '$50'
                text              : "0"
                textInputStyle    : Qt.ImhDigitsOnly
                property double val  : Number(text) * 5000
                outlineVisible: false
//                    activeFocusOnTab: true
                Keys.onDownPressed: hundredDollarAdder.forceActiveFocus()
                Keys.onUpPressed  : twentyDollarAdder.forceActiveFocus()
                 haveLabelRect        : true
                onFocusChanged: if(focus) dTextInput.selectAll()
                onTextChanged        :
                {
                    text = ZGlobal.functions.numbersOnly(text)
                    if(!moneyRow.rowMutex && mainTotalBox && ZGlobal.functions.isDef(mainTotalBox.z))
                        mainTotalBox.z = 999
                }
            }
            ZTextBox {
                id     : hundredDollarAdder
                width  : parent.width
                height : moneyAdder.cellHeight

                state             : 'left'
                labelName         : '$100'
                text              : "0"
                textInputStyle    : Qt.ImhDigitsOnly
                property double val  : Number(text) * 10000
                outlineVisible: false
//                    activeFocusOnTab: true
                Keys.onDownPressed: dollarAdder.forceActiveFocus()
                Keys.onUpPressed  : fiftyDollarAdder.forceActiveFocus()
                 haveLabelRect        : true
                onFocusChanged: if(focus) dTextInput.selectAll()
                onTextChanged        :
                {
                    text = ZGlobal.functions.numbersOnly(text)
                    if(!moneyRow.rowMutex && mainTotalBox && ZGlobal.functions.isDef(mainTotalBox.z))
                        mainTotalBox.z = 999
                }
            }

        }
    }
    Item {
        id : totalsItem
        width : parent.width
        height : moneyAdder.cellHeight
        y : moneyRow.height

        ZTextBox {
            id : totalEditor
            width : parent.width
            height : moneyAdder.cellHeight

            labelName : "Total ($)"
            state : "left"
            haveLabelRect        : true
            outlineVisible: false
            text : "0"
            property double val : Number(text) * 100

            z : mainTotalBox.z === 0 ? 999 : 0
            visible : z === 999

            property bool mutex : false
            onValChanged : {
                if(!mutex){
                    if(val !== null && !isNaN(val)) {

                        moneyRow.rowMutex = true

                        moneyAdder.resetAll()
                        var dollars = (val / 100).toFixed()
                        var cents   = val % 100

//                            console.log(val, dollars, cents)

                        centAdder.text   = cents
                        dollarAdder.text = dollars


                        moneyRow.rowMutex = false
                    }
                }
            }


            onAccepted : if(mainTotalBox && ZGlobal.functions.isDef(mainTotalBox.z))
                            mainTotalBox.z = 0

        }
        ZTextBox {
            id : mainTotalBox
            width : parent.width
            height : moneyAdder.cellHeight

            labelName : "Total ($)"
            state : "left"
            haveLabelRect        : true
            outlineVisible: false
            isEnabled: false
            z : 999
            visible : z === 999

            property double val : centAdder.val + nickelAdder.val + dimeAdder.val + quarterAdder.val +
                                dollarAdder.val + fiveDollarAdder.val + tenDollarAdder.val + twentyDollarAdder.val +
                                fiftyDollarAdder.val + hundredDollarAdder.val

            text : ZGlobal.functions.moneyify(val/100)
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
        centAdder.text = nickelAdder.text = dimeAdder.text = quarterAdder.text =
        dollarAdder.text = fiveDollarAdder.text = tenDollarAdder.text = twentyDollarAdder.text =
        fiftyDollarAdder.text = hundredDollarAdder.text = "0"
    }
    function formObject(giefObject) {
        var coins = [Number(centAdder.text), Number(nickelAdder.text), Number(dimeAdder.text), Number(quarterAdder.text)]
        var cash  = [Number(dollarAdder.text), Number(fiveDollarAdder.text), Number(tenDollarAdder.text),
                     Number(twentyDollarAdder.text), Number(fiftyDollarAdder.text), Number(hundredDollarAdder.text) ]

        if(giefObject)
            return {coins : coins, cash : cash}
        return [coins, cash]
    }

}
