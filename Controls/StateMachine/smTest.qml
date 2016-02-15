import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import Zabaat.Controls.StateMachine 1.0
import Zabaat.Material 1.0
import Zabaat.Utility.FileIO 1.0

Window {
    id : mainWindow
    width : Screen.width
    height : Screen.height - 300
    Component.onCompleted: MaterialSettings.init()


    Connections {
        target: MaterialSettings
        onLoadedChanged : if(MaterialSettings.loaded) {
                              loader.sourceComponent = editor
//                              loader.sourceComponent = smc
//                              loader.source = "StateMachineEditorv2/StateMachineEditor"
                          }
    }
    Loader {
        id : loader
        anchors.fill: parent
//        onLoaded : if(item) item.logic.model = lm.get(0)
    }

    Component {
        id : smc

        Item {

            Column {
                width  : parent.width
                height : parent.height

                StateMachineViewer {
                    id : sm
                    width  : parent.width
                    height : parent.height/2
                    qmlDirectory: Qt.resolvedUrl("qml")
                    onCurrentStateChanged: sme.logic.setActiveState(currentState)
                }

                StateMachineEditor {
                    id : sme
                    width : parent.width
                    height : parent.height/2
                    enabled : false
//                    onLoaded : sm.stateMachinePath = "file:///" + url;
                }

            }
            Component.onCompleted: sme.logic.openFileDialog("load")
        }
    }
    Component {
        id : editor

        Item {
            anchors.fill: parent

            Rectangle {
                width : parent.width
                height : parent.height * 0.05
                anchors.top: parent.top
                color      : Colors.info

                Row {
                    width : parent.height * 2 + spacing
                    height : parent.height
                    spacing : 5
                    anchors.right: parent.right
                    anchors.margins: 5

                    ZButton {
                        //load button
                        text : "Save"
                        width : height
                        height : parent.height
                        state : "ghost-f3"
                        onClicked : zfileio.save()
                    }
                    ZButton {
                        //load button
                        text : "Load"
                        width : height
                        height : parent.height
                        state : "ghost-f3"
                        onClicked : zfileio.load()
                    }
                }
            }
            StateMachineEditor {
                id : sme
                model : lm.get(0)
                width : parent.width
                height : parent.height * 0.95
                anchors.bottom: parent.bottom
            }
            ZFileOperations {
                id : zfileio
                property int saveCounter : 0

                function save(url, json){
                    //if it is still undefined, we need the fd to show up!
                    if(url === null || typeof url === 'undefined' || url === ""){
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

                    if(json === null || typeof json === 'undefined' || json === ""){
                        json = sme.logic.getJSON()
                    }
                    if(zfileio.writeFile(folder,file,json)){
                        console.log("saves performed", ++saveCounter)
                    }
                }
                function load(url){
                    if(url === null || typeof url === 'undefined' || url === ""){
                        fd.mode = "load"
                        fd.open()
                        return;
                    }
                    url = url.toString()
                    url = url.replace("file://", "")
                    url = url.replace('qrc://', "")
                    if(url.indexOf("/") === 0)
                        url = url.slice(1)

                    var txt = zfileio.readFile(url)
                    if(txt){
                        try{
                            var obj = JSON.parse(txt)
                            lm.set(0,obj);
                        }
                        catch(e) {
                            console.log("Load failed", e)
                        }
                    }
                }
            }
            FileDialog {    //default way of saving lading
                id : fd
                property string mode : ""
                selectExisting: mode === 'save' ?  false : true
                nameFilters: [ "JSON (*.json)" ]
                onFileUrlChanged: {
                    if(fileUrl.toString() !== ""){
                        if(mode === "save")    zfileio.save(fileUrl)
                        else                   zfileio.load(fileUrl)
                    }
                }
            }
        }
    }


    //this is to simluate a controller environment

    ListModel {
        id : lm
        dynamicRoles: true
        Component.onCompleted: lm.append(stateMachineObject)
    }


    property var stateMachineObject : ({
                                id   : "someMongoId" ,
                                name : "nameless"    ,
                                functions  : [ {
                                                  id:"0",
                                                  name : "stateChange",
                                                  readOnly : false,
                                                  rules    : [{ name : "id", type :"string", required:true, choices:"" } ,
                                                               { name : "dest", type:"string",required:true, choices:"" } ]
                                                } ,
                                                {
                                                   id       :"1",
                                                   name     : "update",
                                                   readOnly : true,
                                                   rules    : [{ name : "model", type :"object", required:true, choices:"" }]
                                                 }
                                              ] ,
                                states     : [ { id : "0",
                                                  name : "red",
                                                  transitions  : [] ,   //implicit usage
                                                  functions    : []  ,
                                                  x : 100,
                                                  y : 100,
                                                  w : 192,
                                                  h : 64,
                                                  isDefault:true,
                                                }
                                             ]
                             })






//    Rectangle {
//        id : focusShower        //shows us where our focus is!!
//        property var myTarget : mainWindow.activeFocusItem
//        onMyTargetChanged: {
//            if(myTarget) {
//                parent = myTarget
//                anchors.fill = myTarget
//            }
//            else {
//                anchors.fill = null;
//                parent = null;
//            }
//        }
//        opacity : 0.5
//        color   : 'orange'
//        visible : false
//        enabled : false
//    }




}
