import QtQuick 2.0
import Zabaat.Shaders 1.0 as Fx
import Zabaat.Material 1.0
Rectangle {
    color : Qt.lighter(Colors.info)

    Column {
        width : parent.width /2
        height: parent.height * 0.3
        anchors.horizontalCenter: parent.horizontalCenter

        property int h : height/8

        ZSlider {
            id: slider_value
            width : parent.width
            height : parent.h
            min : 0
            max : 4
            value : 1
            label : "value"
        }
        ZSlider {
            id: slider_duration
            width : parent.width
            height : parent.h
            min    : 300
            max    : 10000
            value  : 2000
            isInt  : true
            label  : "duration"
        }
        ZSlider {
            id: slider_str
            width : parent.width
            height : parent.h
            min : 0
            max : 4
            value : 2.2
            label : "Strength"
        }
        ZSlider {
            id: slider_dist
            width : parent.width
            height : parent.h
            min : 0
            max : 4
            value : 1
            label : "Dist"
        }
        ZSlider {
            id: slider_loops
            width : parent.width
            height : parent.h
            min   : -1
            max   : 10
            value : -1
            isInt : true
            label : "loops"
        }
        ZSlider {
            id: slider_opacity
            width : parent.width
            height : parent.h
            min   : 0
            max   : 1
            value : 1
            label : "opacity"
        }
        ZSlider {
            id: slider_scale
            width : parent.width
            height : parent.h
            min   : 0
            max   : 2
            value : 1
            label : "scale"
        }
        Item {
            width : parent.width
            height : parent.h

            ZSwitch {
                id: hideSourceSwitch
                width : parent.width / 4
                height : parent.height
                isOn : true
            }

            ZSwitch {
                id: varyingDistSwitch
                width : parent.width / 4
                height : parent.height
                isOn : true
                anchors.right: parent.right
            }
        }
    }

    Item {

        width : parent.width
        height : parent.height * 0.7
        anchors.bottom: parent.bottom


        Image {
            id : sample
            width  : height
            height : parent.height * 2/3
            anchors.left: parent.left
            anchors.leftMargin: width /2
            anchors.verticalCenter: parent.verticalCenter
            source : "sword_hilt.png"

            Image {
                anchors.fill: parent
                source : "sword_blade.png"
                anchors.margins: -1
            }
        }

        Image {
            id : sourceHilt
            width  : height
            height : parent.height * 2/3
            anchors.centerIn: parent
            source : "sword_hilt.png"

            Image {
                id : sourceRect_Blade
                anchors.fill: parent
                source : "sword_blade.png"
                scale  : 1.2
            }

            Fx.Glow {
                source : sourceRect_Blade
                value  : slider_value.value
                loopDuration: slider_duration.value
                sampleStrength  : slider_str.value
                sampleDist      : slider_dist.value
                hideSource      : hideSourceSwitch.isOn
                loops : slider_loops.value === -1 ? Animation.Infinite : slider_loops.value
                opacity : slider_opacity.value
                scale : slider_scale.value
                varyingDist: varyingDistSwitch.isOn
            }
        }

        Image {
            id : sourceFrog
            width  : height
            height : parent.height * 2/3
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: width/2
            source : "frog.jpg"
        }



        Fx.Glow {
            source : sourceFrog
            value  : slider_value.value
            loopDuration: slider_duration.value
            sampleStrength  : slider_str.value
            sampleDist      : slider_dist.value
            hideSource      : hideSourceSwitch.isOn
            loops : slider_loops.value === -1 ? Animation.Infinite : slider_loops.value
            opacity : slider_opacity.value
            scale : slider_scale.value
            varyingDist: varyingDistSwitch.isOn
        }

    }



}
