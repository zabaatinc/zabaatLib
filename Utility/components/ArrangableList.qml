import QtQuick 2.5
import Zabaat.Utility 1.0
import "ZSubModel"

//components should have var model && int index if they want to talk to the data!
Item {
    id : rootObject

    property alias model : logic.sourceModel
    property var defaultDelegate          : defDel;
    property alias cellHeight             : lv.cellHeight
    property color color_border_highlight : "red"
    property color color_border_normal    : "black"

    QtObject {
        id : logic
        function getSelectedIndices(){
            var related = []
            var local   = []
            for(var i = 0; i < lv.contentItem.children.length ; ++i){
                var child = lv.contentItem.children[i]
                if(child && child.imADelegate && child.selected){
                    local.push(child._index);
                    related.push(child.relatedIndex);
                }
            }
            related = related.sort()
            local   = local.sort()
            return {related : related, local : local};
        }


        function doMove(lm, from, to , n){
            if(!lm)
                return;

            if(to + n > lm.count - 1){
                 to = lm.count - n
            }
            lm.move(from,to,n)
        }


        function getDiffFromSelected(i){
            var selected = getSelectedIndices()
            if(selected && selected.length > 0){
                var minDiff = lv.model.count;
                for(var s in selected){
                    var sIdx = selected[s]
                    minDiff = Math.min(lv.model.count, Math.abs(sIdx - i))
                    if(minDiff === 1)
                        return minDiff
                }
                return minDiff
            }
            return 0;
        }
        function deselectAll(){
            for(var i = 0; i < lv.contentItem.children.length ; ++i){
                var child = lv.contentItem.children[i]
                if(child && child.imADelegate && child.selected){
                    child.selected = false;
                }
            }
        }
        function selectAll(){
            for(var i = 0; i < lv.contentItem.children.length ; ++i){
                var child = lv.contentItem.children[i]
                if(child && child.imADelegate ){
                    child.selected = true;
                }
            }
        }
        function getSelected(){
            var arr = []
            for(var i = 0; i < lv.contentItem.children.length ; ++i){
                var child = lv.contentItem.children[i]
                if(child && child.imADelegate && child.selected){
                    arr.push(child);
                }
            }
            return arr;
        }
        function getDelegateInstance(idx){
            for(var i = 0; i < contentItem.children.length ; ++i){
                var child = contentItem.children[i]
                if(child && child.imADelegate && child._index === idx){
                    return child;
                }
            }
            return null;
        }
        function deselect(idx, item){
            item.selected= false;
//            var selected = getSelectedIndices().sort()
////            var largestDiff = 0;
////            console.log(selected, selected.length )
//            if(selected && selected.length > 1){
//                var prev    = selected[0]
//                for(var i = 1; i < selected.length ; ++i){
//                    var now = selected[i]
////                    console.log("DIFF", Math.abs(prev - now))
//                    if(Math.abs(prev - now) > 1){
//                        deselectAll()
//                        return
//                    }
//                    prev = now;
//                }
//            }
        }
        function select(idx, item){
//            var diffFromSelected =  getDiffFromSelected(idx)
//            if(getDiffFromSelected(idx) > 1){
//                deselectAll()
//            }
            item.selected = true;
        }

        property var sourceModel : null
    }
    ListView {
        id : lv
        anchors.fill: parent
        property int cellHeight : height * 0.1

        model : ZSubModel {
            id         : zsubmodel
            sourceModel: logic.sourceModel
            compareFunction: function(a,b){
                if( a.__relatedIndex < b.__relatedIndex)
                    return -1
                else if(a.__relatedIndex > b.__relatedIndex)
                    return 1
                return 0;

            }
        }

        clip : false
        delegate : Item {
            id : del
            width : lv.width
            height : lv.cellHeight

            property var  model       : lv.model && lv.model.count > index ? lv.model.get(index) : null
            property int _index       : index
            property int relatedIndex : model ? model.__relatedIndex : -1
            property bool imADelegate : true
            property bool selected    : false

            z : __delMsArea.isDragging ? 1 : 0


    //        Drag.keys: ["dropItem"]
            Row {
                anchors.fill: parent

                Item {
                    width : height
                    height : parent.height

                    Rectangle {
                        anchors.centerIn: parent
                        width : parent.width/2
                        height : parent.height/2
                        radius : height/2
                        border.width: 1
                        color : del.selected ? color_border_highlight : "transparent"

                        MouseArea {
                            anchors.fill: parent
                            onClicked : if(!del.selected) logic.select  (del.relatedIndex,del)
                                        else                logic.deselect(del.relatedIndex,del)
                        }
                    }
                }

                Item {
                    width : parent.width - parent.height
                    height : parent.height

                    Loader {
                        id : __delLoader
                        objectName      : "delLoader"
                        width           : parent.width
                        height          : parent.height
                        sourceComponent : rootObject.defaultDelegate
                        scale : __delMsArea.isDragging ? 0.8 : 1

                        property int _index : index

                        Drag.keys: ["dropItem"]
                        Drag.active: __delMsArea.isDragging
                        Drag.hotSpot.x : width/2
                        Drag.hotSpot.y : height/2
                        onLoaded: if(item) {
                                      item.anchors.fill = __delLoader
                                      if(item.hasOwnProperty("index"))
                                          item.index = Qt.binding(function(){ return index })
                                      if(item.hasOwnProperty("model") && lv.model)
                                          item.model = lv.model.get(index);
                                  }

                        MouseArea {
                            id : __delMsArea
                            anchors.fill: parent
                            propagateComposedEvents: true
                            hoverEnabled: true
                            drag.target: parent

                            property bool isDragging : drag.active

                            onIsDraggingChanged : {
                                if(!logic.sourceModel)
                                    return;

                                if(!isDragging){
                                    var target      = __delLoader.Drag.target
                                    var selectedObj = logic.getSelectedIndices()

                                    var local   = selectedObj.local
                                    var related = selectedObj.related

//                                    console.log("local:", local ,"-->", target.index, "related:",related, "->", target.relatedIndex)
                                    if(target && target !== __delDropArea && related && local && related.length > 0 && local.length >0){

                                                                        //from      //to                 //len
                                        logic.doMove(logic.sourceModel, related[0], target.relatedIndex, related.length)
//                                        logic.doMove(lv.model         , local[0]  , target.index       , local.length)
                                    }
                                    __delLoader.x = __delLoader.y = 0;

                                    if(related.length === 1)
                                        logic.deselect(del.relatedIndex,del);
                                }
                                else {
                                    logic.select(del.relatedIndex,del)
                                }
                            }
                        }

                    }

                    DropArea {
                        id : __delDropArea
                        anchors.fill: parent
                        objectName : "DropArea:" + index
                        keys      : ["dropItem"]


                        property int relatedIndex : del.relatedIndex
                        property int index        : del._index

                        onEntered : {
                            if(drag.source !== null && typeof drag.source !== "undefined" && drag.source._index !== index)
                            {
                                borderRect.border.color = rootObject.color_border_highlight
            //                    __del.scale  = 1.1
                            }
                        }
                        onExited : {
                            borderRect.border.color = rootObject.color_border_normal
            //                __del.scale  = 1
                        }


                    }

                    Rectangle {
                        id : borderRect
                        anchors.fill: parent
                        color : 'transparent'
                        border.width: 1

                    }

                }

            }


        }
        Component {
            id : defDel
            Rectangle {
                id : defDelInstance
                property int index : -1
                property var model : null
                width              : lv.width
                height             : lv.cellHeight
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    font.pixelSize  : parent.height * 1/3
                    text : parent.model && parent.model.name ? parent.model.__relatedIndex + ":" +  parent.model.name : ""
                }
            }
        }
    }


}



