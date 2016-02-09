import Zabaat.Misc.Global 1.0
import QtQuick 2.4
import Zabaat.Misc.Util 1.0

//expects a list of {title:<some title>, amount:<some amount>, color:<some hex string> } objects
//color can be left empty if you wanna appeal to the RNG gods

Item {
    id : rootObject

    property var dispFunc : null
    property var model    : null
    width : 400
    height : 32

    property color amountColor : ZGlobal.style.text.color1
    property color labelColor  : ZGlobal.style.text.color2
    property int   amountFontPxSize  : rootObject.height/6

    onModelChanged : {
        if(model){
            lm.clear()
            if(ZGlobal.functions.getType(model) === 'listmodel'){
                lv.model = model
            }
            else{
                var myItr = new ZIterator.ZIterator(model)
                while(myItr.hasNext()){
                    privates.addItem(myItr.next())
                }
                lv.model = lm
            }
        }
    }

    QtObject {
        id : privates

        function addItem(item){
           if(item && typeof item === 'object'){
               var listObj = {}
               listObj.amount    = ZGlobal.functions.isDef(item.amount) ? item.amount  : 0
               listObj.title     = ZGlobal.functions.isDef(item.title)  ? item.title   : "N/A"
               listObj.itemColor = ZGlobal.functions.isDef(item.color)  ? item.color   : undefined
               lm.append(listObj)
           }
        }
    }
    ListView {
        id : lv
        anchors.fill: parent
        orientation : ListView.Horizontal
        model       : lm

        ListModel { id : lm; dynamicRoles : true  }

        function getTotal() {
            var newTotal = 0
            var myItr = new ZIterator.ZIterator(lv.model)
            while(myItr.hasNext())
                newTotal += Number(myItr.next().amount)

            delTotal = newTotal
//            console.log(delTotal)
        }

        property int delTotal : 0

        delegate : ZTextBox{
            id : delItem
            property bool imADelegate : true
            property int _index       : index

            visible: width > 0
            width  : lv.delTotal > 0 && Number(amount) !== null ? lv.width * Number(amount) / lv.delTotal :
                                                                  lv.width / lv.count
            height : lv.height
//            onWidthChanged: if(_index === 0 && lv.delTotal > 0 && Number(amount) !== null ) console.log(lv.width,'*',Number(amount),  '/', lv.count,'=', width)

            Behavior on width {
                NumberAnimation {
                    duration : 333
                    easing { type : Easing.OutBounce ; overshoot : 200 }
                }
            }


            font.pixelSize: rootObject.amountFontPxSize

            outlineVisible : false
            labelName  : title
            color      : typeof itemColor !== 'undefined' ? itemColor : Qt.rgba(Math.random(), Math.random(), Math.random())
            text       : rootObject.dispFunc ? rootObject.dispFunc(amount) : amount
            onTextChanged: if(Number(amount) !== null)
                               lv.getTotal()

            isEnabled  : false
            state      : 'top'
            labelColor : rootObject.labelColor
            fontColor  : rootObject.amountColor
        }
    }

    function moneyDisp(a){
        return  "$ " +  ZGlobal.functions.moneyify(a/100)
    }
}
