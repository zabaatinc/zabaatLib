import QtQuick 2.0
import Zabaat.Shaders 1.0 as Fx
import Zabaat.Material 1.0
Rectangle {
    id : rootObject
    color : Qt.lighter(Colors.info)

    Column {
        width : parent.width
        height : childrenRect.height
        ZSlider {
            id: slider
            width : parent.width
            height : rootObject.height * 0.1
            min : 0
            max : 1
            value : 1
            label : "Value"
            state : "default";
            onValueChanged: am.maskStrength = value;
        }

        ZSlider {
            id: dividerSlider
            width : parent.width
            height : rootObject.height * 0.1
            min : 0
            max : 1
            value : 1
            label : "Value"
            state : "default";
            onValueChanged: am.dividerValue = value;
        }
    }



//    Image {
//        id : sample
//        width  : height
//        height : parent.height * 0.4
//        anchors.left: parent.left
//        anchors.leftMargin: width/2
//        anchors.verticalCenter: parent.verticalCenter
//        source : "frog.jpg"
//    }

    Image {
        id : sourceRect
        width : height
        height : parent.height * 0.4
        anchors.centerIn: parent
        source : "frog.jpg"
    }

    Fx.AlphaMask {
        id : am
        source : sourceRect
        mask   : Image {
            width : sourceRect.width
            height : sourceRect.height
            source : "mask.png"
        }
        opacity : 1

    }

}
