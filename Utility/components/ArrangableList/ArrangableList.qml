import QtQuick 2.5
//import Zabaat.Material 1.0  //remove dependecy later
import Zabaat.Utility 1.1
import QtQuick.Controls 1.4


Item {
    id : rootObject
    property alias model                        : zsubOrig.sourceModel
    property var   filterFunc                   : null
    property alias lv                           : lv
    property alias logic                        : logic
    property alias gui                          : gui

    property var   selectionDelegate             : selectionDelegate
    property color selectionDelegateDefaultColor : "green"
    property var   highlightDelegate             : rootObject.selectionDelegate //will normally just change by changing selectionDelegate!
    property var   delegate                      : simpleDelegate
    property real  delegateCellHeight            : lv.height * 0.1

    readonly property int count_Original        : zsubOrig.sourceModel.count
    readonly property alias count_ZSubOrignal   : zsubOrig.count
    readonly property alias count_ZSubChanger   : zsubChanger.count

    readonly property var undo                  : logic.undo
    readonly property var redo                  : logic.redo
    readonly property var deselect              : logic.deselect
    readonly property var select                : logic.select
    readonly property var selectAll             : logic.selectAll
    readonly property var deselectAll           : logic.deselectAll
    readonly property var moveSelectedTo        : logic.moveSelectedTo

    onActiveFocusChanged: if(activeFocus)
                              gui.forceActiveFocus()

    QtObject {
        id: logic

        //undos and redos are basically
        property var states         : []
        property int stateIdx       : 0   //left of stateIdx is undos, right of stateIdx is redos.
        property var selected       : ({})
        property int selectedLen    : 0
        property int lastTouchedIdx : -1

        property ZSubModel zsubOrig    : ZSubModel {
            id : zsubOrig
            onSource_rowsInserted: {
                //TODO
                console.log("TODO rowsInserted", start, end, count )
            }
            onSource_rowsRemoved:  {
                //TODO
                console.log("TODO rowsRemoved", start, end , count)
            }

        }
        property ZSubModel zsubChanger : ZSubModel {
            id : zsubChanger
            sourceModel : zsubOrig
            filterFunc : rootObject.filterFunc
            sortFuncAcceptsIndices: true
            sortFunc : function(a,b){ return a - b }
            onIndexListChanged: {
                logic.lastTouchedIdx = -1;
                logic.deselectAll()
            }
            onSourceModelChanged: {
                logic.stateIdx = 0;
                logic.states   = [];

                if(sourceModel)
                    logic.states.push(logic.cloneArr(sourceModel.indexList))
            }


        }

        function isSelected(idx){
            return typeof selected[idx] !== 'undefined'
        }


        function undos(){
            //get everything left of stateIdx
            var arr = []
            for(var i = 0; i < stateIdx; ++i){
                arr.push(states[i])
            }
            return arr;
        }
        function redos(){
            var arr = []
            for(var i = stateIdx  + 1; i < states.length; ++i){
                arr.push(states[i])
            }
            return arr;
        }


        function newArray(start,end){
            var arr = []
            for(var i = start; i<= end;++i)
                arr.push(i);
            return arr;
        }

        function isArray(obj){
            return toString.call(obj) === '[object Array]';
        }
        function cloneArr(arr){
            var narr =  []
            for(var i = 0; i < arr.length; ++i)
                narr.push(arr[i])
            return narr;
        }
        function indexOf(arr, element){
            function isArray(obj){
                return toString.call(obj) === '[object Array]';
            }

            if(arr === null || typeof arr === 'undefined' || !isArray(arr))
                return -1;

            for(var i = 0; i < arr.length; ++i){
                if(arr[i] === element)
                    return i;
            }

            return -1;
        }
        function moveArrayElem(arr, old_index, new_index) {
           if (new_index >= arr.length) {
               var k = new_index - arr.length;
               while ((k--) + 1) {
                   arr.push(undefined);
               }
           }
           arr.splice(new_index, 0, arr.splice(old_index, 1)[0]);
           return arr; // for testing purposes
       }


        function deselect(idx, ctrlMod){    //shiftMod don't matta here
            if(idx < 0 || idx >= zsubChanger.indexList.length || indexOf(selected, idx) !== -1)
                return false;

            if(ctrlMod || selectedLen === 1){
                var ns = selected
                if(typeof ns[idx] !== 'undefined'){
                    delete ns[idx]

                    selected = ns
                    selectedLen--
                    return true;
                }
            }
            else {
               //actually, since ctrl wasn't pressed, we REALLY meant to select this
               //and deselect everything else
               return select(idx);
            }
        }
        function select(idx, ctrlMod, shiftMod){
            if(isArray(idx)){
                var ns = {}
                for(var i = 0; i < idx.length; ++i){
                    var si = idx[i]
                    if(si < 0 || si >= zsubChanger.indexList.length )
                        return false;

                    ns[si] = zsubChanger.indexList[si]
                }
                selected = ns
                selectedLen = idx.length;
                return true;
            }



            if(idx < 0 || idx >= zsubChanger.indexList.length || indexOf(selected, idx) !== -1)
                return false;


            if(shiftMod) {  //this trumps ctrlMod & other types of clickers

                ns = {}
                if(logic.lastTouchedIdx !== -1){
                    //let's see if we need to go up for our selection or down
                    var start, end
                    if(idx < logic.lastTouchedIdx) {
                        start = idx
                        end = logic.lastTouchedIdx
                    }
                    else if(idx > logic.lastTouchedIdx){
                        start = logic.lastTouchedIdx
                        end = idx
                    }
                    else {
                        //both the same index, make sure we only select this thing
                        ns[logic.lastTouchedIdx] = zsubChanger.indexList[logic.lastTouchedIdx]
                        selected = ns;
                        selectedLen = 1;
                        return true;
                    }


                    var count = end - start + 1;
                    for(var i = start; i <= end; ++i){
                        ns[i] = zsubChanger.indexList[i]
                    }
                    selected = ns;
                    selectedLen = count;
                    return true;
                }
                else {
                    return false;
                }
            }
            else {
                ns = ctrlMod && selected ? selected : {};
                ns[idx] = zsubChanger.indexList[idx];

                selected = ns;
                selectedLen = ctrlMod ? selectedLen + 1 : 1
            }

            return true;
        }



        function undo(){
            if(states.length > 0 && stateIdx > 0){
                stateIdx--
                var undoState = states[stateIdx]
                zsubOrig.indexList = undoState
                deselectAll()
            }
        }
        function redo(){
            if(states.length > 0 && stateIdx < states.length - 1) {
                stateIdx++
                var redoState = states[stateIdx]
                zsubOrig.indexList = redoState
                deselectAll()
            }
        }
        function selectAll(){
            var ns = {}
            for(var i in zsubChanger.indexList){
                ns[i] =zsubChanger.indexList[i]
            }
            selected = ns
            selectedLen = zsubChanger.indexList.length;
        }
        function deselectAll(){
            selected = {}
            selectedLen = 0
        }
        function moveSelectedTo(idx){
            if(selected && selectedLen > 0){

                var len   = zsubChanger.indexList.length
                var e     = selectedLen === 1 ? zsubChanger : zsubOrig
                var begin = e.indexList[0]    //the refIdx at the start of our list(zsubChanger)
                var end   = e.indexList[len -1]
                var dest  = idx <= 0 ? begin : idx >= len ? end : e.indexList[idx]

                if(selectedLen === 1){
                    //we only have one element. So this should be essy.
                    var s = selectedFirst()

                    zsubOrig.move(s,dest,1);
                    deselectAll()
                    logic.lastTouchedIdx = -1;

                    //                    var il = cloneArr(zsubOrig.indexList)
                    //                    var temp = il[s]
                    //                    il[s] = il[dest]
                    //                    il[dest] = temp
                    //                    zsubOrig.indexList = il
                }
                else {
                    var il        = cloneArr(zsubOrig.indexList)
                    var movingArr = selectedAsArr()


                    for(var i = movingArr.length - 1; i >= 0 ; --i ){
                        var si = movingArr[i]
                        il.splice(si, 1);
                    }
                    console.log(movingArr, il , dest)

                    var head   = movingArr[0]
                    var tail   = movingArr[movingArr.length -1]
                    var target = indexOf(il, dest) // the arr index to move to (in il) !

                    if(target !== -1){
                        var left, right

                        if(head > idx) { //moving stuff up
                            console.log("moving stuff up")
                        }
                        else if(head < idx){    //moving stuff down
                            console.log("tail:", tail, "\tidx:", idx)

                            if(tail < idx){
                                right  = il.slice(0 , target)
                                left = il.slice(target, il.length)
                            }
                            else {
                                left  = []
                                right = il
                            }
                        }

                        console.log(left, movingArr, right)
                        il = left.concat(movingArr).concat(right)
////                        select(newArray(dest, dest + selectedLen - 1))
                        zsubOrig.indexList  = il;
                        deselectAll()
                        logic.lastTouchedIdx = -1;
                    }

//                    for(var i = 0; i < sar.length; ++i){
//                        var si = sar[i]
//                        movingArr.push(il[si])  //we will remove this from il
//                    }

//                    for(i = sar.length - 1; i >= 0 ; --i ){
//                        si = sar[i]
//                        il.splice(si, 1);
//                    }
//                    var target = indexOf(il , dest) //the arr index to move TO!


//                    console.log(movingArr, il , "----" , head, idx)
//                    if(target !== -1) {

//                        il.splice(target, 0, movingArr)
//                        il = _.flatten(il);

//                        var left, right
//                        if(head > idx) { //moving stuff up!
//                            if(idx === 0){
//                                left  = []
//                                right = il
//                            }
//                            else {
//                                left  = il.slice(0 , target)
//                                right = il.slice(target, il.length)
//                            }
//                        }
//                        else if(idx > head) {    //moving stuff down
//                            if(il.length === 1 || (il.length - target) < movingArr.length) {   //is last element
//                                left = il
//                                right = []
//                            }
//                            else {
//                                left  = il.slice(0 , target)
//                                right = il.slice(target, il.length)
//                            }
//                        }
//                        console.log(left, right)

//                    }


                }

                //remove everything after stateIdx (if not last)
                states.length = stateIdx + 1    //this will kill everything after the stateIdx
                states.push(cloneArr(zsubOrig.indexList))
                stateIdx = states.length -1
            }
        }

        function selectedAsArr(){
            var arr = []
            for(var s in selected){
                arr[s] = s
            }
            return arr.filter(function(a) {
                return a !== null || typeof a !== "undefined" ? true : false
            });
        }
        function selectedFirst(){
            if(selected){
                for(var s in selected)
                    return selected[s]
            }
            return null;
        }

    }


    Item {
        id: gui
        anchors.fill: parent
        Component.onCompleted: gui.forceActiveFocus()
        property bool ctrlModifier : false
        property bool shiftModifier : false

        Keys.onPressed: {
            if(event.modifiers & Qt.ControlModifier)
                ctrlModifier = true;
            if(event.modifiers & Qt.ShiftModifier)
                shiftModifier = true;
        }
        Keys.onReleased: {
            if(!event.modifiers)
                return ctrlModifier = shiftModifier = false;

            var s = false;
            var c = false;
            if(event.modifiers & Qt.ShiftModifier){
                 s = true;
            }

            if(event.modifiers & Qt.ControlModifier){
              c = true;
            }
            ctrlModifier = c;
            shiftModifier = s;

            if((ctrlModifier && shiftModifier && event.key === Qt.Key_Z) ||
                    (ctrlModifier && event.key === Qt.Key_Y)) {
                logic.redo()
            }
            else if(ctrlModifier && event.key === Qt.Key_Z){
                logic.undo()
            }
        }


        ListView {
            id : lv
            anchors.fill: parent
            model : zsubChanger
            delegate : Loader  {
                id : delegateLoader
                width  : lv.width
                height : delegateCellHeight
                sourceComponent : dragDelegate.index !== index ? rootObject.delegate : blankDelegate
                property int _index       : index
                property bool imADelegate : true
                property bool selected: logic.selected && typeof logic.selected[index] !== 'undefined' ? true : false

                onLoaded : {
                    item.anchors.fill = delegateLoader
                    if(item.hasOwnProperty('model'))
                        item.model = Qt.binding(function() { return lv.model.get(index) })
                    if(item.hasOwnProperty('index'))
                        item.index = Qt.binding(function() { return index; })
                }

                Loader {
                    anchors.fill   : parent
                    sourceComponent: parent.selected && !dMsArea.isDragging ? rootObject.selectionDelegate : null
                    z : 9
                }
                DropArea {
                    id : dDropArea
                    anchors.fill: parent
                    objectName : "DropArea:" + parent._index
                    keys : ["dropItem"]
                    z : 999

                    onEntered: delHighlightLoader.sourceComponent = rootObject.highlightDelegate//dBorderRect.border.width = rootObject.delegateHighlightThickness
                    onExited : delHighlightLoader.sourceComponent = null; //dBorderRect.border.width  = 0;


                    Loader {
                        id : delHighlightLoader
                        anchors.fill: parent
                    }

                }

            }
            MouseArea {
                id : dMsArea
                anchors.fill: parent
                propagateComposedEvents: true
                preventStealing: false
                drag.target: dragDelegate
                onClicked:  {
                    gui.forceActiveFocus()
                    var idx = lv.indexAt(mouseX, mouseY + lv.contentY)
                    if(idx !== -1){
                        if(!gui.ctrlModifier && !gui.shiftModifier)
                            logic.lastTouchedIdx = idx;

                        return logic.selected && typeof logic.selected[idx] !== 'undefined' ? logic.deselect(idx, gui.ctrlModifier, gui.shiftModifier) :
                                                                                                logic.select(idx  , gui.ctrlModifier, gui.shiftModifier);
                    }
                }

                property bool isDragging : drag.active
                onIsDraggingChanged: {
                    if(!isDragging){
                        var dTarget = dragDelegate.Drag.target
                        if(dTarget){
                            var idx = dTarget.parent._index
                            if(idx > -1 && idx < logic.zsubChanger.indexList.length){
                                logic.moveSelectedTo(idx);
                            }
                        }
                        dragDelegate.index= -1;
                    }
                    else {
                        idx = lv.indexAt(mouseX, mouseY + lv.contentY)
                        if(idx !== -1){
                            dragDelegate.index = idx
                            if(!logic.isSelected(idx)) {
                                logic.select(idx, true);
                            }
                        }
                    }
                }


            }
            Loader {
                id : dragDelegate
                width : logic.selectedLen > 1 ? lv.width - height : lv.width
                height : delegateCellHeight
                sourceComponent: index !== -1  ? rootObject.delegate : null
                property int index : -1
                x : dMsArea.mouseX - width/2
                y : dMsArea.mouseY - height/2
                onLoaded : {
                    item.anchors.fill = dragDelegate
                    if(item.hasOwnProperty('model'))
                        item.model = Qt.binding(function() { return lv.model.get(index) })
                    if(item.hasOwnProperty('index'))
                        item.index = Qt.binding(function() { return index; })
                }

                Drag.keys: ["dropItem"]
                Drag.active: dMsArea.isDragging
                Drag.hotSpot.x : width/2
                Drag.hotSpot.y : height/2

                Rectangle {
                    anchors.left: parent.right
                    width : parent.height
                    height : parent.height
                    radius : height/2
                    color  : "red"
                    visible : logic.selectedLen > 1 && dragDelegate.sourceComponent !== null
                    border.width: 1
                    Text{
                        anchors.fill: parent
                        font.pixelSize: height * 1/2
                        color : 'white'
                        text  : logic.selectedLen
                        scale : paintedWidth > width ? width / paintedWidth : 1
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

            }


            function getDelegateInstance(idx){
                for(var i = 0; i < lv.contentItem.children.length; ++i) {
                    var child = lv.contentItem.children[i]
                    if(child && child.imADelegate && child._index === idx)
                        return child;
                }
                return null;
            }








        }

        Component {
            id : blankDelegate
            Rectangle {
                border.width: 1
                color : 'transparent'
            }
        }

        Component {
            id : simpleDelegate
            Rectangle {
                border.width: 1
                property int index
                property var model
                Text {
                    anchors.fill: parent
                    font.pixelSize: height * 1/3
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
//                    text             : parent.model ? JSON.stringify(parent.model) : "N/A"
                    text             : parent.model ? parent.model.number : "N/A"
                }
            }
        }
        Component {
            id : selectionDelegate
            Rectangle {
                color : selectionDelegateDefaultColor
                opacity : 0.5
            }
        }



    }





}
