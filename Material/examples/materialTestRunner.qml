import QtQuick 2.5
import QtQuick.Window 2.0
import Zabaat.Material 1.0
import Qt.labs.folderlistmodel 2.1
import QtQuick.Controls 1.4

Window {
    id : mainWindow
    width : Screen.width
    height : Screen.height - 300
    Component.onCompleted:{
        MaterialSettings.init(this)
    }

    ListView {
        id : lv
        width : parent.width * 0.15
        height : parent.height
        visible : MaterialSettings.loaded
        model : FolderListModel {
            folder : "tests"
            nameFilters : ["*.qml"]
        }
        header : Rectangle {
            width : lv.width
            height : lv.height * 0.05
            color : 'green'
            Text {
                anchors.fill: parent
                text   : "Tests"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: height * 1/3
                color :"white"
            }
        }

        delegate: Button{
            width : lv.width
            height  : lv.height * 0.05
            text    : lv.model.get(index,"fileName");
            onClicked : loader.source = "tests/"+ text
        }
    }



    Loader {
        id : loader
        anchors.right: parent.right
        width : parent.width - lv.width
        height : parent.height
        onLoaded : item.anchors.fill = loader
        Rectangle {
            anchors.fill: parent
            border.width: 2
            color : 'transparent'
        }
    }


}
