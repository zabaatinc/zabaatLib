import QtQuick 2.4
import Zabaat.UI.Wolf 1.1
import Zabaat.Misc.Global 1.0
import Zabaat.Misc.Util 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

ListView {
    id : rootObject
    width: 100
    height: 62

    property int cellHeight: 40
    property var del              : null
    property url delegateUrl      : ""
    property var selectedArr      : []
    property bool selectAllButton : true
//    property bool autoAdjustSize : true
//    clip : true

    signal selected(int index)
    signal unselected(int index)
    signal selectionChanged(int count)

    QtObject {
        id : functions

        function _select(listIdx){
            if(ZGlobal.functions.isDef(listIdx) && ZGlobal._.indexOf(selectedArr, listIdx, false) === -1){
                selectedArr.push(listIdx)
                checkboxList.check(listIdx)
                selected(listIdx)

                return 1
            }
            return 0
        }
        function _unselect(listIdx){
            if(ZGlobal.functions.isDef(listIdx)){
                var idx = ZGlobal._.indexOf(selectedArr, listIdx, false)
                if(idx !== -1) {
                    checkboxList.uncheck(listIdx)
                    selectedArr.splice(idx,1)   //TEST
                    unselected(listIdx)

                    return 1
                }
                return 0
            }
        }
    }

    function getSelected(functionReturnsObject){ //this means give me back an object instead of an array
        var retArr = []
        var retObj = {}
        if(selectedArr ){
            var itr = new ZIterator.ZIterator(model)
            for(var s = 0; s < selectedArr.length; s++){
                var item = itr.get(selectedArr[s])

                if(functionReturnsObject)  retObj[s] = item
                else                       retArr.push(item)
            }

            return functionReturnsObject ? retObj : retArr
        }
        return retArr
    }

    /* can take int, string, array or multiple args!!!
       valid uses : select(1), select("1"), select([1,2]), select(1,2), select([1,2],3)
    */
    function select(listIdx){
        if(arguments.length === 1){
            var type = ZGlobal.functions.getType(listIdx)
            switch(type){
                case 'number' : functions._select(listIdx)        ; selectionChanged(selectedArr.length);   break;
                case 'string' : functions._select(Number(listIdx)); selectionChanged(selectedArr.length);   break;
                case 'array'  : for(var i = 0; i < listIdx.length ; i++){
                                    functions._select(listIdx[i])
                                }
                                selectionChanged(selectedArr.length)
                                break;
            }
        }
        else {
            for(i = 0; i < arguments.length; i++)
                select(arguments[i])        //recursive call!
            selectionChanged(selectedArr.length);
        }
    }

    /* can take int, string, array or multiple args!!!
       valid uses : unselect(1), unselect("1"), unselect([1,2]), unselect(1,2), unselect([1,2],3)
    */
    function unselect(listIdx){
        if(arguments.length === 1){
            var type = ZGlobal.functions.getType(listIdx)
            switch(type){
                case 'number' : functions._unselect(listIdx)        ; selectionChanged(selectedArr.length);   break;
                case 'string' : functions._unselect(Number(listIdx)); selectionChanged(selectedArr.length);  break;
                case 'array'  : for(var i = 0; i < listIdx.length ; i++)
                                    functions._unselect(listIdx[i]) //recursive call
                                selectionChanged(selectedArr.length);
                                break;
            }
        }
        else {
            for(i = 0; i < arguments.length; i++)
                unselect(arguments[i])        //recursive call!
            selectionChanged(selectedArr.length);
        }
    }
    function unselectAll(){
        if(ZGlobal.functions.isUndef(model))
            return

        var type    = ZGlobal.functions.getType(model)
        var lenProp = type === 'array' ? 'length' : type === 'listmodel' ? 'count' : null
        if(lenProp !== null){
            for(var i = 0; i < model[lenProp]; i++) {
                checkboxList.uncheck(i)
                unselected(i)
            }
            selectedArr = []
        }
        selectionChanged(selectedArr.length);
    }
    function selectAll(){
//        console.log(rootObject, 'selectAll()')
        if(ZGlobal.functions.isUndef(model))
            return

        var type    = ZGlobal.functions.getType(model)
        var lenProp = type === 'array' ? 'length' : type === 'listmodel' ? 'count' : null
        if(lenProp){
            selectedArr = []
            for(var i = 0; i < model[lenProp]; i++) {
                functions._select(i)
                selected(i)
            }
        }
        selectionChanged(selectedArr.length);
    }

//    onCountChanged : {
//        if(count > 0 && autoAdjustSize){
////            contentItem.anchors.right = rootObject.right
//            readjust()
//        }
//    }

//    function readjust(){
//        for(var i = 0; i < count; i++){
//            var item = ZGlobal.functions.getDelegateInstance(rootObject, i)
//            if(item){
//                item.width         = Qt.binding(widthFunc)
//                item.height        = Qt.binding(heightFunc)
//                item.anchors.right = item.parent.right
//            }
//        }
//    }

    ListView {
        id : checkboxList
        width         : cellHeight
        height        : parent.height
        contentY      : rootObject.contentY

        anchors.right : parent.left
        anchors.top   : parent.top
        model         : parent.model
        interactive   : false
        onFocusChanged : if(focus)
                             parent.focus = true

        function check(index){
            var item = ZGlobal.functions.getDelegateInstance(checkboxList, index)
            if(item) {
                item.suppressChanges = true
                item.checked = true
//                selected(index)
                item.suppressChanges = false
            }
        }
        function uncheck(index) {
            var item = ZGlobal.functions.getDelegateInstance(checkboxList, index)
            if(item){
                item.suppressChanges = true
                item.checked = false
//                unselected(index)
                item.suppressChanges = false
            }
        }

        delegate : CheckBox {
            property bool imADelegate : true
            property int  _index      : index
            property bool suppressChanges : false
            style: checkboxStyle
            onCheckedChanged: {
                if(!suppressChanges) {
                    if(checked)      select(index)
                    else             unselect(index)
                }
            }
        }
    }

    header : Item {
        width   : rootObject.checkMark_width
        height  : rootObject.selectAllButton ? cellHeight : 0
        visible : rootObject.selectAllButton
    }

    CheckBox {
       width       : cellHeight
       height      : rootObject.selectAllButton ? cellHeight : 0
       visible     : selectAllButton && ZGlobal.functions.isDef(model) && ( (model.count && model.count > 0) || (model.length && model.length > 0) ) ? true : false
//       scale : 1.05
       style : checkboxStyle
       anchors.bottom: parent.top
       anchors.right : parent.left
       onCheckedChanged: {
           if(checked) selectAll()
           else        unselectAll()
       }
   }

    Timer {
        interval   : 200
        repeat     : false
        running    : true
        onTriggered: {
            rootObject.contentY = 1
            rootObject.contentY = 0
        }
    }


    Component {
        id : checkboxStyle
        CheckBoxStyle {
            indicator: Rectangle {
                        implicitWidth: cellHeight
                        implicitHeight: cellHeight
                        border.width: 1
                            Rectangle {
                                color: control.checked ? ZGlobal.style.info : ZGlobal.style._default
                                radius: 1
                                anchors.margins: 4
                                anchors.fill: parent
                                border.width: 1
                            }
                        }
        }
    }



}

