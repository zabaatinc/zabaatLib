import QtQuick 2.5
import Zabaat.Utility.SubModel 1.1
import QtQuick.Controls 1.4

Item {
    Test_Main_SimulatedData {
        id: simData
        url : Qt.resolvedUrl("data.txt")
    }

    ListView {
        Text { text : flv.count ; anchors.right: parent.right ; z : 999 }
        id : flv
        width  : parent.width/2
        height : parent.height/2
        anchors.centerIn: parent
        clip : true
        model : ZSubModel {
            id : sub
            sourceModel : simData.model
        }
        delegate : Text {
            width         : flv.width
            height        : flv.height * 0.1
            property var m : sub.get(index)
            text          : m ? m.sort + " " + m.state  : ""
            font.pixelSize: height * 1/3
        }
        Rectangle {
            anchors.fill: parent
            color : 'transparent'
            border.width: 1
        }
    }



    Column {
        id : menu
        height : parent.height
        width : parent.width * 0.05
        function randIdx(){
            return Math.floor(Math.random() * simData.model.count)
        }
        Button {
            width : parent.width
            height : width
            text : 'Attach filter'
            onClicked : sub.filterFunc = sub.filterFunc ? null :  function(a) { return a.state === "pickQueue" }
        }
        Button {
            width : parent.width
            height : width
            text : 'Attach sort'
            onClicked : sub.sortFunc = sub.sortFunc ? null :  function(a, b) { return a.sort - b.sort }
        }
    }









}
