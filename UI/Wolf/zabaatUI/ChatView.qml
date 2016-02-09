// ChatView.qml
import QtQuick 2.3

ListView {
    id: root
    width: 100
    height: 62
    property string fontColor: "white"
    model: ListModel {}

    function append(prefix, message) {
        model.append({prefix: prefix, message: message})
    }

    delegate: Row {
        width: root.width
        height: 24
        property real cw: width/24
        Label {
            width: cw*1
            height: parent.height
            text: model.prefix
            color: fontColor
        }
        Label {
            width: cw*23
            height: parent.height
            text: model.message
            color: fontColor
        }
    }
}
