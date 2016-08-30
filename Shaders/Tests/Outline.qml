import QtQuick 2.0
import Zabaat.Shaders 1.0 as Fx
import Zabaat.Material 1.0
Rectangle {
    id : rootObject
    color : Qt.lighter(Colors.info)

    property real sliderH : height * 0.05;
    Column {
        width : parent.width
        height : childrenRect.height
        anchors.bottom: parent.bottom
        Row {
            width  : parent.width
            height : sliderH
            ZButton {
                width  : parent.width/4
                height : parent.height
                text   : 'L'
                state  : am.leftLine ? 'success' : 'warning'
                onClicked : am2.leftLine = am.leftLine = !am.leftLine
            }
            ZButton {
                width  : parent.width/4
                height : parent.height
                text   : 'R'
                state  : am.rightLine ? 'success' : 'warning'
                onClicked : am2.rightLine =am.rightLine = !am.rightLine
            }
            ZButton {
                width  : parent.width/4
                height : parent.height
                text   : 'T'
                state  : am.topLine ? 'success' : 'warning'
                onClicked : am2.topLine =am.topLine = !am.topLine
            }
            ZButton {
                width  : parent.width/4
                height : parent.height
                text   : 'B'
                state  : am.botLine ? 'success' : 'warning'
                onClicked : am2.botLine =am.botLine = !am.botLine
            }
        }
        ZSlider {
            id: thicknessSLider
            width : parent.width
            height : sliderH
            min : 0
            max : 20
            value : 1
            label : "thickness"
            state : "default";
            isInt: true
        }
        ZSlider {
            id: dividerSlider
            width : parent.width
            height : sliderH
            min : 0
            max : 1
            value : 1
            label : "Value"
            state : "default";
            onValueChanged: am.dividerValue = value;
        }


    }


    Row {
        anchors.centerIn: parent
        width : childrenRect.width
        height : parent.width/8
        spacing : rootObject.width/16

        Item {
            width : rootObject.width/8
            height : width
            Rectangle {
                id : sourceRect
                anchors.fill: parent
                radius : height/2
                color : 'yellow'
            }
            Fx.Outline {
                id : am
                source : sourceRect
                dividerValue: dividerSlider.value
                thickness: thicknessSLider.value
                color : 'orange'
                clip : false
            }
        }

        Item {
            width : rootObject.width/8
            height : width
            Image {
                id : sourceImg
                anchors.fill: parent
                fillMode : Image.PreserveAspectFit
                source : "mario.png"
            }
            Fx.Outline {
                id : am2
                source : sourceImg
                dividerValue: dividerSlider.value
                thickness: thicknessSLider.value
                color : 'orange'
                clip : false
            }
        }




    }




}
