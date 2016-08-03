import QtQuick 2.5
import ".."
Item {
    id : rootObject
    property real d : Math.min(rootObject.width, rootObject.height) * 0.1

    ViewModel {
        id : vm
        Component.onDestruction: vmRect.destroy()
    }
    Rectangle {
        id : vmRect
        width : d * 2
        height : d * 2
        border.width: 1
        color : 'green'
        Text {
            anchors.fill: this.parent ? this.parent : null
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text : vm ? vm.__priv.parentCount : ""
            font.pixelSize: parent.height * 1/3
        }
    }


    Text {
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text : "Left click anywhere to create parent & initing the viewmodel object. Left click on parents" +
               "to destroy them. When parents reach 0 , the viewmodel should get destroyed. Number inside the" +
               "green box is the number of parents that reference the viewmodel";
        wrapMode: Text.WordWrap
    }



    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: {
            var r = rectFactory.createObject(rootObject)
            r.x = mouseX - r.width/2;
            r.y = mouseY - r.height/2;
            vm.addParent(r);
        }
    }

    Component {
        id : rectFactory
        Rectangle {
            id : rectDel

            width : d
            height : d
            Component.onCompleted: {
                color = Qt.rgba(Math.random(), Math.random(), Math.random())
            }

            MouseArea {
                anchors.fill: parent
                onClicked: rectDel.destroy()
                drag.target: parent
            }
        }
    }


}
