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
    property var   blankDelegate                 : blankDelegate

    readonly property int count_Original        : zsubOrig.sourceModel.count
    readonly property alias count_ZSubOrignal   : zsubOrig.count
    readonly property alias count_ZSubChanger   : zsubChanger.count
    readonly property alias subModel            : zsubChanger  //for deprecated suppoert
    readonly property alias subModelOrig        : zsubOrig

    readonly property var undo                  : logic.undo
    readonly property var redo                  : logic.redo
    readonly property var deselect              : logic.deselect
    readonly property var select                : logic.select
    readonly property var selectAll             : logic.selectAll
    readonly property var deselectAll           : logic.deselectAll
    readonly property var moveSelectedTo        : logic.moveSelectedTo
    readonly property var resetState            : logic.resetState

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
//                console.log("TODO rowsInserted", start, end, count )
                logic.resetState();
            }
            onSource_rowsRemoved:  {
                //TODO
//                console.log("TODO rowsRemoved", start, end , count)
                logic.resetState();
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

                if(sourceModel && sourceModel.indexList.length > 0)
                    logic.states.push(logic.cloneArr(sourceModel.indexList))
            }
            onSourceModelChanged: {
                logic.resetState();
                if(sourceModel && sourceModel.indexList.length > 0)
                    logic.states.push(logic.cloneArr(sourceModel.indexList))
            }


        }

        function resetState(){
            logic.lastTouchedIdx = -1;
            logic.stateIdx = 0;
            logic.states   = [];
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

        function isUndef(item){
            return item === null || typeof item === 'undefined'
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
        function moveSelectedTo(idx , destIdx){     //destIdx is normally BLANK! HARD CODE, USE @ UR OWN RISK!
            if(selected && selectedLen > 0){

                var len   = zsubChanger.indexList.length
                var begin = zsubChanger.indexList[0]        //the refIdx at the start of our list(zsubChanger)
                var end   = zsubChanger.indexList[len -1]
//                var superBegin = zsubOrig.indexList[0]
//                var superEnd   = zsubOrig.indexList[zsubOrig.indexList.length - 1]
                var dest  = !isUndef(destIdx) ? destIdx :
                                                idx <= 0 ? begin : idx >= len ? end : zsubChanger.indexList[idx]

                if(selectedLen === 1){
                    //we only have one element. So this should be essy.
                    var s = selectedFirst()

                    zsubOrig.move(s,dest,1);
                    deselectAll()
                    logic.lastTouchedIdx = -1;

                }
                else {
                    //We have a list and selection in it, we want to move the selection to an
                    //index in the selection (idx). This is a relatively simple problem but what
                    //makes it tougher is that we need to move stuff in zsubOrig.indexList ,
                    //not the zsubChanger.indexList. And what makes this part harder is because of the filter
                    //function. The subChanger doesn't always have the entire list visible to it.

                    //step 1, rip out the selection array from the list
//                    var il    = cloneArr(zsubOrig.indexList)
                    dest = isUndef(destIdx) ? zsubChanger.indexList[idx]  : zsubOrig.indexList[destIdx]

                    var movingArr = []
                    var sar = []
                    for(var a in selected){
                        sar[a]  = selected[a]
                        movingArr[a] = zsubOrig.indexList[selected[a]]
                    }
                    sar       = sar.filter(function(a) { return a !== null || typeof a !== 'undefined' ? true : false })
                    movingArr = movingArr.filter(function(a) { return a !== null || typeof a !== 'undefined' ? true : false })

                    //we need the SAR array (to figure out our head & tail), essentially to figure out
                    //if we are moving up or down.
                    var il = _.difference(zsubOrig.indexList, movingArr);
//                    console.log("remove", movingArr, "from", zsubOrig.indexList , "=", il)


                    //Figure out the head, tail
                    var head   = sar[0]
                    var tail   = sar[sar.length -1]
                    destIdx    = indexOf(il, zsubOrig.indexList[dest])


//                    console.log("H:",head, "T:",tail, "\t\tDest:", dest, "@", destIdx)
                    //Subdivide the ilArr further @ dest.
                    //Place movingArr on left or right of it , depending on special conditions.
                    if(destIdx !== -1){
                        var left, right

                        if(head > dest) { //moving stuff up
//                            console.log("moving stuff up")
                            if(il.length === 1){
                                left = []
                                right = il;
                            }
                            else {
                                left = il.slice(0, destIdx);
                                right = il.slice(destIdx, il.length);
                            }
//                            return console.log(left, movingArr, right)
                        }
                        else if(head < dest){    //moving stuff down
//                            console.log("moving stuff down")
                            if(tail < dest || il.length === 1){
//                                console.log("case 1::\ttail<dest (", tail , "<", dest ,")"  , il)
                                left  = il
                                right = []
                            }
                            else {
//                                console.log("case 2")
                                left = il.slice(0, destIdx);
                                right = il.slice(destIdx, il.length);
                            }
                        }
                        else {
//                            console.log("head & dest are the same" , head , "===" , dest)
                            return;
                        }



//                        console.log(left, movingArr, right)
                        il = left.concat(movingArr).concat(right)
////                        select(newArray(dest, dest + selectedLen - 1))
                        zsubOrig.indexList  = il;
                        deselectAll()
                        logic.lastTouchedIdx = -1;
                    }
                    else {
//                        console.log("DEST IDX is -1. Tried to find", dest, "in", il)
                    }
                }

                //remove everything after stateIdx (if not last)
                states.length = stateIdx + 1    //this will kill everything after the stateIdx
                states.push(cloneArr(zsubOrig.indexList))
                stateIdx = states.length -1
            }
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

        ScrollView {
            anchors.fill: parent


            ListView {
                id : lv
                width : gui.width
                height : gui.height
                model : zsubChanger
                delegate : Loader  {
                    id : delegateLoader
                    width  : lv.width
                    height : delegateCellHeight
                    sourceComponent : dragDelegate.index !== index ? rootObject.delegate : rootObject.blankDelegate
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
                    onClicked: {
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
