import QtQuick 2.5
import Zabaat.Utility 1.1
import QtQuick.Controls 1.4

Item {


    property var master : ["Zero", "One","Two","Three","Four","Five"]
    Row {
        width : parent.width
        height : parent.height
        anchors.centerIn: parent

        ListView {
            id : orig
            width    : parent.width/2
            height   : parent.height
            delegate : Loader {
                width : orig.width
                height : arrangable.delegateCellHeight
                sourceComponent: arrangable.delegate
                onLoaded : item.model = Qt.binding(function() { return modelData })
            }
            model : master
        }
        ArrangableList {
            id     : arrangable
            width  : parent.width/2
            height : parent.height
            model  : master
            filterFunc: function(a) {
                return a.toLowerCase().indexOf('o')!== -1
            }
            readonly property var il : arrangable.indexList
            onIlChanged: {
                textUndos.doUpdate()
                textRedos.doUpdate()
            }
        }
    }

    Text {
        id : textUndos
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 10
        text : JSON.stringify(arrangable.undos(),null,2)

        function doUpdate() {
            var t = "Undos\n"
            _.each(arrangable.undos() , function(v,k) {
                t += JSON.stringify(v) + "\n"
            })

            text = t;
        }
    }

    Text {
        id : textRedos
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 10
        text : JSON.stringify(arrangable.redos())

        function doUpdate() {
            var t = "Redos\n"
            _.each(arrangable.redos() , function(v,k) {
                t += JSON.stringify(v) + "\n"
            })

            text = t;
        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        Button {
            anchors.bottom: parent.bottom
            text : "undo"
            onClicked : arrangable.undo()
        }

        Button {
            anchors.bottom: parent.bottom
            text : "redo"
            onClicked : arrangable.redo()
        }


        Button {
            anchors.bottom: parent.bottom
            text : "save"
            onClicked : {

            }
        }
    }







}
