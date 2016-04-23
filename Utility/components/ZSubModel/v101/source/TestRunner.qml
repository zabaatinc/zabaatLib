import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import Qt.labs.folderlistmodel 2.1

Window {
    visible: true
    width : Screen.width
    height : Screen.height - 300

    Column {
        anchors.fill: parent
        ListView {
            id : lv
            orientation: ListView.Horizontal
            height : parent.height  * 0.1
            width : parent.width
            delegate : Button {
                width : height * 4
                height : lv.height
                onClicked : if(text !== "") loader.source = text + ".qml"
                text : m ? m.name : ""
                property var m: lv.model.get(index)
            }
            model : ListModel {
                ListElement { name : "Test_DataChanged" }
                ListElement { name : "Test_Empty" }
                ListElement { name : "Test_Main" }
                ListElement { name : "Test_ModelCeption" }
                ListElement { name : "Test_Section" }
            }

        }
        Loader {
            id : loader
            width : parent.width
            height : parent.height * 0.9
        }
    }





}
