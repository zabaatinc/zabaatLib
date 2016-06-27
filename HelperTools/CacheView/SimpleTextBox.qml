import QtQuick 2.5
TextInput{
    font.pixelSize: parent.height * 1/3
    onActiveFocusChanged: if(activeFocus)
                              selectAll()
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    property alias label : lbl.text
    activeFocusOnTab: true
    focus : true
    clip : true


    Rectangle {
        anchors.fill: parent
        color : 'transparent'
        border.width: 1
    }

    Text {
        id : lbl
        font : parent.font
        horizontalAlignment: parent.horizontalAlignment
        verticalAlignment: parent.verticalAlignment
        color : parent.color
        opacity: 0.5
        visible : parent.text.length === 0
        anchors.fill: parent
    }
}
