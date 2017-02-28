import QtQuick 2.5
//log objects have 4 things
//ts   : <js date>
//file : <string>
//line : <string>
//text : <string>
Item {
    id : rootObject
    property alias model     : lv.model
    property int   fontSize  : 14
    property real  titleSize : height * 0.05
    property color color     : "blue"
    ListView {
        id : lv
        anchors.fill: parent
        delegate:  Rectangle{
            id : del
            color : index % 2 === 0 ? 'white' : 'lightGray'
            width : lv.width
            height : childrenRect.height + 5
            property var m : model
            property string ts : model && model.ts ? Qt.formatDateTime(model.ts) : "";
            property string file : model && model.file ? model.file : ""
            property string line : model && model.line !== undefined ? model.line : ""
            property string text : model && model.text ? model.text : ""

            Item {
                id : titleArea
                width : parent.width - 10
                anchors.horizontalCenter: parent.horizontalCenter
                height : fileAndLine.paintedHeight
                Text {
                    id : fileAndLine
                    font.pointSize: fontSize
                    width : parent.width / 2
                    elide : Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    text  : index + " " +  del.file + "::" + del.line
                    Rectangle {
                        id : thruLine
                        width  : fileAndLine.paintedWidth
                        height : 2
                        color  : rootObject.color
                        anchors.top : parent.bottom
                    }
                }
                Text {
                    id : date
                    font.pointSize: fontSize
                    width : parent.width / 2
                    elide : Text.ElideRight
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    text : del.ts
                }


            }


            Item {
                id : messageArea
                width : parent.width - 10
                anchors.horizontalCenter: parent.horizontalCenter
                height : t.paintedHeight
                anchors.top : titleArea.bottom
                anchors.topMargin: 5

                Text {
                    id : t
                    font.pointSize: fontSize;
                    width : parent.width
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    text : del.text
                }
            }
        }



    }
}
