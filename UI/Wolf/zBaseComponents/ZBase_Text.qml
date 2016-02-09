import QtQuick 2.4
import Zabaat.Misc.Global 1.0

Rectangle
{
    id : rootObject
    width  : 100
    height : 200

    signal clicked(var self)
    signal hovered(var self)
    signal unhovered(var self)
    property var self : this

    color : "white"
    property color fontColor      : "black"
    property color outlineColor   : ZGlobal.style.accent
    property int outlineThickness : 2
    property alias outlineLeft    : lineLeft
    property alias outlineRight   : lineRight
    property alias outlineTop     : lineTop
    property alias outlineBottom  : lineBottom
    property alias text : textObj.text
    property alias dText : textObj
    property bool  showOutlines   : false
    property alias horizontalAlignment : textObj.horizontalAlignment
    property alias verticalAlignment : textObj.verticalAlignment
    property alias fontSize : textObj.font.pointSize
    property alias hoverEnabled : ms.hoverEnabled

    property var uniqueProperties : ['fontColor','outlineColor','outlineThickness','text','shoutOutlines']
    property var uniqueSignals : ({})

    visible : height > 0

    Rectangle
    {  // left hook
        id            :lineLeft
        width         : outlineThickness
        height        : parent.height
        color         : outlineColor
        anchors.right : parent.left
        anchors.top   : parent.top
        visible       : showOutlines
    }

    Rectangle
    {  // right hook
        id            :lineRight
        width         : outlineThickness
        height        : parent.height
        color         : outlineColor
        anchors.left  : parent.right
        anchors.top   : parent.top
        visible       : showOutlines
    }

    Rectangle
    {  // top hook
        id             : lineTop
        width          : parent.width
        height         : outlineThickness/2
        color          : outlineColor
        anchors.left   : parent.left
        anchors.bottom : parent.top
        visible       : showOutlines
    }

    Rectangle
    {
        //bottom hook
        id             : lineBottom
        width          : parent.width
        height         : outlineThickness/2
        color          : outlineColor
        anchors.left   : parent.left
        anchors.top    : parent.bottom
        visible       : showOutlines
    }


    Text
    {
        id : textObj
        horizontalAlignment : Text.AlignHCenter
        verticalAlignment   :  Text.AlignVCenter
        width : parent.width
        height : parent.height
        scale : paintedWidth > width ? width / paintedWidth : 1
        font.family   : ZGlobal.style.text.normal.family
        font.pointSize: ZGlobal.style.text.normal.pointSize
        font.bold: ZGlobal.style.text.normal.bold
        font.italic: ZGlobal.style.text.normal.italic
        color : fontColor
        visible : parent.height > 0

        onTextChanged: {
            if(containsNonLatinCodepoints(text))
            font.family = 'FontAwesome'
        }

        function containsNonLatinCodepoints(s) {
            return /[^\u0000-\u00ff]/.test(s);
        }
    }


    QtObject
    {
        id : privates

    }


    MouseArea{
        id : ms
        anchors.fill: parent
        hoverEnabled: true
        onClicked: rootObject.clicked(rootObject)
        onEntered: hovered(rootObject)
        onExited: unhovered(rootObject)
    }
}
