import Zabaat.Shaders 1.0 as Fx
import Zabaat.Material 1.0
import QtQuick 2.5
Item {


    Column {
        width : parent.width /2
        height: parent.height * 0.3
        anchors.horizontalCenter: parent.horizontalCenter

        property int h : height/3

        ZSlider {
            id: slider_hue
            width : parent.width
            height : parent.h
            min : 0
            max : 1
            label : "hue"
        }

        ZSlider {
            id: slider_sat
            width : parent.width
            height : parent.h
            min : 0
            max : 1
            value : 1
            label : "sat"
        }

        ZSlider {
            id: slider_value
            width : parent.width
            height : parent.h
            min : 0
            max : 1
            value : 1
            label : "value"
        }

    }

    Rectangle {
        id : sourceRect
        color : "red"
        width : height
        height : parent.height * 0.2
        anchors.centerIn: parent
        border.width: 1
    }

    Fx.HSV{
        id : fx
        source : sourceRect
        h : slider_hue.value
        s : slider_sat.value
        v : slider_value.value
    }



}
