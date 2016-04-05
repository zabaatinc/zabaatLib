import QtQuick 2.5
import "ZSubModel"
//import Zabaat.Utility 1.0

Item {
    id : rootObject

    property alias logic      : logic
    property alias guiVars    : guiVars

    property alias queryTerm       : zsub.queryTerm
    property alias model           : zsub.sourceModel
    property alias delegate        : guiVars.delegate
    property alias lv : lv

    QtObject {
        id : logic
        property ZSubModel zsub : ZSubModel {
            id : zsub
//            sortRoles: null;
            compareFunction: function(a,b){
                return a.__relatedIndex - b.__relatedIndex
            }
        }

        function getSelected(){ //relatedIndices!
            var arr = []
            for(var i = 0; i < lv.contentItem.children.length ; ++i){
               var child = lv.contentItem.children[i]
               if(child && child.imADelegate && child.selected){
                   arr.push(child.relatedIndex);
               }
           }
           arr.sort()
           return arr
        }
        function doMove(lm, from, to , n){
            if(!lm)
                return;

            if(to + n > lm.count - 1){
                 to = lm.count - n
            }
            lm.move(from,to,n)
        }

        function deselectAll(){
            for(var i = 0; i < lv.contentItem.children.length ; ++i){
                var child = lv.contentItem.children[i]
                if(child && child.imADelegate){
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
        function select(idx, rIndex, item){
            var diffFromSelected =  getDiffFromSelected(idx)
            if(getDiffFromSelected(idx) > 1){
                deselectAll()
            }
            item.selected = true;
        }
        function deselect(idx, rIndex, item){

            item.selected= false;
            var selected = getSelected()
//            var largestDiff = 0;
//            console.log(selected, selected.length )
            if(selected && selected.length > 1){
                var prev    = selected[0]
                for(var i = 1; i < selected.length ; ++i){
                    var now = selected[i]
//                    console.log("DIFF", Math.abs(prev - now))
                    if(Math.abs(prev - now) > 1){
                        deselectAll()
                        return
                    }
                    prev = now;
                }
            }

        }
        function dropped(target, droppee){
            if(target && target !== droppee.dDropArea){

                var arr = getSelected();
                var tIndex = target.parent.relatedIndex
                //check we didn't just do a booboo and drop on one of the selecteds!
                var booMade = false
                for(var i = 0; i < arr.length; ++i){
                    if(arr[i] === tIndex){
//                         console.log("BOO MADE ON", arr[i])
                        booMade = true
                        break
                    }
                }

                if(!booMade) {
                    if(arr.length > 0) {
    //                    console.log("MOVE", arr[0] , "--> ", target.parent.relatedIndex)
                        logic.doMove(zsub.sourceModel, arr[0], tIndex, arr.length)
                    }
                    if(arr.length === 1)
                        logic.deselectAll()
                }

            }


            return showAllSelected(droppee)
        }


        function getDiffFromSelected(i){
            var selected = getSelected()
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


        function hideOtherSelected(del){    //returns count of total selected items
            var count = 0;
            var idx = del.relatedIndex
            for(var i = 0; i < lv.contentItem.children.length ; ++i){
               var child = lv.contentItem.children[i]
               if(child && child.imADelegate && child.selected && child.relatedIndex !== idx){
                   child.dLoader.parent =  del.dLoaderTail //visible = false;
                   count++
               }
            }
            return count + 1;
        }

        function showAllSelected(del){ //returns count of total selected items
//            for(var i = del.dLoaderTail.children.length - 1; i >= 0; i--){



            var removeThese = del.dLoaderTail.children
            for(var r = removeThese.length -1 ; r >= 0; r--){
                var dLoader = removeThese[r]

                var dLoaderParent = getDelegateInstance(dLoader.relatedIndex)
                dLoader.parent    = dLoaderParent
                dLoader.x = dLoader.y = 0
                dLoader.visible = true
                dLoader.z = 1

//                console.log(dLoader, dLoaderParent , dLoader.parent === dLoaderParent)
//                console.log("-------------------------------------------------------")
//                for(var d in dLoader){
//                    console.log(d, dLoader[d])
//                }
//                console.log("-------------------------------------------------------")

            }

            del.dLoaderTail.kids = 0;

//            var count
//            for(var i = 0; i < lv.contentItem.children.length ; ++i){
//               var child = lv.contentItem.children[i]
//               if(child && child.imADelegate && child.selected ){
//                   child.dLoader.visible = true;
//                   count++
//               }
//            }
//            return count;
        }

        function getDelegateInstance(idx){
            for(var i = 0; i < lv.contentItem.children.length ; ++i){
                var child = lv.contentItem.children[i]
                if(child && child.imADelegate && child.relatedIndex === idx){
                    return child;
                }
            }
            return null;
        }
    }
    QtObject {
        id : guiVars
        property alias cellHeight              : lv.cellHeight
        property color color_border_hightlight : "red"
        property var   delegate                : defaultDelegateCmp
        property color color_border_normal     : "black"

        property Component defaultDelegateCmp : Component {
            id : defaultDelegateCmp
            Rectangle {
                property int index : -1
                property int relatedIndex : -1
                property var model : null
                border.color: 'purple'
//                color : "red"
//                width : lv.width
//                height : lv.cellHeight
                border.width: 1
                Text {
                    anchors.centerIn: parent
                    font.pixelSize  : parent.height * 1/3
                    text : parent.model && parent.model.name ? parent.model.__relatedIndex + ":\t" +  parent.model.name : ""
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

        }

    }

    ListView {
        id : lv
        anchors.fill: parent
        clip : false
        model : logic.zsub

        property int cellHeight : height * 0.1

        delegate : Item {
            id : del
            objectName : "head" + _index
            width : lv.width
            height: lv.cellHeight

            property var  m            : lv.model && lv.model.count > index ?  lv.model.get(index) : null
//            onMChanged: if(m) console.log(JSON.stringify(m,null,2))
            property int  relatedIndex : m && m.__relatedIndex !== null && typeof m.__relatedIndex !== 'undefined' ? m.__relatedIndex : -1
            property int _index        : index
            property bool imADelegate  : true
            property bool selected     : false

//            property string name : m ? m.name : ""

            property alias dDropArea : dDropArea
            property alias dLoader   : dLoader
            property alias dLoaderTail : dLoaderTail
            property alias dBorderRect : dBorderRect

            z : dMsArea.isDragging ?  1 : 0

            Rectangle {
                id : dCheckBox
                width  : parent.height/2
                height : parent.height/2
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: height/2
                radius : height/2
                border.color : "black"
                color : del.selected ? guiVars.color_border_hightlight : "transparent"
                MouseArea {
                    anchors.fill: parent
                    onClicked : if(!del.selected)   logic.select(del._index, del.relatedIndex, del);
                                else                logic.deselect(del._index, del.relatedIndex, del)
                }
                z : 0
            }

            Loader {
                id : dLoader
                objectName : "Loader" + del._index
                width        : parent.objectName.indexOf("head") === 0 ? parent.width - parent.height : parent.width
                height       : parent.objectName.indexOf("head") === 0 ? parent.height                : parent.h
                anchors.right: parent.objectName.indexOf("head") === 0 ? parent.right : undefined
                anchors.left : parent.objectName.indexOf("head") === 0 ? undefined : parent.left

                sourceComponent : guiVars.delegate
                scale : dMsArea.isDragging ?  0.8 : 1

                property var  m              : lv.model && lv.model.count > index ? lv.model.get(index) : null
                property int  relatedIndex   : m && m.__relatedIndex !== null && typeof m.__relatedIndex !== "undefined" ? m.__relatedIndex : -1
                property var   originalParent : del
                property var dTar: Drag.target
//                onDTarChanged: console.log(dLoader," hovers over " , dTar)


                Drag.keys: ["dropItem"]
                Drag.active: dMsArea.isDragging
                Drag.hotSpot.x : width/2
                Drag.hotSpot.y : height/2
                onLoaded : if(item) {
                               item.anchors.fill = dLoader
                               if(item.hasOwnProperty("index"))
                                   item.index = Qt.binding(function() { return del._index })
                               if(item.hasOwnProperty("relatedIndex"))
                                   item.relatedIndex = Qt.binding(function() { return del.relatedIndex})
                               if(item.hasOwnProperty("model"))
                                   item.model = Qt.binding(function() { return del.m })
                           }

                MouseArea {
                    id : dMsArea

                    propagateComposedEvents: true
//                    hoverEnabled: true
                    anchors.fill: parent
                    drag.target : parent
                    property bool isDragging : drag.active

                    onIsDraggingChanged: {
                        if(!zsub.sourceModel)
                            return;

                        if(!isDragging){    //finished dragging
                            //make sure we didn't drop on one of the selected!
                            logic.dropped(dLoader.Drag.target, del)
                            dLoader.x = dLoader.y = 0;
                            dBorderRect.border.color = "black"
                            dCountTeller.text = ""
//                            logic.showAllSelected(del)
                        }
                        else {             //begun dragging
                            logic.select(del._index, del.relatedIndex, del);
                            var count = logic.hideOtherSelected(del)
//                            dLoaderTail.height = dLoader.height * (count - 1)
                            dLoaderTail.kids   = count - 1

                            dCountTeller.text  = " x" + count
                        }
                    }
                }

                z : 1

                Column {
                    id : dLoaderTail
                    objectName : "tail"
                    property int kids : 0

                    anchors.top: dLoader.bottom
                    width : parent.width
                    height : dLoader.height * kids
                    property int h : height/kids

//                    scale : dLoader.scale
                }
            }

            Text {
                //count teller
                id   : dCountTeller
                text : ""
                anchors.top: dLoader.top
                anchors.right: dLoader.right
                width : parent.height
                height : parent.height
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHJCenter
                font.pixelSize: height * 1/3
                color : guiVars.color_border_hightlight
                visible : text.length > 0

                z  : 2
            }


            DropArea {
                id : dDropArea
                width : parent.width - parent.height
                height : parent.height
                anchors.right: parent.right
                objectName : "DropArea:" + del._index
                keys : ["dropItem"]
                scale : dLoader.scale
                z : 999

//                onSourceChanged: console.log("SOURCE", source)


                onEntered: if(drag.source !== null && typeof drag.source !== 'undefined' && drag.source.parent._index !== del._index){
                        dBorderRect.border.color = guiVars.color_border_hightlight
                }

                onExited: dBorderRect.border.color = dMsArea.isDragging ? "transparent" : guiVars.color_border_normal

                Rectangle {
                    id : dBorderRect
                    anchors.fill: parent
                    color : 'transparent'
                    border.width: 1
                    visible : dLoader.parent === del
                }
            }


//            Text {    //for debugging. checks if stuff is in sync. Brohim!
//                anchors.centerIn: parent
//                horizontalAlignment: Text.AlignHCenter
//                verticalAlignment: Text.AlignVCenter
//                font.pixelSize: parent.height * 1/3
//                text : parent.relatedIndex + ":\t" + parent.name

//                property var realname      : rootObject.model.get(parent._index)
//                property var suggestedName : rootObject.model.get(parent.relatedIndex)

//                color : realname !== suggestedName ? "red" : "green"
//            }
        }

    }


}
