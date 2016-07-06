import QtQuick 2.5
import Zabaat.Utility 1.0
import QtQuick.Controls 1.4
Item {
    id : rootObject

    property var source: Qt.resolvedUrl("SubView/image.jpg")

    ImageSubView {
        id : sv
        width : parent.width  * 3/4
        height : parent.height * 1/2
        anchors.centerIn: parent
        subRect: subPicker.subRect
        source : rootObject.source

        MouseArea {
            anchors.fill: parent
            onClicked : subPicker.visible = true
        }
        ZTracer { }

        property point dim : Qt.point(width,height)
        onDimChanged: console.log("DIM= ", dim)
    }


    ImageSubPicker{
        id : subPicker
        anchors.centerIn: parent
        width : parent.width * 0.75
        height : parent.height * 0.75
        visible : false


        source : rootObject.source
        ratio : sv.dim//sv.dim.x !== 0 && sv.dim.y !== 0 ? sv.dim : Qt.point(1,1)

        Button {
            text : 'done'
            onClicked : subPicker.visible = false;
        }
    }



}
