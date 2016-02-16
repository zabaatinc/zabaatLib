import Zabaat.Material 1.0
import QtQuick 2.5
Rectangle {
    signal requestTransition(string name);
    property alias model : lv.model
    color : Colors.colorhashFunc("defaultNavigation")

    ListView{
        id : lv
        anchors.fill: parent
        orientation : ListView.Horizontal
        delegate : ZButton {
            width: lv.height * 4
            height : lv.height
            state  : "ghost-f3"
            text : name
            onClicked: requestTransition(dest);
        }
    }

}

