import QtQuick 2.0
import Zabaat.Shaders 1.0 as Fx
import Zabaat.Material 1.0
Item {
//    color : Colors.info

    ZSlider {
        id: slider
        width : parent.width
        height : parent.height * 0.1
        min : 0
        max : 4
        label : "Blur"
    }

    Rectangle {
        id : sourceRect
        color : "red"
        width : height
        height : parent.height * 0.2
        anchors.centerIn: parent
        border.width: 1
    }

    Fx.Blur {
        source : sourceRect
        value  : slider.value
    }

}
