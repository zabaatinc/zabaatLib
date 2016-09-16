import QtQuick 2.5
import Zabaat.Utility 1.0
import QtQuick.Controls 1.4
import Zabaat.Material 1.0
import Zabaat.HelperTools 1.0
Item {
    id : rootObject

//    QueryViewer {
//        id : qView
//        anchors.fill: parent
//        queryObj :  ({
//            status: "A",
//            $or   : [ { age: { $lt: 30 } }, { type: 1 } ]
//          })
//    }
    QueryBuilder {
        id : qb
        anchors.fill: parent
    }

}
