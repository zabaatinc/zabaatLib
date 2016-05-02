//Components dropped in should have property string title : ""
//If a custom header delegate is provided & if it doesn't have a onClicked signal ,
//we will add a mouseArea to it
import QtQuick 2.5
import Zabaat.Material 1.0
ZObject {
    id : rootObject
    objectName : "ZSwipeView"
    clip : true

    property var highlightDelegate : null
    property var headerDelegate    : null
    property int currentIndex      : -1
    property var currentItem       : null

    property int count             : 0
    property var items             :[]

    property alias container       : container

    onCurrentIndexChanged: if(currentIndex > -1 && currentIndex < count)
                               currentItem = items[currentIndex]

    function get(i){
        if(i > -1 && i < count)
            return items[i]
        return null;
    }

    QtObject {
        id: priv

        function isArray(obj){
            return toString.call(obj) === '[object Array]';
        }

        property string addProperty : isArray(items) ? "push" : "append"
        property string lenProperty : isArray(items) ? "length" : "count"


        function indexOf(arr,item){
            for(var i = 0; i < arr.length; ++i){
                if(arr[i] === item)
                    return i;
            }
            return -1;
        }

        function destructionHandler(i){
            if(typeof i === "object"){
                var idx = indexOf(items, i)
                if(idx !== -1){
                    items.splice(idx,1);
                    if(currentIndex >= items.length) {
                       currentIndex--
                    }
                    currentItem = get(currentIndex);


                    itemRemoved(idx);
                    --count;
                }
            }
            else if(typeof i === 'number'){
                items.splice(i,1);
                if(currentIndex >= items.length) {
                   currentIndex--
                }
                currentItem = get(currentIndex);

                itemRemoved(idx);
                --count;
            }
        }

        function kidnap(){
            var newItems = []
            var start = count
            for(var i = 0; i < rootObject.children.length; ++i) {
                var child = rootObject.children[i]
                if(child &&
                   child !== announcementTimer && child !== priv &&
                   child.objectName !== "styleLoader" &&
                   child.objectName !== "editModeLoader" && priv.indexOf(items,child) === -1 )
                {
                    child.Component.destruction.connect(function(){ priv.destructionHandler(child) })
                    child.parent = container
                    newItems.push(child)
                    items[addProperty](child);
                }
            }
            count = items[lenProperty]
            rootObject.itemsAdded(newItems, start, start + newItems.count - 1,  newItems.count);
        }


        property Item container : Item {
            id : container
            objectName : "ZSwipeView.Container"
            visible : false
        }
    }


    onChildrenChanged : announcementTimer.start()

    signal itemsAdded(var items, int startIdx, int endIdx, int count)
    signal itemRemoved(var idx)


    Timer {
        id : announcementTimer
        interval : 10
        onTriggered : priv.kidnap()
    }




}
