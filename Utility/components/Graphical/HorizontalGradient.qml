import QtQuick 2.5
Rectangle {
    width  : parent.height
    height : parent.width
    anchors.centerIn: parent
    rotation : 90

    property color color1 : 'red'
    property color color2 : 'blue'
    gradient : Gradient{
        GradientStop { position: 1.0; color: color1 }
        GradientStop { position: 0.0; color: color2 }
    }
}
