import QtQuick 2.5
import Zabaat.Utility 1.0
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
        ArrangableListArray {
            id     : arrangable
            width  : parent.width/2
            height : parent.height
            model  : master
            filterFunc: function(a) {
                return a.toLowerCase().indexOf('o')!== -1
            }
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
