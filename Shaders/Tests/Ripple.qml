import QtQuick 2.0
import Zabaat.Shaders 1.0 as Fx
import Zabaat.Material 1.0
Item {
//    color : Colors.info

    Column {
        width : parent.width /2
        height: parent.height * 0.3
        anchors.horizontalCenter: parent.horizontalCenter
        z : Number.MAX_VALUE

        property int h : height/2

//        ZSlider {
//            id: slider_Str
//            width : parent.width
//            height : parent.h
//            min : 100
//            max : 20000
//            value : 1000
//            label : "Duration"
//        }

        ZSlider {
            id: slider_frequency
            width : parent.width
            height : parent.h
            min : 0
            max : 50
            value : 2
            label : "Freq"
        }
    }
    Rectangle {
        id : frog
        width : parent.width
        height : parent.height
//        source : "scenery.jpg"
        color : 'purple'
        anchors.horizontalCenter: parent.horizontalCenter
        MouseArea {
            anchors.fill: parent
            onClicked: rippleEffect.center = Qt.vector2d(mouseX/frog.width ,mouseY / frog.height);
        }
    }



    Fx.Ripple {
        id : rippleEffect
        source : frog
        freq : slider_frequency.value
//        duration: slider_Str.value
//        amplitude: slider_amplitude.value
    }




}
