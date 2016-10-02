import QtQuick 2.5
import Zabaat.Utility 1.0
import Zabaat.Material 1.0
import Zabaat.Shaders 1.0 as Fx
Rectangle {
    id : rootObject
    objectName : "test.qml"
    color : 'lightyellow'
    Component.onCompleted: {
        forceActiveFocus();
    }

    Keys.onPressed: {
        if(event.key === Qt.Key_Plus){
            var r = rectFactory.createObject(rootObject)
            r.x = Math.random() * rootObject.width
            r.y = Math.random() * rootObject.height
        }
        else if(event.key == Qt.Key_Delete) {
            selector.deleteSelection();
        }
    }

    Selector {
        id : selector
        anchors.fill: parent
        z : Number.MAX_VALUE
    }



    Component {
        id : rectFactory
        Rectangle {
            id : rectInstance
            width : 64
            height : 64
            color : Colors.getRandomColor()
//            MouseArea {
//                anchors.fill: parent
//                acceptedButtons: Qt.RightButton
//                onClicked : parent.parent = compositor;
//            }
        }
    }



}
