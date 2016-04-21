import QtQuick 2.5
import QtQuick.Window 2.2
import Zabaat.Utility.ZSubModel 1.1
import QtQuick.Controls 1.4

Window {
    visible: true
    width : Screen.width
    height : Screen.height - 300

    ZSubModel {
        id : sub
    }

    ZSubModel {
        id : sub2
        sourceModel : ListModel {
            ListElement { name : "derp" }
        }
    }


    Row {
        Button {
            text : "empty"
            onClicked : console.log(JSON.stringify(sub.get(0)))
        }
        Button {
            text : "non empty"
            onClicked : console.log(JSON.stringify(sub2.get(0)))
        }
    }




}
