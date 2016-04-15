import QtQuick 2.5
import QtQuick.Window 2.2
import Wolf 1.0
import QtQuick.Controls 1.4

Window {
    visible: true
    width : Screen.width
    height : Screen.height - 300

    SimulatedData {
        id: simData
        onReadyChanged : if(ready) {
                             sub.sourceModel = simData.model
                         }
        url : Qt.resolvedUrl("datasmall.txt")
    }

    Button {
        onClicked : simData.model.append({derp: 1 })
        anchors.right: parent.right
        text : "CLICK ME"
        z : 999

    }

    ListView {
        id : lv
        anchors.centerIn: parent
        width : parent.width
        height : parent.height
        model : SubModel {
            id : sub
//            indexList : [1,2]
            onCountChanged         : console.log("sub.count=",count)
            Component.onCompleted  : console.log("sub.count=",count)
//            onRowsAboutToBeInserted: console.log("Rows about to be inserted")
        }
        delegate : Text {
            width         : lv.width
            height        : lv.height * 0.1
            text          : "i:" + index + "\tsoNumber:" + soNumber
            font.pixelSize: height * 1/3
        }
//        onCountChanged: console.log("lv.count",lv.count)
    }


}
