import QtQuick 2.0
import Zabaat.Shaders 1.0 as Fx
import Zabaat.Material 1.0
Item {
//    color : Colors.info

    Column {
        width : parent.width
        height : parent.height * 0.3
        y : 10

        property int h : height / 2

        ZSlider {
            id: slider_blur
            width : parent.width
            height : parent.h
            min : 0
            max : 4
            value : 0
            label : "Blur"
        }

        ZSlider {
            id: slider_contrast
            width : parent.width
            height : parent.h
            min : 0
            max : 4
            value : 1
            label : "Contrast"
        }

    }



    Image {
        id : sample
        width  : height
        height : parent.height * 0.35
        anchors.left: parent.left
        anchors.leftMargin: width/2
        anchors.verticalCenter: parent.verticalCenter
        source : "frog.jpg"
    }


    Image {
        id : sourceRect
        width : height
        height : parent.height * 0.35
        anchors.centerIn: parent
        source : "frog.jpg"
    }

    Fx.PencilDrawing {
        source   : sourceRect
        blur     : slider_blur.value
        contrast : slider_contrast.value
    }

}
