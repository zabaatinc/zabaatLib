import QtQuick 2.5
Item {
    id : selector
    objectName : "selector"
    property var selectedItems : ({})
    property int count : 0
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
                             priv.isArray(except) ? except : [except]

        var deleteArr = [];
        priv.each(selectedItems, function(v,k) {
            if(priv.indexOf(eArr,v) === -1) {
                deleteArr.push(k)
            }
        })

        priv.each(deleteArr, function(v,k){
            delete selectedItems[v];
            count--;
        })

        selectionRect.doUpdate();
    }
    function deleteSelection(){
        if(!selectedItems)
            return;

        priv.each(selectedItems, function(v,k) {
            v.destroy();
        })
    }
    function isSelected(item){
        return selectedItems && selectedItems[item.toString()] ? true : false
    }

    QtObject {
        id : priv
        function each(collection, fn) {
            if(typeof fn !== 'function' || typeof collection !== 'object')
                return;

            for(var k in collection){
                if(fn(collection[k],k) === false)
                    return;
            }
        }
        function indexOf(arr,v) {
            if(typeof arr !== 'object')
                return -1;

            for(var k in arr){
                if(arr[k] == v)
                    return k;
            }
            return -1;
        }
        function isArray(arr) {
            return toString.call(arr) === "[object Array]"
        }
        function keys(collection) {
            var arr = []
            each(collection,function(v,k){
                arr.push(k)
            })
            return arr;
        }


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
            priv.each(selector.selectedItems, function(v,k) {
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
                priv.each(selector.selectedItems, function(v) {
                    v.x += diff.x;
                    v.y += diff.y;
                })
                prevCoords = Qt.vector2d(coords.x, coords.y);
            }
        }
        onDraggingChanged: prevCoords = dragging ? Qt.vector2d(x,y) : Qt.vector2d(NaN,NaN);
    }
    MouseArea {
        id : selectorMa
        anchors.fill: parent
        drag.target: selectionRect.width > 0 && selectionRect.height > 0 ? selectionRect : null;
        onClicked : {
            var item = selector.parent.childAt(mouseX, mouseY);
            if(!item || item === selector || item === selector.parent)
                return selector.deselectAll();

            if(mouse.modifiers & Qt.ShiftModifier)
                return !isSelected(item) ? selector.addToSelection(item) : selector.removeFromSelection(item);
            else {
                selector.deselectAll();
                selector.addToSelection(item);
            }
        }
    }
}
