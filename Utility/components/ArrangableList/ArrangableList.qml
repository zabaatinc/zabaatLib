import QtQuick 2.5
//import Zabaat.Material 1.0  //remove dependecy later
import Zabaat.Utility 1.1
import QtQuick.Controls 1.4


Item {
    id : rootObject
    property alias model                        : zsubOrig.sourceModel
    property alias filterFunc                   : zsubChanger.filterFunc
    property alias lv                           : lv
    property alias logic                        : logic
    property alias gui                          : gui

    property var   selectionDelegate            : selectionDelegate
    property color selectionDelegateDefaultColor : "green"
    property var   delegate                     : simpleDelegate
    property real  delegateCellHeight           : lv.height * 0.1



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

        property ZSubModel zsubOrig    : ZSubModel {  id : zsubOrig   }
        property ZSubModel zsubChanger : ZSubModel {
            id : zsubChanger
            sourceModel : zsubOrig
            sortFuncAcceptsIndices: true
            sortFunc : function(a,b){ return a - b }
            onIndexListChanged: {
                logic.lastTouchedIdx = -1;
            }
            onSourceModelChanged: {
                logic.stateIdx = 0;
                logic.states   = [];

                if(sourceModel)
                    logic.states.push(logic.cloneArr(sourceModel.indexList))
            }
            onSource_rowsRemoved: {
                //TODO
            }
            onSource_rowsInserted: {
                //TODO
            }
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
                var begin = zsubChanger.indexList[0]    //the refIdx at the start of our list(zsubChanger)
                var end   = zsubChanger.indexList[len -1]
                var dest  = idx <= 0 ? begin : idx >= len ? end : zsubChanger.indexList[idx]

                if(selectedLen === 1){
                    //we only have one element. So this should be essy.
                    var s = selectedFirst()
                    zsubOrig.move(s,dest,1);
                    logic.select(dest);         //w/o having a ctrl mod, it will deselect
                    logic.lastTouchedIdx = -1;
                }
                else {
                    var il = cloneArr(zsubOrig.indexList)

                    //do all the operations on il & then put it back into zsubOrig.indexList
                    var sar = selectedAsArr()
                    for(var i = 0; i < sar.length; ++i){
                        var si = sar[i]

                        //assign si to idx!
                        moveArrayElem(il, si, dest + i);
                    }

                    zsubOrig.indexList  = il;
                    select(newArray(dest, dest + selectedLen - 1))
                    logic.lastTouchedIdx = -1;
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
                arr[s] = selected[s]
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
                sourceComponent : rootObject.delegate
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
                    anchors.fill: parent
                    sourceComponent: parent.selected ? rootObject.selectionDelegate : null
                    z : 9
                }


            }
            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                preventStealing: false
                onClicked : {
                    gui.forceActiveFocus()
                    var idx = lv.indexAt(mouseX, mouseY + lv.contentY)
                    if(idx !== -1){
                        if(!gui.ctrlModifier && !gui.shiftModifier)
                            logic.lastTouchedIdx = idx;

                        return logic.selected && typeof logic.selected[idx] !== 'undefined' ? logic.deselect(idx, gui.ctrlModifier, gui.shiftModifier) :
                                                                                                logic.select(idx  , gui.ctrlModifier, gui.shiftModifier);
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
