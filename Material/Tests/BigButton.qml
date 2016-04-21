import QtQuick 2.0
import Zabaat.Material 1.0
Item {

    property int count : 0
    ZButton {
        text : FA.heartbeat  + " " + count
        width : parent.width/2
        height : parent.height/2
        anchors.centerIn: parent
        state : "warning-f1"
        onClicked : ++count
    }





}
