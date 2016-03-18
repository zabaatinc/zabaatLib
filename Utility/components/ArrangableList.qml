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


    QtObject {
        id : logic
        property ZSubModel zsub : ZSubModel {
            id : zsub
            sourceModel: rootObject.model
            compareFunction: function(a,b){
                if     (a.__relatedIndex < b.__relatedIndex)           return -1;
                else if(a.__relatedIndex > b.__relatedIndex)           return 1;
                return 0;
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
            item.selected = true;
        }
        function deselect(idx, rIndex, item){
            item.selected = false;
        }
        function dropped(target, droppee){
            if(target && target !== droppee.dDropArea){


                var arr = getSelected();
//                console.log("DROPPED", target, droppee, arr)
                if(arr.length > 0) {
                                    //lm            //from  //to  //len
//                    console.log("MOVE", arr[0] , "--> ", target.parent.relatedIndex)
                    logic.doMove(zsub.sourceModel, arr[0], target.parent.relatedIndex, arr.length)
                }
                if(arr.length === 1)
                    logic.deselectAll()
            }
            droppee.dLoader.x = droppee.dLoader.y = 0;
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
            width : lv.width
            height: lv.cellHeight

            property var  m            : lv.model && lv.model.count > index ?  lv.model.get(index) : null
//            onMChanged: if(m) console.log(JSON.stringify(m,null,2))
            property int  relatedIndex : m ? m.__relatedIndex : -1
            property int _index        : index
            property bool imADelegate  : true
            property bool selected     : false

            property string name : m ? m.name : ""

            property alias dDropArea : dDropArea
            property alias dLoader   : dLoader

            z : dMsArea.isDragging ?  1 : 0

            Rectangle {
                id : dCheckBox
                width : parent.height/2
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
            }
            Loader {
                id : dLoader
                width : parent.width - parent.height
                height : parent.height
                anchors.right: parent.right
                sourceComponent : guiVars.delegate
                scale : dMsArea.isDragging ?  0.8 : 1

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
                            logic.dropped(dLoader.Drag.target, del)
                        }
                        else {             //begun dragging
                            logic.select(del._index, del.relatedIndex, del);
                        }
                    }
                }
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

                onSourceChanged: console.log("SOURCE", source)


                onEntered: if(drag.source !== null && typeof drag.source !== 'undefined' && drag.source.parent._index !== del._index){
                        dBorderRect.border.color = guiVars.color_border_hightlight
                }

                onExited: dBorderRect.border.color = dMsArea.isDragging ? "transparent" : guiVars.color_border_normal

                Rectangle {
                    id : dBorderRect
                    anchors.fill: parent
                    color : 'transparent'
                    border.width: 1
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
