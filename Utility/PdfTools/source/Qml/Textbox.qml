import QtQuick 2.0

Column
{
    id : rootObject
    property alias input   : tinput
    property alias text    : tinput.text
    property alias caption : caption.text
    property alias inputLimits : tinput.inputMethodHints
    signal textersChanged(string text);

    width  : 100
    height : 32


    Rectangle
    {
        width  : parent.width
        height : parent.height * 1/3
        color  : "gray"
        border.width: 1
        border.color: "black"

        Text
        {
            id : caption
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle
    {
        width  : parent.width
        height : parent.height * 2/3
        border.width: 1
        border.color: "black"

        TextInput
        {
            id : tinput
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            focus : true

            onTextChanged: rootObject.textersChanged(text)
        }
    }
}


