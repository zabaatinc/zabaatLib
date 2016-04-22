import "../"
import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

Window {
    visible: true
    width : Screen.width
    height : Screen.height - 300
    color : "lightBlue"

    ListModel {
        id : testModel
        ListElement { number : 1 }
        ListElement { number : 2 }
        ListElement { number : 3 }
        ListElement { number : 4 }
    }

    Text {
        text : "origCount:" +  al.count_Original + "\n" +
               "subOrigCount:" +  al.count_ZSubOrignal + "\n" +
               "subChangerCount:" +  al.count_ZSubChanger

    }


    ArrangableList {
        id : al
        width : parent.width/2
        height : parent.height/2
        anchors.centerIn: parent

        model : testModel
//        delegate   : Component {
//            ZText {
//                property int index;
//                property var model;
//                anchors.fill: parent
//                text        : model ? model.number : ""
//                state  : 'f3-t1'
//            }
//        }

    }



}
