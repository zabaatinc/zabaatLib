import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import "StateMachineEditor"   as V1
import "StateMachineEditorv2" as V2
import "StateMachineViewer"
import Zabaat.Material 1.0

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

                StateMachine {
                    id : sm
                    width  : parent.width
                    height : parent.height/2
                    qmlDirectory: Qt.resolvedUrl("qml")
                    onCurrentStateChanged: sme.logic.setActiveState(currentState)
                }

                V2.StateMachineEditor {
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

        V2.StateMachineEditor {
            id : sme
            model : lm.get(0)
            anchors.fill: parent

    //                width : parent.width
    //                height : parent.height

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
