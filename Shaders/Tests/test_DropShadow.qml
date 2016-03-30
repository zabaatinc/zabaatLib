import Zabaat.Shaders 1.0 as Fx
import Zabaat.Material 1.0
import QtQuick 2.5
Item {

    ZSlider {
        id: slider
        width : parent.width /2
        height: parent.height * 0.1
        min : 0
        max : 1
        onValueChanged: {
//            console.log("DERP")
            fx.value = {h : value, s : 0.5, v : 1 }
        }
    }

    Rectangle {
        id : yellowRect
        color : "yellow"
        width : height
        height : parent.height * 0.2
        anchors.right: sourceRect.right
        anchors.rightMargin: width/2
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        id : sourceRect
        color : "red"
        width : height
        height : parent.height * 0.2
        anchors.centerIn: parent
//        onVisibleChanged: if(!visible) console.log("NOW IM INVISIBLE")
//                          else         console.log("I AM NOW VISIBLE")
//        visible : false
    }

    Fx.HSV{
        id : fx
        anchors.fill: sourceRect
        source : sourceRect
//        opacity : 0.1
//        value:  { h :  slider.value
    }



}
