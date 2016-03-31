import QtQuick 2.0
import Zabaat.Shaders 1.0 as Fx
import Zabaat.Material 1.0
Rectangle {
    color : Qt.lighter(Colors.info)

    ZSlider {
        id: slider
        width : parent.width
        height : parent.height * 0.1
        min : 0
        max : 4
        value : 1
        label : "Value"
    }

    Image {
        id : sample
        width  : height
        height : parent.height * 0.4
        anchors.left: parent.left
        anchors.leftMargin: width/2
        anchors.verticalCenter: parent.verticalCenter
        source : "frog.jpg"
    }

    Image {
        id : sourceRect
        width : height
        height : parent.height * 0.4
        anchors.centerIn: parent
        source : "frog.jpg"
    }

    Fx.Bloom {
        source : sourceRect
        value  : slider.value
    }

}
