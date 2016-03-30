import QtQuick 2.0
import Zabaat.Shaders 1.0 as Fx
import Zabaat.Material 1.0
Item {
//    color : Colors.info

    ZSlider {
        id: slider
        width : parent.width
        height : parent.h
        min : 0
        max : 20
        value : 1
        label : "Contrast"
        y : height/2

    }

    Image {
        id : sample
        width  : height
        height : parent.height * 0.5
        anchors.left: parent.left
        anchors.leftMargin: width/2
        anchors.verticalCenter: parent.verticalCenter
        source : "frog.jpg"
    }


    Image {
        id : sourceRect
        width : height
        height : parent.height * 0.5
        anchors.centerIn: parent
        source : "frog.jpg"
    }

    Fx.Contrast {
        source : sourceRect
        value  : slider.value
    }

}
