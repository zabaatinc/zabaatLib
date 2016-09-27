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
            min : 100
            max : 20000
            value : 1000
            label : "Duration"
        }

        ZSlider {
            id: slider_amplitude
            width : parent.width
            height : parent.h
            min : 0
            max : 1
            value : 0.5
            label : "Amp"
        }
    }


    Item {
        id : content
        width : parent.width
        height : parent.height * 0.6
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        Rectangle {
            id : container
            width : parent.width
            height : parent.height/2
            color : 'lightblue'
            Image {
                id : frog
                width : parent.width
                height : parent.height
                source : "scenery.jpg"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Rectangle {
                id : movableRect
                width : height
                height : parent.height * .7
                color : 'red'
                border.width: 1
                MouseArea {
                    anchors.fill: parent
                    drag.target: movableRect
                }
            }

        }



        Fx.WaterReflection {
            source : container
            duration: slider_Str.value
            amplitude: slider_amplitude.value
//            frequency: slider_frequency.value
        }
    }



}
