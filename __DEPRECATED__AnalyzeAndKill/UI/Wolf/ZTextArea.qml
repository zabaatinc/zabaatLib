import QtQuick 2.4
import QtQuick.Controls 1.3
import Zabaat.Misc.Global 1.0

TextArea {
    id: ta
    width   : 100
    height  : 62
    text    :  ""
    font: ZGlobal.style.text.normal

    property bool resetPositionOnFocusLost : true

    onFocusChanged: if(!focus && resetPositionOnFocusLost){
                        cursorPosition = 0
                    }

    wrapMode                 : Text.WrapAtWordBoundaryOrAnywhere
    inputMethodHints         : Qt.ImhMultiLine
    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
    verticalScrollBarPolicy  : Qt.ScrollBarAlwaysOff

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        hoverEnabled: true
        onClicked: {
            parent.forceActiveFocus()
            ta.cursorPosition = ta.positionAt(mouse.x, mouse.y)
        }
        onPressed: {
//            parent.forceActiveFocus()
            ta.moveCursorSelection(ta.positionAt(mouse.x, mouse.y))
        }
    }


    Rectangle {
        id: scrolly
        anchors.right: parent.right
        width        : parent.width * 0.02
        height       : formula < ta.height/10 ? ta.height/10 : formula

        property real formula: (ta.height * 150) / ta.contentHeight

        color: ZGlobal.style.danger
        border.width: 1
        radius: height / 2
        enabled: false //TODO DERP ta.contentHeight > ta.height
        visible: enabled
        onYChanged: {
            var x = 0
            var y = ta.contentHeight * (scrolly.y / scrollyMa.drag.maximumY)
            ta.cursorPosition = ta.positionAt(x,y)
        }

        MouseArea {
            id: scrollyMa
            anchors.fill: parent
            drag.target: parent
            drag.minimumY: 0
            drag.maximumY: ta.height - parent.height
        }
    }
}

