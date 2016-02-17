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
    Component.onCompleted: {
        MaterialSettings.font.font1 = "FontAwesome"
        MaterialSettings.init()
    }


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
        id : editor

        StateMachineEditor_FileIO{
            id: sme
            anchors.fill : parent
        }
    }


    //this is to simluate a controller environment







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
