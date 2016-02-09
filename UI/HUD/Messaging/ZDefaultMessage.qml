import QtQuick 2.0
import QtGraphicalEffects 1.0
import Zabaat.Misc.Global 1.0

Item
{
    id : rootObject
    width  : 200
    height : 32

    property alias bgkColor  : _rect.color
    property alias glowColor : _glow.color
    property alias textColor : _text.color
    property alias glow      : _glow.visible
    property alias text      : _text.text
    property bool  acknowledged : false
    visible : height > 0

    RectangularGlow
    {
        id : _glow
        anchors.fill: _rect
        glowRadius : 5
        spread : 0.2
        color : "black"
        cornerRadius: _rect.radius * glowRadius
    }

    Rectangle
    {
        id : _rect
        color : "white"
        anchors.fill: parent
        radius : 25

        Text
        {
            id : _text
            text : "message me here so harder. do it now pleaserrrrrrrrrrrrrrrrs"
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            scale : paintedWidth > width ? (width / paintedWidth) : 1
        }
    }

    MouseArea
    {
        anchors.fill: parent
        onClicked : acknowledged = true
    }
}


