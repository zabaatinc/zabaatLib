import QtQuick 2.5
import Zabaat.Utility 1.0
import Zabaat.Material 1.0
import Zabaat.Shaders 1.0 as Fx
Item {
    id : rootObject
    objectName : "test.qml"

    Component.onCompleted:  {
        forceActiveFocus();
    }



    Item {
        id : selector
        objectName : "selector"
        property var selectedItems : ({})
        property int count : 0
        anchors.fill: parent
        z : Number.MAX_VALUE

        function addToSelection(item) {
            if(!item || !Qt.isQtObject(item))
                return;

            if(!selectedItems)
                selectedItems = {}

            var itemStr = item.toString();
            if(selectedItems[itemStr]){ //exists in our map
                return console.error(itemStr, "is already selected")
            }
            else {
                item.Component.destruction.connect(function() {
                    removeFromSelection(item);
                })

                selectedItems[itemStr] = item;
                count++;
                selectionRect.doUpdate();
            }
        }
        function removeFromSelection(item) {
            if(!item || !Qt.isQtObject(item) || !selectedItems || !selectedItems[item.toString()])
                return;

            delete selectedItems[item.toString()];
            count--;
            selectionRect.doUpdate();
        }
        function deselectAll(except) {
            if(!selectedItems)
                return;

            var eArr = !except ? [] :
                                 Lodash.isArray(except) ? except : [except]

            Lodash.each(selectedItems, function(v,k) {
                if(Lodash.indexOf(eArr,v) === -1) {
                    delete selectedItems[k];
                    count--;
                }
            })
            selectionRect.doUpdate();
        }
        function deleteSelection(){
            if(!selectedItems)
                return;

            Lodash.each(selectedItems, function(v,k) {
                v.destroy();
            })
        }


        Rectangle {
            id : selectionRect
            border.width: 4
            color : 'transparent'
            border.color: 'blue'
            width  : 0
            height : 0

            Rectangle {
                anchors.right: parent.right
                visible : selector.count > 1 ? true : false
                width   : height * 2.5
                height  : 20
                color : selectionRect.border.color
                Text {
                    anchors.centerIn: parent
                    text :selector.count
                    color:'white'
                }
            }


            function doUpdate() {
                if(selector.count === 0) {
                    selectionRect.x = selectionRect.y = selectionRect.width = selectionRect.height = 0;
                    return;
                }


                var topLeft  = Qt.point(Number.MAX_VALUE,Number.MAX_VALUE);
                var botRight = Qt.point(0,0);
                Lodash.each(selector.selectedItems, function(v,k) {
                    topLeft.x  = Math.min(v.x, topLeft.x);
                    topLeft.y  = Math.min(v.y, topLeft.y);
                    botRight.x = Math.max(v.x + v.width, botRight.x);
                    botRight.y = Math.max(v.y + v.height, botRight.y);
                })

                selectionRect.x      = topLeft.x;
                selectionRect.y      = topLeft.y;
                selectionRect.width  = botRight.x - topLeft.x;
                selectionRect.height = botRight.y - topLeft.y;
            }

            readonly property bool dragging : selectorMa.drag.active
            property vector2d prevCoords : Qt.vector2d(NaN,NaN);
            property vector2d coords     : Qt.vector2d(x,y);

            onCoordsChanged: {
                //drag all the selected items
                if(dragging) {
                    var diff = coords.minus(prevCoords);
                    Lodash.each(selector.selectedItems, function(v) {
                        v.x += diff.x;
                        v.y += diff.y;
                    })
                    prevCoords = Qt.vector2d(coords.x, coords.y);
                }
            }
            onDraggingChanged: prevCoords = dragging ? Qt.vector2d(x,y) : Qt.vector2d(NaN,NaN);
        }
//        Fx.Invert {
//            source : selectionRect
//            fill : rootObject
//        }

        MouseArea {
            id : selectorMa
            anchors.fill: parent
            drag.target: selectionRect.width > 0 && selectionRect.height > 0 ? selectionRect : null;
            onClicked : {
                var item = rootObject.childAt(mouseX, mouseY);
                if(!item)
                    return selector.deselectAll();

                if(item !== selector.parent && item !== selector) {
                    if(mouse.modifiers & Qt.ShiftModifier) {
                        if(!selector.selectedItems || !selector.selectedItems[item.toString()]){
                            selector.addToSelection(item);
                        }
                        else {
                            selector.removeFromSelection(item);
                        }
                    }
                    else {
                        selector.deselectAll();
                        selector.addToSelection(item);
                    }
                }
            }
        }
    }


    Keys.onPressed: {
        if(event.key === Qt.Key_Plus){
            var r = rectFactory.createObject(rootObject)
            r.x = Math.random() * rootObject.width
            r.y = Math.random() * rootObject.height
        }
        else if(event.key == Qt.Key_Delete) {
            selector.deleteSelection();
        }
    }




    Component {
        id : rectFactory
        Rectangle {
            width : 64
            height : 64
            color : Colors.getRandomColor()
        }
    }



}
