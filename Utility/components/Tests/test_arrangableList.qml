import Zabaat.Utility 1.0
import QtQuick 2.5

Row {
    id : rootObject
    width : parent ? parent.width * 3/4 : 0
    height : parent ? parent.height * 3/4 : 0

    property ListModel sourceModel : ListModel{
        ListElement{ name : "A" }
        ListElement{ name : "B" }
        ListElement{ name : "C" }
        ListElement{ name : "D" }
        ListElement{ name : "E" }
    }


    ListView {
        id : lv
        width : parent.width/2
        height : parent.height
        property int cellHeight  : height  * 0.1
        model : rootObject.sourceModel
        delegate : Rectangle {
            id : defDelInstance
            width : lv.width
            height : lv.cellHeight
//            color : Qt.rgba(Math.random(),Math.random(),Math.random())
            border.width: 1
            property var m : lv.model && lv.model.count > index ? lv.model.get(index) : null
            Text {
                anchors.centerIn: parent
                font.pixelSize  : parent.height * 1/3
//                text            : defDelInstance.parent && defDelInstance.parent.parent ? defDelInstance.parent.parent._index : "derp"
                text : parent.m ? index + ":\t" +parent.m.name : ""
            }
        }
    }


    ArrangableList {
        id : al
        width : parent.width/2
        height : parent.height
        model : rootObject.sourceModel
//        queryTerm: ({"$and":[{name: { "$gt":"A" } }  , {name: { "$lt":"E" } } , {name: { "!=":"C" } }  ]  })
        queryTerm : ({"name":""})
    }




}
