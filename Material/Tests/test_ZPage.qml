import QtQuick 2.0
import Zabaat.Material 1.0
ZPage {
    id : rootObject

    Rectangle {
        color : 'green'
        Component.onCompleted:  {
            rootObject.bindItem(this, 1920/4, (1080 - 300)/4, 1920/2, (1080 - 300) / 2)
        }
        border.width: 1
        Text {
            //ratio printer
            anchors.centerIn: parent
            text : (parent.width / parent.height).toFixed(2)
        }
    }

    Rectangle {
        Component.onCompleted: rootObject.bindItem(this, 300, 400, 200, 200)
        color : 'red'
        border.width: 1
        Text {
            //ratio printer
            anchors.centerIn: parent
            text : (parent.width / parent.height).toFixed(2)
        }
    }

    Rectangle {
        Component.onCompleted: rootObject.bindSizeRememberRatio(this, 320, 240)
        color : 'pink'
        border.width: 1
        Text {
            //ratio printer
            anchors.centerIn: parent
            text : (parent.width / parent.height).toFixed(2)
        }
    }



}
