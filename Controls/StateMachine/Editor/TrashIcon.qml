import QtQuick 2.4
import Zabaat.Material 1.0
Item {
    id : trashIcon
    property color color : "gray"
    SequentialAnimation on color {
        id      : colorAnim
        loops   : Animation.Infinite
        running : false
        property color color    : trashIcon.color
        property color endColor : Colors.getContrastingColor(color)
        property bool  restart  : false;

        ColorAnimation {
            from    : colorAnim.color
            to      : colorAnim.endColor
            duration: 333
        }
        ColorAnimation {
            from    : colorAnim.endColor
            to      : colorAnim.color
            duration: 333
        }
        onStopped: trashIcon.color = "gray"

    }


    Column {
        spacing : 5
        anchors.fill: parent
        Rectangle {
            width  : parent.width
            height : parent.height * 0.20 - parent.spacing/2
            color  : trashIcon.color
            border.width: 1
            radius : (parent.height * 0.8) * 0.05
        }
        Rectangle{
            width : parent.width
            height : parent.height * 0.80 - parent.spacing/2
            color  : trashIcon.color
            border.width: 1
            radius : height * 0.05

            Row {
                anchors.centerIn: parent
                height : h
                width  : w * 3 + spacing * 2

                property real w : parent.width * 0.03
                property real h : parent.height * 0.75
                spacing         : parent.width/4

                Rectangle {
                    width : parent.w
                    height : parent.h
                    color  : "black"
                }

                Rectangle {
                    width : parent.w
                    height : parent.h
                    color  : "black"
                }

                Rectangle {
                    width : parent.w
                    height : parent.h
                    color  : "black"
                }
            }

        }


    }




    DropArea {
        id : functionsTrasher
        objectName : "functionTrash"
        anchors.fill: parent
        property var root : trashIcon
        keys: ['function']
        onEntered:  {
//                console.log(drag.source.toString().toLowerCase())
            if(!colorAnim.running && drag.source.objectName.toLowerCase() === "stateboxfuncrect")
                colorAnim.start()
        }
        onExited : {
            if(root)
                colorAnim.stop()
        }



    }
    //trash icon
}

