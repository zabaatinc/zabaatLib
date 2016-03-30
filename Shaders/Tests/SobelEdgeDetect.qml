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
        max : 1
        label : "MixLevel"
    }

    Image {
        id : sourceRect
        width : height
        height : parent.height * 0.5
        anchors.centerIn: parent
        source : "frog.jpg"
    }

    Fx.SobelEdgeDetect {
        source : sourceRect
        mixLevel  : slider.value
    }

}
