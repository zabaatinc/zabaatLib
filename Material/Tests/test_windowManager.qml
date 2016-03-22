import QtQuick 2.5
import Zabaat.Material 1.0
import QtQuick.Controls 1.4
Item {

    Column {
        Text { text : "num Windows:" + WindowManager.count   }
        Text { text : "activeWindow:" + WindowManager.activeWindow   }
        Text {
            text : "json:" + WindowManager.json
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Button {
            onClicked : WindowManager.create()
            text : "new"
        }

        Button {
            onClicked : WindowManager.closeAll()
            text : "closeAll"
        }
    }



}
