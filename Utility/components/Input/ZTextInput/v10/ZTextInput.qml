import QtQuick 2.7
import Zabaat.Base 1.0
import QtQuick.Controls 1.4
Rectangle {
    id : rootObject
    border.width: 1
    property alias text      : te.text
    property alias textColor : te.color
    property alias minHeight : rootObject.implicitHeight
    property real  maxHeight : 0
    property alias font      : te.font
    height                   : flickable.height
//    implicitHeight           : te.cursorRectangle.height + 5
    property color cursorColor  : 'blue'
    property alias infoText     : lbl.text
    property alias infoColor    : lbl.color
    property point inputMargins : Qt.point(10,10);

    Flickable {
        id : flickable
        property alias ch : te.contentHeight
        width             : parent.width
        height            : Math.min(maxHeight, Math.max(ch + 5 , minHeight));
        contentWidth      : parent.width
        contentHeight     : maxHeight < ch ? ch + 5 : height;
        clip: true

        Item {
            id : container
            width  : flickable.width - (inputMargins.x * 2)
            height : Math.max(te.paintedHeight,minHeight) - (inputMargins.y * 2)
            anchors.centerIn: parent

            Text {
                id : lbl
                anchors.fill: parent
                wrapMode : Text.WordWrap
                verticalAlignment : Text.AlignVCenter
                font : te.font
                visible : te.text.length === 0
            }
            TextEdit {
                id : te
                anchors.fill: parent
                wrapMode : Text.WordWrap
                verticalAlignment : Text.AlignVCenter
                cursorDelegate: Component { Rectangle {
                        id : cursorDel
                        width : 2
                        color : cursorColor
                        radius : 5
                        Timer {
                            interval : 500
                            running : true
                            repeat : true
                            onTriggered: cursorDel.visible = !cursorDel.visible
                        }
                    }
                }

                onCursorRectangleChanged:  {
                    if(maxHeight > te.contentHeight)
                        return flickable.contentY = 0;

                    //figure out if adjustment is needed.
                    //to figure that out, we must first know whether the cursor
                    //is in view
                    var top = flickable.contentY;
                    var bot = top + maxHeight;

                    var cur = te.cursorRectangle;

                    //if the cursor is within top and bot, its alright, no need to do anything.
                    var isAboveTheView = cur.y <= top;
                    var isBelowTheView = (cur.y + cur.height) >= bot;

                    if(!isAboveTheView && !isBelowTheView) {
                        return;
                    }

                    //if is above
                    if(isAboveTheView) {
                        return flickable.contentY = cur.y;
                    }
                    else { //is below
                        return flickable.contentY = cur.y - maxHeight + cur.height + inputMargins.y*2;
                    }
                }
            }

        }



    }


}
