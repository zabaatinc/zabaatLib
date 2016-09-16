import QtQuick 2.5
import Zabaat.Material 1.0
Rectangle {
    id : rootObject
    border.width: 1

    property string key
    property string val


    Row {
        anchors.fill        : parent
        anchors.margins     : 5
        spacing : 5
        property int w : width/3
        Text {
            id : keyText
            width  : paintedWidth
            height : parent.height
            horizontalAlignment : Text.AlignHCenter
            verticalAlignment   : Text.AlignVCenter
            text                : key
            font.pixelSize      : height * 1/3
        }
        OpSelector {
            id : opText
            width  : Math.max(parent.w , keyText.width)
            height : parent.height/2
            anchors.verticalCenter: parent.verticalCenter

//            horizontalAlignment : Text.AlignHCenter
//            verticalAlignment   : Text.AlignVCenter
//            text                : "=="
//            font.pixelSize      : height * 1/3
        }
        ZTextBox {
            text   : rootObject.val
            height : parent.height
            width  : parent.w
        }

        ZButton {
            onClicked : val += 'C'
            height : parent.height
            width  : parent.w
        }


    }


}
