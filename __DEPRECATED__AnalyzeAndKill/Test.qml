import QtQuick 2.5
import Zabaat.Utility 1.0
import QtQuick.Controls 1.4
import Zabaat.Material 1.0
Item {
    id : rootObject

    property real w : width / 4


    Row {
        width  : childrenRect.width
        height : parent.height * 0.1
        anchors.centerIn: parent

        ZTextBox {
            width : rootObject.w
            height: parent.height
            state : "tleft-cliplabel"
            label : 'left'
        }
        ZTextBox {
            width : rootObject.w
            height: parent.height
            label : 'center'
            state : "cliplabel"
        }
        ZTextBox {
            width : rootObject.w
            height: parent.height
            label : 'right'
            state : 'tright-cliplabel'
        }
    }








}
