import QtQuick 2.0
import Zabaat.Auth 1.0
Item {

    Image {
        id : img
        width : parent.width / 4
        height : width
    }

    Google {
        id : go
        width : parent.width/2
        height : parent.height
        anchors.right: parent.right


    }

}
