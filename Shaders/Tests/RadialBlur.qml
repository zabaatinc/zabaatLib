import QtQuick 2.0
import Zabaat.Shaders 1.0 as Fx
import Zabaat.Material 1.0
Item {
//    color : Colors.info

    Column {
        width : parent.width /2
        height: parent.height * 0.3
        anchors.horizontalCenter: parent.horizontalCenter

        property int h : height/2

        ZSlider {
            id: slider_Str
            width : parent.width
            height : parent.h
            min : 0
            max : 20
            value : 2.2
            label : "Strength"
        }

        ZSlider {
            id: slider_Dist
            width : parent.width
            height : parent.h
            min : 0
            max : 20
            value : 1
            label : "Dist"
        }


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

    Fx.RadialBlur {
        source : sourceRect
        sampleStrength: slider_Str.value
        sampleDist: slider_Dist.value
    }

}
