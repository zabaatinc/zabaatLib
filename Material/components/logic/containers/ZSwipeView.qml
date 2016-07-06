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
    property var items             : []

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

        property bool kidnapping : false
        function getArray(){
            var tbkidnapped = []

            for(var i = 0; i < rootObject.children.length ; ++i) {
                var child = rootObject.children[i]
                if(child &&
                   child !== priv &&
                   child.objectName !== "styleLoader" && !child.dontKidnap &&
                   child.objectName !== "editModeLoader" && priv.indexOf(items,child) === -1 )
                {
                    tbkidnapped.push(child)
                }
            }

            return tbkidnapped;
        }


        function kidnap(arr){
            kidnapping = true;

            if(items === null || typeof items === 'undefined')
                items = []

            var newItems = []
            var start = rootObject.count

            var childrenArr = arr ? arr : getArray()
            for(var c in childrenArr){
                var child = childrenArr[c]
//                console.log(child)
                child.Component.destruction.connect(function(){ priv.destructionHandler(child) })
                child.parent = container
                newItems.push(child)
                rootObject.items.push(child);
            }
            rootObject.count = rootObject.items.length
            rootObject.itemsAdded(newItems, start, start + newItems.count - 1,  newItems.count);

            var remaining = getArray()
            if(remaining.length === 0) {
                kidnapping = false;
            }
            else {
                kidnap(remaining);
            }
        }


        property Item container : Item {
            id : container
            objectName : "ZSwipeView.Container"
            visible : false
        }
    }



    onChildrenChanged : if(!priv.kidnapping)
                            priv.kidnap()




    signal itemsAdded(var items, int startIdx, int endIdx, int count)
    signal itemRemoved(var idx)

    function setHeaderBackground(color)   { return skinFunc(arguments.callee.name , color ) }




}
