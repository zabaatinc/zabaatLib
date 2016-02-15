import QtQuick 2.4
import Zabaat.Material 1.0
import "StateBox"
import "Functions"
Rectangle {
    id : rootObject
    border.width: 1
    color       : 'transparent'
    clip        : true

    signal modelUpdatedInternally(var obj, string json); //use this to save , update the model. This shouldn't be aware of it I feel!!
    property var   model    : null
    property int   cellHeight: 60
    property alias logic   : modelLogic
    property alias gui     : gui

    //these are the default ways to change the statemachine. Override to change and include socketIO or something at the other end!
    //with socketIOController. Ideally, you would just listen to the modelUpdatedInternally signal that this thing emits and
    //just run the save function then.
    property var rename               : modelLogic.rename
    property var saveFunc             : modelLogic.save
    property var loadFunc             : modelLogic.load
    property var createStateBox       : modelLogic.createStateBox
    property var deleteStateBox       : modelLogic.deleteStateBox
    property var createTransition     : modelLogic.createTransition
    property var editTransition       : modelLogic.editTransition
    property var deleteTransition     : modelLogic.deleteTransition
    property var makeDefault          : modelLogic.makeDefault
    property var createFunction       : modelLogic.createFunction
    property var editFunction         : modelLogic.editFunction
    property var deleteFunction       : modelLogic.deleteFunction
    property var state_addFunction    : modelLogic.addFunctionToState
    property var state_editFunction   : modelLogic.editFunctionInState
    property var state_deleteFunction : modelLogic.removeFunctionFromState

    Logic { //handles all the model logic
        id: modelLogic
        width                   : parent.width;
        height                  : parent.height;
        cellHeight              : rootObject.cellHeight    //the cellheight is used to create stateObjects
        model                   : rootObject.model
        stateContainer          : stateContainer     //
        localName               : smName.text       //this is so we can emit changes!
        onModelUpdatedInternally: {
            rootObject.modelUpdatedInternally(obj,json);
            jsonText.text = json;
        }
    }

    Item {  //split up into 3 parts, gui, jsonText, dragger
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

                function handleRightClick(item, coords, addtlparams){
                    if(mode !== 0 && item !== rootObject)
                        return;

                    var name = item.toString().toLowerCase()
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
                function setActiveState(id){  //should only be used for when not editing :)
                    if(!stateContainer || !stateContainer.model)
                        return;

                    for(var i = 0; i < stateContainer.model.count; ++i) {
                        var item = stateContainer.itemAt(i);
                        if(item.modelId === id){
                            item.color = Colors.warning
                            item.colorAnim.start()
                        }
                        else {
                            item.color = Colors.info
                            item.colorAnim.stop()
                        }
                    }
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
            TrashIcon {
                width  : height / 1.5
                height : 70
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 20
            }


            Repeater {
                id : stateContainer
                anchors.fill: parent
                model       : modelLogic.states
                scale       : Math.min(scX,scY)

                property real scX : guilogic.loadedWidth === -1 ?  1 :  width  / guilogic.loadedWidth
                property real scY : guilogic.loadedHeight === -1 ? 1 :  height / guilogic.loadedHeight

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
                    onDelegateRectChanged   : if(model && !mutex && !mutexTimer.running && ready)
                                                  modelLogic.emitChange()
                    onModelRectChanged      : if(ready) syncPosition()
                    getStateItemFunc        : stateContainer.getStateItem
                    onMakeDefaultClicked    : modelLogic.makeDefault(id,name)
                    onRemoveFunction        : rootObject.state_deleteFunction(id,functionName)

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
                    target         : modelLogic.functions
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
                    state : "f2-t2"
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
                model : modelLogic.functions
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
                                        else if(modelLogic[m.func]){
                                            modelLogic[m.func](contextMenu.args, contextMenu.clickedPt.x, contextMenu.clickedPt.y)
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
                text : modelLogic.model ?    JSON.stringify({ id : modelLogic.model.id, name : smName.text,
                                          functions : GFuncs.toArray(modelLogic.functions) ,
                                          states: modelLogic.getStatesJSON() ,
                                          width:rootObject.width,
                                          height: rootObject.height } , null , 2) : ""
            }


        }
        Rectangle{
            id : dragger
            color : Colors.info
            width : 8
            height : parent.height
            x : marea.drag.maximumX

            border.width: 1
            MouseArea {
                id : marea
                anchors.fill: parent
                drag.axis: Drag.XAxis
                drag.minimumX: 0
                drag.maximumX: dragger.parent.width - (dragger.width  * 2)
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

}
