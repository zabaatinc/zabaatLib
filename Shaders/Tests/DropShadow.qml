import QtQuick 2.0
import Zabaat.Shaders 1.0 as Fx
import Zabaat.Material 1.0
import Zabaat.Utility 1.0
import QtGraphicalEffects 1.0
Rectangle {
    id : rootObject
    color : Colors.names.yellowgreen

//    CheckeredGrid {
//        rows : 50
//        columns : 50
//        anchors.fill: parent
//    }


    Column {
        width : parent.width
        height : childrenRect.height
        spacing : 10
        ZSlider {
            id: sliderX
            width : parent.width
            height : rootObject.height * 0.1
            min : 1
            max : 15
            value : 15
            label : "X"
        }
        ZSlider {
            id: sliderY
            width : parent.width
            height : rootObject.height * 0.1
            min : 1
            max : 15
            value : 15
            label : "Y"
        }
        ZSlider {
            id: slider2
            width : parent.width
            height : rootObject.height * 0.1
            min : 0
            max : 1
            value : 0.2
            label : "Hardness"
        }
        ZSlider {
            id: slider3
            width : parent.width
            height : rootObject.height * 0.1
            min : 0
            max : 1
            value : 0.2
            label : "Depth"
        }
        Row {
            width : childrenRect.width
            height : rootObject.height * 0.1
            spacing : 20

            ZButton {
                text : 'Black'
                height : parent.height
                width : 200
                onClicked : shadowOfMordor.shadowColor = "black"
            }

            ZButton {
                text : 'Random'
                height : parent.height
                width : 200
                onClicked : shadowOfMordor.shadowColor = Qt.rgba(Math.random(),Math.random(),Math.random(), 1)
            }

        }
    }



        Fx.DropShadow {
            id : shadowOfMordor
            source  : sourceRect
            hardness: slider2.value
            depth   : slider3.value
            offset  : Qt.point(sliderX.value * 5,sliderY.value * 5);
        }
        Image {
           id : sourceRect
           width : height
           height : parent.height * 0.2
           anchors.centerIn: parent
           source : "mario.png"
        }



//    Rectangle {
//        id : sourceRect2
//        color : "red"
//        width : height
//        height : parent.height * 0.2
//        anchors.centerIn: parent
//        anchors.horizontalCenterOffset: -200
//        anchors.verticalCenterOffset: -4
//        border.width: 1
//    }

//    DropShadow {
//        source : sourceRect2
////        cached : true
//        radius : slider3.value
//        samples : 1 + radius * 2
//        anchors.fill: sourceRect2
//        horizontalOffset: 3 * slider.value
//        verticalOffset  : 3 * slider2.value
//    }

}
