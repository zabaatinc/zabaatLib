import QtQuick 2.4
import Zabaat.Material 1.0
import Zabaat.Utility 1.0
import Zabaat.Utility.FileIO 1.0
import QtQuick.Dialogs 1.2
import "StateBox"
import "Functions"
import QtQuick.Controls 1.4

Rectangle {
    id : rootObject
    border.width: 1
    color       : 'transparent'
    clip        : true

    property var  model   : null

    property int cellHeight: 64
//    onModelChanged : console.log(JSON.stringify(model,null,2))
    property alias logic  : logic
    property alias gui    : gui

    //these are the default ways to change the statemachine. Override to change and include socketIO or something at the other end!
    //with socketIOController
    property var rename               : logic.defaultFunctions.rename
    property var saveFunc             : logic.defaultFunctions.save
    property var loadFunc             : logic.defaultFunctions.load
    property var createStateBox       : logic.defaultFunctions.createStateBox
    property var deleteStateBox       : logic.defaultFunctions.deleteStateBox
    property var createTransition     : logic.defaultFunctions.createTransition
    property var editTransition       : logic_defaultFunctions.editTransition
    property var deleteTransition     : logic.defaultFunctions.deleteTransition
    property var makeDefault          : logic.defaultFunctions.makeDefault
    property var createFunction       : logic_defaultFunctions.createFunction
    property var editFunction         : logic_defaultFunctions.editFunction
    property var deleteFunction       : logic_defaultFunctions.deleteFunction
    property var state_addFunction    : logic_defaultFunctions.addFunctionToState
    property var state_editFunction   : logic_defaultFunctions.editFunctionInState
    property var state_deleteFunction : logic_defaultFunctions.removeFunctionFromState



    property bool saveOnUpdate  : true  //call save on update?
    property bool virtualSave   : true

//    onModelChanged : updateModelTimer.start()
//    Timer {
//        id          : updateModelTimer
//        interval    : 1000
//        onTriggered : logic.model = model
//        onRunningChanged : if(running) console.log(logic, logic.defaultFunctions, logic.defaultFunctions.getState)
//    }

    QtObject {
        id : logic
        objectName : "StateMachineEditor_Logic"
        property alias model : rootObject.model
        property string id              : model && model.id        ? model.id        : ""
        property string name            : model && model.name      ? model.name      : ""
        property var functions          : model && model.functions ? model.functions : null
        property var states             : model && model.states    ? model.states    : null



        property QtObject defaultFunctions : QtObject {
            id : logic_defaultFunctions
            property string fileUrl : ""
            property int saveCounter : 0

            function makeDefault(id){

                if(!model)
                    return;

                var idx = indexOf(id)
                if(idx !== -1){
                    for(var i = 0 ; i < logic.states.count; ++i){
                        var item = logic.states.get(i)
                        item.isDefault = idx === i ? true : false;
                    }
                    if(saveOnUpdate)
                        saveFunc()
                }
            }
            function createStateBox(args, x,y){
                if(!logic.states)
                    return;

                var obj = defaultStateObject
                obj.x   = x
                obj.y   = y
                obj.h   = cellHeight
                obj.w   = obj.h * 3
                obj.id  = (maxId(logic.states) + 1).toString()

                logic.states.append(_.clone(obj))
                if(saveOnUpdate)
                    saveFunc()
            }
            function deleteStateBox(item,x,y){
                var idx = indexOf(item.modelId)
                if(idx !== -1){
                    logic.states.remove(idx)
                    if(saveOnUpdate)
                        saveFunc()
                }
            }
            function save(url){
//                console.trace()
                if(_.isUndefined(url))
                    url = fileUrl;

                //if it is still undefined, we need the fd to show up!
                if(url === "" && !virtualSave){
                    fd.mode = "save"
                    fd.open()
                    return;
                }


                var arr = url.toString().split("/")
                var file = arr[arr.length-1]

                arr.splice(arr.length -1, 1)
                var folder = arr.join("/")

                folder = folder.replace("file:///", "")
                folder = folder.replace('qrc:///', "")

                var obj = JSON.stringify({ id : logic.model.id, name : smName.text,
                                           functions : GFuncs.toArray(logic.functions) ,
                                           states: stateContainer.getJSON() ,
                                           width:rootObject.width,
                                           height: rootObject.height } , null , 2)

    //            console.log(obj)
                if(virtualSave){
                    jsonText.text = obj;
                }
                else if(zfileio.writeFile(folder,file,obj)){
                    console.log("saves performed", ++saveCounter)

//                   rootObject.saved(folder + "/" + file)
                }
            }
            function load(url){

            }
            function rename(id, name){
                function renameAllTransitions(oldName, newName){
                    //iterate over all states, go into their transitions and change dest if it matches oldName
                    if(logic.states){
                        var numUpdated = 0;
                        for(var i =0; i < logic.states.count; i++){
                            var sObj = logic.states.get(i);
                            var transitions = sObj.transitions
                            if(transitions){
                                for(var t = 0; t < transitions.count; t++){
                                    var trans = transitions.get(t)
                                    if(trans.dest === oldName){
                                        trans.dest = newName
                                        numUpdated++;
                                    }
                                }
                            }
                        }
                        console.log("transitions updated as a result:", numUpdated)
                    }
                }

                var idx = indexOf(id)
                if(idx !== -1){
                    //rename all transitions too! that were going to this state!
                    var item    = logic.states.get(idx)

                    renameAllTransitions(item.name,name)
                    item.name = name;

                    if(saveOnUpdate)
                        saveFunc()
                }
            }
            function createTransition(source, destination){
//                console.log(source, destination)
                var sModel = getState(source);
                var dModel = getState(destination)
                if(sModel && dModel){
                    var t = _.clone(defaultTransObject)
                    t.dest = destination;
                    sModel.transitions.append(t)
                    if(saveOnUpdate)
                        saveFunc()
                }
                else {
                    console.log("ERROR when creating transition",  source,":",sModel,"\t",destination,":",dModel )
                }
            }
            function deleteTransition(originName, destinationName, friendlyName){
                //find origin state
                var sModel = getState(originName)
                var tIndex = getTransition(originName, destinationName, friendlyName, true)
                if(tIndex !== -1){
                    sModel.transitions.remove(tIndex);
                    if(saveOnUpdate)
                        saveFunc()
                }
            }
            function editTransition(originName, destinationName, oldName, newName, rules){
                //TODO
                console.log(originName,destinationName,oldName,newName,rules)
                var idx = getTransition(originName, destinationName, oldName, true)
                if(idx !== -1){
                    var sModel = getState(originName)
                    var t = _.clone(defaultTransObject)
                    t.name = newName ? newName : oldName ? oldName : ""
                    t.dest = destinationName;
                    t.rules = rules;
                    sModel.transitions.set(idx,t);  //overwrite the thinger!
                    if(saveOnUpdate)
                        saveFunc()
                }
            }

            function createFunction(name, rules){
                var idx = getFunction(name,true)
                if(idx === -1){  //does not exist!
                    var mId = (maxId(logic.functions) + 1).toString()
                    var fObj ={id : mId ,name : name, rules : rules }
                    logic.functions.append(fObj)
                    if(saveOnUpdate)
                        saveFunc()
                    return;
                }
//                console.log("function", name, "alreay exists!")
            }
            function editFunction(id, rules, name){
                var idx = getFunctionById(id,true)
//                console.log("edit function called", id, name, JSON.stringify(rules,null,2))
//                console.log("in hurr, idx", idx)
//                console.log( JSON.stringify(GFuncs.toArray(logic.functions) ,null , 2))

                function updateAllStates(fId, oldName, newName){ //useful if the function was renamed!
                    var updateCount = 0;
                    for(var i =0; i < logic.states.count; ++i){
                        var s = logic.states.get(i)
                        var fList = s.functions;
                        if(fList){
                            for(var f = 0; f < fList.count; ++f){
                                var fItem = fList.get(f)
                                if(typeof fItem === 'string' && fItem === oldName){
                                    fList.set(f,newName)
                                    updateCount++
                                }
                                else if(typeof fItem === 'object' && fItem.id === fId){
                                    fItem.name = newName
                                    updateCount++
                                }
                            }
                        }
                    }
                }

                if(idx !== -1){
                    var f   = logic.functions.get(idx);

                    var fObj ={id : id, name : name, rules : rules }
                    if(name !== f.name){
                        updateAllStates(id, f.name, name)  //update all states that were saying we allow this func
                    }

//                    console.log("SETTING rulezuues to", JSON.stringify(fObj,null,2))
                    logic.functions.set(idx,fObj)

                    if(saveOnUpdate)
                        saveFunc()
                }
                else {
                    console.log(id, name, "function not found. Sorry. Try again later.")
                }
            }
            function deleteFunction(id, name){
                var idx = getFunctionById(id, true)
                if(idx !== -1){
                    logic.functions.remove(idx)
                    if(saveOnUpdate)
                        saveFunc()
                }
            }

            function addFunctionToState(id, fn){
                var idx = indexOf(id)
                if(idx !== -1){
                    var s = logic.states.get(idx)
                    if(fnIndexInState(s,fn) === -1){
//                        console.log('adding function')
                        s.functions.append({name : fn , rules : []})
                        if(saveOnUpdate)
                            saveFunc()
                    }
                }
            }
            function removeFunctionFromState(id, fn){
                var idx = indexOf(id)
                if(idx !== -1){
                    var s = logic.states.get(idx)
                    var fIndex = fnIndexInState(s,fn) !== -1
                    if(fIndex !== -1){
                        s.functions.remove(fIndex)
                        if(saveOnUpdate)
                            saveFunc()
                    }
                }
            }
            function editFunctionInState(id, fn, rules){
                var idx = indexOf(id)
                if(idx !== -1){
                    var s = logic.states.get(idx)
                    var fIndex = fnIndexInState(s,fn) !== -1
                    if(fIndex !== -1){
                        var fObj = { name : fn, rules : rules }
                        s.functions.set(fIndex,fObj)
                        if(saveOnUpdate)
                            saveFunc()
                    }
                }
            }


            //helpers
            function fnIndexInState(stateObj, fName){
                var functions = stateObj.functions
                for(var i = 0; i < functions.count; i++){
                    var fItem = functions.get(i)
                    if(typeof fItem === 'string' && fName === fItem)
                        return i;
                    else if(typeof fItem === 'object' && fItem.name === fName)
                        return i
                }
                return -1
            }

            function getFunction(name, giveMeIndex){
                if(logic.functions){
                    for(var i = 0; i < logic.functions.count; ++i){
                        var f= logic.functions.get(i)
                        if(f.name === name)
                            return giveMeIndex ? i : f;
                    }
                }
                return giveMeIndex ? -1 : null
            }
            function getFunctionById(id, giveMeIndex){
                if(logic.functions){
                    for(var i = 0; i < logic.functions.count; ++i){
                        var f= logic.functions.get(i)
//                        console.log("comparing",id, "with", f.id)
                        if(f.id === id)
                            return giveMeIndex ? i : f;
                    }
                }
                return giveMeIndex ? -1 : null
            }
            function getTransition(originName, destinationName, friendlyName, giveMeIndex){
                var sModel = getState(originName)
//                var dModel = getState(dModel)
                if(sModel){
                    var transitions = sModel.transitions
                    for(var t = 0; t < transitions.count; ++t){
                        var trans = transitions.get(t)
                        if(trans.dest === destinationName){
                            if(_.isUndefined(friendlyName) || friendlyName === ""){
                                return giveMeIndex ? t : trans
                            }
                            else if(trans.name === friendlyName){
                                return giveMeIndex ? t : trans
                            }
                        }
                    }
                }

                return giveMeIndex ? -1 : null;
            }
            function getState(name){
                if(logic.states){
                    for(var i = 0; i < logic.states.count; i++){
                        var item = logic.states.get(i)
//                        console.log(JSON.stringify(item,null,2))
                        if(item.name == name)
                            return item
                    }
                }
//                console.log("getState NOT FOUND")
                return null
            }
            function getStateById(id){
                var idx = indexOf(id)
                if(idx)
                    return logic.states.get(idx)
            }
            function indexOf(id){
                if(logic.states){
                    for(var i = 0; i < logic.states.count; i++){
                        var item = logic.states.get(i)
                        if(item && item.id == id)
                            return i
                    }
                }
                return -1;
            }
            function maxId(lm){
                var max = -1;
                if(lm){
                    for(var i = 0; i < lm.count; i++){
                        max = Math.max(max, +  lm.get(i).id )
                    }
                }
                return max;
            }

            property var defaultStateObject : ({ id : "", name : "", functions:[], transitions:[], isDefault : false })
            property var defaultTransObject : ({name: "", dest : "", rules:[]                                        })

            property ZFileOperations zfileio : ZFileOperations { id : zfileio }

        }


        function funcNameValidation(name, oldText, self){
            if(name === self.name)
                return null;

            function nameExists(name){
                if(functions){
                    for(var i = 0; i < functions.count; i++){
                        var item = functions.get(i)
                        if(item.name === name)
                            return true;
                    }
                }
                return false;
            }

            if(name.length === 0 || name.trim().length === 0)
                return "too short"

            if(!isNaN(name))
                return "starts with digit"

            if(nameExists(name)){
                return "name already exists"
            }

//            console.log("RETurning null!")
            return null;
        }
        function nameValidation(name, oldText, self){
            if(name === self.name)
                return null;

            function nameExists(name){
                if(states){
                    for(var i = 0; i < states.count; i++){
                        var item = states.get(i)
                        if(item.name === name)
                            return true;
                    }
                }
                return false;
            }

            if(name.length === 0 || name.trim().length === 0)
                return "too short"

            if(!isNaN(name))
                return "starts with digit"

            if(nameExists(name)){
                return "name already exists"
            }

//            console.log("RETurning null!")
            return null;
        }
    }


    Item {
        anchors.fill: parent

        Rectangle {
            id : gui
//            anchors.fill: parent
            width : parent.width - (parent.width - dragger.x)
            height : parent.height
            anchors.right: dragger.left
//            border.width:
            property real xScl : width / parent.width
            property real yScl : height / parent.height
            scale : Math.min(xScl,yScl)


            property color normalStateColor : Colors.info
            property color activeStateColor : Colors.warning
            property alias cellHeight : rootObject.cellHeight

            property QtObject guilogic : QtObject {
                id : guilogic
                property int    mode      : 0       //the current state the gui is in (contextually)
                property var    modeItem  : null     //the item that changed the guimode
                property real loadedWidth : model && model.width ?  model.width  : -1
                property real loadedHeight: model && model.height?  model.height : -1


    //            Component.onCompleted: {
    //                console.log(hashFunc("a"))
    //                console.log(hashFunc("aa"))
    //                console.log(hashFunc("aaaaaaaaaaaaaaaaaaa"))
    //            }
                function handleRightClick(item, coords, addtlparams){
                    if(mode !== 0 && item !== rootObject)
                        return;

                    var name = item.toString().toLowerCase()
                    console.log(name)
        //            console.log(name)

                    if(item === rootObject) {
                       if(mode === 0){
                            showContextMenu(menuModels.rootObject, coords.x, coords.y);
                       }
                       else {
                            showContextMenu(menuModels.cancel, coords.x, coords.y)
                       }
                    }
                    else if(name.indexOf("statebox") === 0){
                        if(!addtlparams)
                            showContextMenu(menuModels.stateBox, item.x + item.width, item.y, item);
                        else if(addtlparams === 'functions')
                        {
                            functionsDefiner.target = null
                            functionsDefiner.target = item;
                        }
                    }
                    else if(name.indexOf("statetransitionmodelobject") === 0){
//                        var pt = item.mapToItem(rootObject);
//                        pt.x += item.width/2
                        showContextMenu(menuModels.stateTransition, coords.x, coords.y,  item);
                    }

                }
                function handleLeftClick(item, coords){
                    if(mode === 1 && item !== modeItem){  //hey we chose a different statebox!!
                        createTransition(modeItem.name,item.name)
    //                    modeItem.logic.addTransition(item);  //
                        mode = 0;
                        modeItem.enabled = true;
                        modeItem = null;
                    }
                }
                function showContextMenu(model,x,y, src) {
                    contextMenu.clickedPt = Qt.point(x,y);
                    contextMenu.args    = src;
                    contextMenu.model   = model;
                    contextMenu.x       = x;
                    contextMenu.y       = y;
                    contextMenu.visible = true;
                    contextMenu.forceActiveFocus()
                }
                function beginEditingTransition(obj){
                    transitionNamer.target = obj;
                    transitionNamerBlocker.visible = true;
                }
                function modeReset(){
                    mode = 0;
                    modeItem.enabled = true;
                    modeItem = null;
                }

                function enterTransitionCreationMode(item,x,y){
                    if(item) {
                        modeItem         = item;
                        modeItem.enabled = false;
                        mode             = 1;       //transition mode
                    }
                }
                function beginDeletingTransition(args,x,y){
                    deleteTransition(args.originName, args.destinationName, args.name)
                }

                property var menuModels: ({ rootObject : [{name: "Create State"      , func: "createStateBox" }  ] ,
                                            stateBox   : [{name: "Create Transition" , func : "enterTransitionCreationMode" } ,
                                                          {name: "Delete"            , func : "deleteStateBox"   } ,
                                                         ] ,
                                             stateTransition: [  {name: "Edit"       , func : "beginEditingTransition"  } ,
                                                                 {name: "Delete"     , func : "beginDeletingTransition"} ,
                                                                ] ,
                                             cancel    : [{name: "Cancel" , func: "modeReset" }  ]
                                           })
            }

            Rectangle{
                anchors.fill: parent
                color       : "black"
                visible     : guilogic.mode !== 0
                focus       : false
                opacity     : 0.5

                Text {
                    width                   : parent.width
                    height                  : 64
                    horizontalAlignment     : Text.AlignHCenter
                    verticalAlignment       : Text.AlignVCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize          : 48
                    color                   : "white"
                    text                    : guilogic.mode === 1 ? "Click a box to finish creating transition" : ""
                    focus                   : false
                }
            }
            MouseArea {
                id : rightClickDetector
                anchors.fill           : parent
                acceptedButtons        : Qt.RightButton
                onClicked              : guilogic.handleRightClick(rootObject, Qt.point(mouseX,mouseY))
                propagateComposedEvents: true
                visible                : !functionsDefBlocker.visible
            }
            MouseArea {
                id : leftClickDetector
                anchors.fill    : parent
                acceptedButtons : Qt.LeftButton
                onClicked       :  {
                    contextMenu.visible = false;
                    forceActiveFocus()
                }
                propagateComposedEvents: true
                visible                : !functionsDefBlocker.visible
            }

            //Repeaters are cooler than listview here because it doesn't try to do fancy stuff in the background!!
            //for us to display the model! They will all have user defined x and y positions!
            Repeater {
                id : stateContainer
                anchors.fill: parent
                model       : logic.states
                scale       : Math.min(scX,scY)

                property real scX : guilogic.loadedWidth === -1 ?  1 :  width  / guilogic.loadedWidth
                property real scY : guilogic.loadedHeight === -1 ? 1 :  height / guilogic.loadedHeight

                function getJSON(){
                    var arr = []
                    for(var i = 0; i < model.count; ++i){
                        var item = itemAt(i)
                        if(item){
                            arr.push(item.getJSON())
                        }
                    }
                    return arr;
                }
                function getStateItem(name){
                    if(!model)
                        return null;

                    for(var i =0 ; i< model.count; ++i){
                        var item = stateContainer.itemAt(i);
                        if(item && item.name === name){
                            return item
                        }
                    }
                    return null;
                }

                delegate: StateBox {
                    id : sb
                    m : model
                    objectName : name
                    color                   : gui.normalStateColor
                    vFunc                   : rootObject.logic.nameValidation
                    mode                    : guilogic.mode
                    onAccepted              : rootObject.rename(id,name);
                    onLeftClicked           : guilogic.handleLeftClick (self,Qt.point(x,y))
                    onRightClicked          : guilogic.handleRightClick(self,Qt.point(x,y))
                    onTransitionRightClicked: guilogic.handleRightClick(transition,Qt.point(x,y))
                    onFunctionsClicked      : guilogic.handleRightClick(self,Qt.point(x,y),"function")
                    onDelegateRectChanged   : if(rootObject.saveOnUpdate && model && !mutex && !mutexTimer.running && ready) saveFunc()
                    onModelRectChanged      : if(ready) syncPosition()
                    getStateItemFunc        : stateContainer.getStateItem
                    onMakeDefaultClicked    : logic_defaultFunctions.makeDefault(id,name)

                    property int _index       : index
                    property bool imADelegate : true
                    property bool mutex : true;
                    property bool ready : modelRect.x !== -999 && modelRect.y !== -999 && modelRect.width !== -999 && modelRect.height !== -999

                    property rect modelRect : model && model.x && model.y && model.w && model.h ? Qt.rect(model.x,model.y,model.w,model.h) :
                                                                                                  Qt.rect(-999,-999,-999,-999)
                    property rect delegateRect : Qt.rect(x,y,width,height)

                    function syncPosition(){
                        if(!ready)
                            return;

                        mutex = true;
                        mutexTimer.start()

                        x      = modelRect.x
                        y      = modelRect.y
                        width  = modelRect.width
                        height = modelRect.height

                        mutex = false;
                    }


                    Timer {
                        id : mutexTimer
                        interval : 10
                        running : false
                        repeat : false
                    }

    //                Text {
    //                    id : debugText
    //                    anchors.top : parent.bottom
    //                    text : parent.modelId + ":" + parent.x + "," + parent.y + "\n" + parent.name
    //                    font.pixelSize: parent.height * 1/6
    //                    anchors.horizontalCenter: parent.horizontalCenter
    //                }
                }

            }


            ZTextBox {
                id : smName
                anchors.horizontalCenter: parent.horizontalCenter
                height : gui.cellHeight * 1.5
                state : "f2"
                width : parent.width * 1/4
                enabled : stateContainer.enabled
                disableShowsGraphically: false
                visible : rootObject.enabled
                text    : model && model.name ? model.name : ""

            }


            UIBlocker {
                id : functionsDefBlocker
                anchors.fill: parent
                visible : functionsDefiner.target !== null && functionsDefiner.show
                color : 'black'
                ActionsListEditor{
                    property bool show : false
                    id : functionsDefiner
                    anchors.right: parent.right
                    height : parent.height
                    width  : parent.width - rootObject.cellHeight
                    target         : logic.functions
                    onTargetChanged: if(target)
                                         forceActiveFocus()
                    vFunc : rootObject.logic.funcNameValidation
                    cellHeight: rootObject.cellHeight
    //                onFinished: functionsDefiner.target= null;

                    onAddFunction   : rootObject.createFunction(name,rules)
                    onEditFunction  : rootObject.editFunction(id,rules,name)
                    onDeleteFunction: rootObject.deleteFunction(id,name)
                }
            }
            UIBlocker {
                id : transitionNamerBlocker
                anchors.fill: parent
                solidBackGround: false
                color : 'black'
                visible : false

                ZTextBox {
                    id : transitionNamer
                    property var target : null
                    anchors.centerIn: parent
                    width : parent.width * 0.3
                    height : cellHeight
                    label : "Enter Friendly Name for transition"
                    text  : target && target.name ? target.name : ""
                    onAccepted: {
                        editTransition(target.origin,target.dest,target.name, text, GFuncs.toArray(target.rules))
                        transitionNamer.target = null;
                        transitionNamerBlocker.visible = false;
                    }
                }

                Keys.onEscapePressed: { transitionNamer.target = null; transitionNamerBlocker.visible = false; }

            }


            ListView {
                id : functionDropper
                width  : cellHeight * 2
                height : parent.height - cellHeight
                model : logic.functions
                interactive : false
                visible : !functionsDefiner.visible
                anchors.top: parent.top
                anchors.topMargin: cellHeight + 20
                anchors.left: parent.left

                delegate : Item {
                    id : dragDelegate
                    width : functionDropper.width
                    height : cellHeight/2
                    property alias color : dragItem.color

                    ZButton {
                        width  : parent.width - parent.height
                        height : parent.height
                        state         : "ghost-f2"
                        text          : name
                    }
                    Item {  //this item just exists so x : 0, y : 0 is reset position
                        anchors.right: parent.right
                        width : height
                        height : parent.height
                        Rectangle {
                            id            : dragItem
                            border.width  : 1
                            width : parent.width
                            height : parent.height
                            Drag.keys     : ['function']
                            Drag.active   : ma.drag.active
                            Drag.hotSpot.x: width/2
                            Drag.hotSpot.y: height/2
                            color : GFuncs.colorhashFunc(name)
                            MouseArea {
                                id : ma
                                anchors.fill: parent
                                drag.target: parent
                                onReleased :  {
                                  var dropee = dragItem.Drag.target
                                  if(dropee)
                                      state_addFunction(dropee.root.modelId,name)

                                  dragItem.x = dragItem.y = 0
                                }
                            }
                        }

                    }
                }

            }





            Row {
                width : parent.width
                height : cellHeight

                ZButton {
                    text : "fx"
                    state : !functionsDefiner.visible ? "ghost-f2" : "ghost-f2-t2"
                    onClicked :functionsDefiner.show = !functionsDefiner.show
                    width : cellHeight
                    height : cellHeight
                }

            }
            ListView {
                id       : contextMenu
                width    : gui.cellHeight * 4
                height   : model && model.length ? model.length * gui.cellHeight : 0
                model    : null   //ListModel { id: lm; dynamicRoles : true; }
                onActiveFocusChanged: if(!activeFocus)
                                        visible = false;

                property var   args      : null
                property point clickedPt : Qt.point(0,0);
                focus : false

                delegate : ZButton {
                    state : "success-f2"
                    width : contextMenu.width
                    height: gui.cellHeight
                    focus : false

                    property var m : contextMenu.model ? contextMenu.model[index] : null
                    text           : m && m.name ? m.name : ""
                    onClicked      : if(m && m.func) {
                                        if(rootObject[m.func]) {
                                            rootObject[m.func](contextMenu.args, contextMenu.clickedPt.x, contextMenu.clickedPt.y)
                                        }
                                        else if(logic.defaultFunctions[m.func]){
                                            logic.defaultFunctions[m.func](contextMenu.args, contextMenu.clickedPt.x, contextMenu.clickedPt.y)
                                        }
                                        else if(logic[m.func]){
                                            logic[m.func](contextMenu.args, contextMenu.clickedPt.x, contextMenu.clickedPt.y)
                                        }
                                        else if(guilogic[m.func]){
                                            guilogic[m.func](contextMenu.args, contextMenu.clickedPt.x, contextMenu.clickedPt.y)
                                        }
                                        contextMenu.visible = false;
                                     }
                }
            }
        }
        Flickable {
            id : jsonView
            anchors.left: dragger.right
//            Layout.minimumWidth : 40
            width : parent.width - gui.width
            height : parent.height
            contentHeight: jsonText.paintedHeight
            Rectangle{
                anchors.fill: parent
            }

            Text {
                id : jsonText
                font.pointSize: 14
                text : JSON.stringify({ id : logic.model.id, name : smName.text,
                                          functions : GFuncs.toArray(logic.functions) ,
                                          states: stateContainer.getJSON() ,
                                          width:rootObject.width,
                                          height: rootObject.height } , null , 2)
            }


        }



        Rectangle{
            id : dragger
            color : Colors.info
            width : 8
            height : parent.height
            x : parent.width * 0.9

            border.width: 1
            MouseArea {
                id : marea
                anchors.fill: parent
                drag.axis: Drag.XAxis
                drag.minimumX: 0
                drag.maximumX: dragger.parent.width - dragger.width
                drag.target: parent
            }
//            onXChanged : {
//                var leftSide = dragger.parent.width - x
//                var rightSide = dragger.parent.width - leftSide
//                gui.width = leftSide
//                jsonView.width = rightSide
//            }
            z : 999
        }

    }








//    UIBlocker {
//        id : aleBlocker
//        anchors.fill: parent
//        visible : ale.target !== null
//        color : 'black'
//        ActionsListEditor{
//            id : ale
//            width : parent.width/2
//            height : parent.height/2
//            anchors.centerIn: parent
//            onTargetChanged: if(target)
//                                 forceActiveFocus()
//            onFinished: ale.target= null;
//        }
//    }



    FileDialog {    //default way of saving lading
        id : fd
        property string mode : ""
        selectExisting: mode === 'save' ?  false : true
//        folder     : Constants.paths.pictures
        nameFilters: [ "JSON (*.json)" ]
//        onRejected : App.loadPage(Constants.qmls.homepage)
        onFileUrlChanged: {
            logic.defaultFunctions.fileUrl = fileUrl.toString()
            if(fileUrl.toString() !== ""){
                if(mode === "save") {
                    saveFunc(fileUrl)
                }
                else {
                    loadFunc(fileUrl)
                }
            }
        }
    }



}
