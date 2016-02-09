import QtQuick 2.4
import Zabaat.Misc.Global 1.0
import QtGraphicalEffects 1.0

Item
{
    id : rootObject
    width  : 200
    height : 32

    property alias bgkColor  : _rect.color
    property alias glowColor : _glow.color
    property alias textColor : _text.color
    property alias glow      : _glow.visible
    property string text      : "derp"
    property bool  acknowledged : false

    signal chatMsgClicked(var msgData)
    property var msgData : null
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
        color : "blue"
        anchors.fill: parent
        radius : 25

        Text
        {
            id : _text
            text : "Chat with " + rootObject.text
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            scale : paintedWidth > width ? (width / paintedWidth) : 1
            color : "white"
        }
     }

    MouseArea
    {
        anchors.fill: parent
        onClicked :  chatMsgClicked(msgData)
    }
}



