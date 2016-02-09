import QtQuick 2.4
import Zabaat.Utility.FileIO 1.0
import Zabaat.Material 1.0
import Zabaat.Utility 1.0
import QtQuick.Dialogs 1.2

Item {
    id : rootObject

//    contentWidth : width
//    contentHeight: height
//    interactive             : true
    signal loaded(string url)
    signal saved(string url)


    property int cellHeight : 40
    property alias logic    : logic

    transform: Scale {
        id : scaley
        xScale : logic.loadedWidth === -1 ?  1 :  width / logic.loadedWidth
        yScale : logic.loadedHeight === -1 ? 1 :  height / logic.loadedHeight
    }

    property alias name : stateMachineNameBox.text

    UIBlocker{
        id: uiBlocker
        anchors.fill: parent
        color       : "black"
        text        : ""
        visible     : logic.mode !== 0
        focus : false

        Text {
            width : parent.width
            height : 64
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment  : Text.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 48
            color : "white"
            text : logic.mode === 1 ? "Click a box to finish creating transition" : ""
            focus : false
        }

    }
    MouseArea {
        id : rightClickDetector
        anchors.fill           : parent
        acceptedButtons        : Qt.RightButton
        onClicked              : logic.handleRightClick(rootObject, Qt.point(mouseX,mouseY))
        propagateComposedEvents: true
        visible                : !areBlocker.visible
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
        visible                : !areBlocker.visible
    }




    Item {  //contains all the stateboxes
        id : stateContainer
        anchors.fill: parent
        enabled : !areBlocker.visible && !aleBlocker.visible

        function getJSON(){
            var arr = []
            for(var i = 0 ; i < children.length; i++){
                var item = children[i]
                var js = item.getJSON()
                js.x = item.x
                js.y = item.y
                //we want to save their location perhaps
                arr.push(js)
            }
            return arr;
        }

    }


    ZTextBox {
        id : stateMachineNameBox
        anchors.horizontalCenter: parent.horizontalCenter
        height : cellHeight * 1.5
        state : "f2"
        width : parent.width * 1/4
        enabled : stateContainer.enabled
        disableShowsGraphically: false
        visible : rootObject.enabled
    }
    Row {
        id : saveLoadButtons
        anchors.right: parent.right
        width : parent.width * 0.1
        height : cellHeight
        enabled : stateContainer.enabled
        visible:  enabled

        ZButton {
            text : "save"
            width : parent.width/2
            height : parent.height
            onClicked : logic.openFileDialog("save")
            state : "success-f2"
        }

        ZButton {
            text : "load"
            width : parent.width/2
            height : parent.height
            onClicked : logic.openFileDialog("load")
            state : "success-f2"
        }
    }


    QtObject {
        id : logic

        property var    map    : ({})
        property string mapStr : ""
        property int    mode   : 0
        property var    modeItem : null

        property real loadedWidth  : -1
        property real loadedHeight : -1


        property color normalStateColor : Colors.info
        property color activeStateColor : Colors.warning

        function setActiveState(stateName){
            for(var i = 0; i < stateContainer.children.length; i++){
                var sbox = stateContainer.children[i]
                sbox.color = sbox.name === stateName ? activeStateColor : normalStateColor
            }
        }

        function modeReset(){
            mode = 0;
            modeItem.enabled = true;
            modeItem = null;
        }
        function rename(name, oldname, item) {
            if(oldname !== "" && logic.map && logic.map[oldname] && logic.map[oldname] === item) {
                delete logic.map[oldname]
            }

            if(logic.map === null || typeof logic.map === 'undefined')
                logic.map = {}

            logic.map[name]  = item;
            item.oldName     = name;

            var str = ""
            for(var m in logic.map){
                str += m + "\n"
            }
            mapStr = str;
        }
        function nameValidation(name, oldText, self){
            if(self.oldName === name)
                return null;

            if(logic.map && logic.map[name]){
                return "name already exists"
            }
            if(name.length === 0 || name.trim().length === 0)
                return "too short"
            if(!isNaN(name))
                return "starts with digit"

            return null;
        }
        function handleRightClick(item, coords, addtlparams) {
            if(mode !== 0 && item !== rootObject)
                return;

            var name = item.toString().toLowerCase()
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
                else if(addtlparams === 'action')
                {
                    ale.target = null
                    ale.target = item;
                }
            }
            else if(name.indexOf("statetransition") === 0){
                var pt = item.mapToItem(rootObject);
                pt.x += item.width/2
                showContextMenu(menuModels.stateTransition, pt.x, pt.y, item);
            }

//            statetransition_qmltype_33

        }
        function handleLeftClick(item, coords){
            if(logic.mode === 1 && item !== modeItem){  //hey we chose a different statebox!!
                modeItem.logic.addTransition(item);
                modeReset()
            }
        }

        function createStateBox(args, x,y){
            var obj = stateBoxFactory.createObject(stateContainer);
            obj.x = x;
            obj.y = y;
            obj.forceActiveFocus()
            return obj;
        }
        function deleteStateBox(item,x,y) {
            item.destroy()
        }

        function editTransition(item,x,y){
            are.target = null;
            are.target = item;
        }
        function deleteTransition(item,x,y){
            item.destroy()
        }


        function createTransition(item,x,y){
            if(item) {
                modeItem         = item;
                modeItem.enabled = false;
                mode             = 1;       //transition mode

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

        function openFileDialog(mode){
            fd.mode = mode;
            fd.open()
        }
        function save(url){
            var arr = url.toString().split("/")
            var file = arr[arr.length-1]

            arr.splice(arr.length -1, 1)
            var folder = arr.join("/")

            folder = folder.replace("file:///", "")
            folder = folder.replace('qrc:///', "")

//            console.log(folder,file)
            var obj = JSON.stringify({ name : name, states: stateContainer.getJSON() , width:rootObject.width, height: rootObject.height } , null , 2)

//            console.log(obj)

            if(zfileio.writeFile(folder,file,obj)){
               rootObject.saved(folder + "/" + file)
            }
        }
        function load(url){
            clear()


//            var arr = url.split("/")
//            var file = arr[arr.length-1]
            var folder = url.toString()
            folder = folder.replace("file:///", "")
            folder = folder.replace('qrc:///', "")
//            arr.splice(arr.length -1, 1)
//            var folder = arr.join("/")

            var text = zfileio.readFile(folder)
//            console.log(text)
            try {
                var obj = JSON.parse(text)
                if(obj){
                    rootObject.loaded(folder);

                    name = obj.name
                    logic.loadedWidth  = obj.width ? obj.width   : rootObject.width
                    logic.loadedHeight = obj.width ? obj.height  : rootObject.height



                    //loop once, creating all the states
                    for(var i = 0; i < obj.states.length; i++){
                        var stateData = obj.states[i]
                        var stateObj = logic.createStateBox(null, stateData.x, stateData.y)


                        stateObj.x = stateData.x
                        stateObj.y = stateData.y

                        logic.map[stateData.name] = stateObj
                        stateObj.oldName = stateObj.name = stateData.name
//                        console.log(stateObj.name)
                    }

                    //loop second time, (now we have map), loading all the data into them!!
                    for( i = 0; i < obj.states.length; i++){
                        stateData = obj.states[i]
                        stateObj  = logic.map[stateData.name]

                        if(stateObj){
                            for(var t = 0; t < stateData.transitions.length; t++){
                                var trans = stateData.transitions[t]
                                var dest = logic.map[trans.state]
                                if(dest){
                                    var tObj = stateObj.logic.addTransition(dest)
                                    tObj.name = trans.name
                                    tObj.rules = trans.rules
                                }

                            }
                            for(var a = 0; a < stateData.actions.length; a++){
                                var action = stateData.actions[a]
                                stateObj.logic.addAction(action.name,action.rules);
                            }
                        }
                    }


                }
            }
            catch(e) {
                console.error(e)
            }

        }

        function clear(){
            name = ""
            for(var i = stateContainer.children.length -1; i >= 0;  i--){
                var item = stateContainer.children[i]
                item.parent = null;
                item.destroy();
            }
            logic.map = {}
        }


        property Component stateBoxFactory : Component {
            id : stateBoxFactory
            StateBox {
                id : sb
                width         : cellHeight * 3
                height        : cellHeight * 1.5
                onLeftClicked           : rootObject.logic.handleLeftClick(self,Qt.point(x,y))
                onRightClicked          : rootObject.logic.handleRightClick(self,Qt.point(x,y))
                onTransitionRightClicked: rootObject.logic.handleRightClick(transition,Qt.point(x,y))
                onActionsClicked        : rootObject.logic.handleRightClick(self,Qt.point(x,y),"action")
                onAccepted    : rootObject.logic.rename(name,oldName, sb);
                vFunc         : rootObject.logic.nameValidation
                mode          : rootObject.logic.mode
            }
        }


        property ZFileOperations zfileio : ZFileOperations { id : zfileio }


        property var menuModels: ({ rootObject : [{name: "Create" , func: "createStateBox" }  ] ,
                                    stateBox   : [{name: "Create Transition" , func : "createTransition" } ,
                                                  {name: "Delete"            , func : "deleteStateBox"   } ,

                                                 ] ,
                                    stateTransition   : [{name: "Edit"       , func : "editTransition" } ,
                                                         {name: "Delete"     , func : "deleteTransition"   } ,
                                                        ] ,
                                     cancel    : [{name: "Cancel" , func: "modeReset" }  ]

                                  })


    }

    UIBlocker {
        id : areBlocker
        anchors.fill: parent
        visible : are.target !== null
        color : 'black'
        RulesEditor{
           id : are
           width : parent.width/2
           height : parent.height/2
           anchors.centerIn: parent
           onTargetChanged: if(target)
                                forceActiveFocus()
           onFinished: target = null;
        }
    }
    UIBlocker {
        id : aleBlocker
        anchors.fill: parent
        visible : ale.target !== null
        color : 'black'
        ActionsListEditor{
            id : ale
            width : parent.width/2
            height : parent.height/2
            anchors.centerIn: parent
            onTargetChanged: if(target)
                                 forceActiveFocus()
            onFinished: ale.target= null;
        }
    }



    ListView {
        id       : contextMenu
        width    : cellHeight * 4
        height   : model && model.length ? model.length * cellHeight : 0
        model    : null   //ListModel { id: lm; dynamicRoles : true; }
        onActiveFocusChanged: if(!activeFocus)
                                visible = false;

        property var   args      : null
        property point clickedPt : Qt.point(0,0);
        focus : false

        delegate : ZButton {
            state : "success-f2"
            width : contextMenu.width
            height: cellHeight
            focus : false

            property var m : contextMenu.model ? contextMenu.model[index] : null
            text           : m && m.name ? m.name : ""
            onClicked      : if(m && m.func) {
                                logic[m.func](contextMenu.args, contextMenu.clickedPt.x, contextMenu.clickedPt.y)
                                contextMenu.visible = false;
                             }
        }
    }


    Text {
        width: parent.width/2
        height: parent.height
        text : logic.mapStr
        font.pixelSize: 32
        focus : false
    }




//    Component.onCompleted:  {
//        fd.folder = DeviceInfo.os === "windows" ? "file:///" +  Constants.paths.pictures : Constants.paths.pictures
//        console.log(Constants.paths.pictures, fd.folder)
//        fd.open()
//    }

    FileDialog {
        id : fd
        property string mode : ""
        selectExisting: mode === 'save' ?  false : true
//        folder     : Constants.paths.pictures
        nameFilters: [ "JSON (*.json)" ]
//        onRejected : App.loadPage(Constants.qmls.homepage)
        onFileUrlChanged: {
            if(fileUrl.toString() !== ""){
                if(mode === "save") {
                    logic.save(fileUrl)
                }
                else {
                    logic.load(fileUrl)
                }
            }
        }
    }


}

