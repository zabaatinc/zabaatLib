import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import "StateMachineEditor"
import "StateMachineViewer"
import Zabaat.Material 1.0

ApplicationWindow {
    id : mainWindow
    width : Screen.width
    height : Screen.height - 300
    Component.onCompleted: MaterialSettings.init()


    Connections {
        target: MaterialSettings
        onLoadedChanged : if(MaterialSettings.loaded) {
//                              loader.sourceComponent = editor
                              loader.sourceComponent = smc
                          }
    }


    Loader {
        id : loader
        anchors.fill: parent

    }

    Component {
        id : smc

        Item {

            StateMachine {
                id : sm
                width  : parent.width
                height : parent.height
                qmlDirectory: Qt.resolvedUrl("qml")
                onCurrentStateChanged: sme.logic.setActiveState(currentState)
            }


            Window {

                width : parent.width
                height : parent.height
                visible : true

                StateMachineEditor {
                    id : sme
                    anchors.fill: parent
                    enabled : false
                    onLoaded : sm.stateMachinePath = "file:///" + url;
                }
            }

            Component.onCompleted: sme.logic.openFileDialog("load")
        }
    }
    Component {
        id : editor
        StateMachineEditor {
            id : sme
//                width : parent.width
//                height : parent.height
        }
    }



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
