import QtQuick 2.5
import Zabaat.Utility 1.1
import QtQuick.Controls 1.4

Item {

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
