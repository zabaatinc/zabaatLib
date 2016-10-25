import QtQuick 2.5
import QtQuick.Controls 1.4
import Zabaat.Base 1.0
import "QueryBuilderComponents"
//import QtQuick.Window 2.0
//provides a nice gui to create query objects
//
Rectangle {
    id : rootObject
    height : mainGroup.height

    //expose the vars inside mainGroup
    property alias color1            : mainGroup.color1
    property alias color2            : mainGroup.color2
    property alias minBtnWidth       : mainGroup.minBtnWidth
    property alias availableVars     : mainGroup.availableVars
    readonly property alias mongoObj : mainGroup.mongoObj
    property alias m                 : mainGroup.m
    property var   colorsObj         : colors;

    function fromMongoQuery(m) { return mainGroup.fromMongoObj(m) }
    function toMongoQuery(m)   { return mainGroup.toMongoObj(m);  }
    function addRule(m,args) {
        return mainGroup.logic.addRule(m,args);
    }
    function addGroup(m,args) {
        return mainGroup.logic.addGroup(m,args);
    }
    function blankGroup() {
        return mainGroup.blankM();
    }
    function refreshView() {
        mainGroup.lv.refresh();
    }

    signal changed(var obj);


    ScrollView {
        id : sv
        anchors.fill: parent
        horizontalScrollBarPolicy : Qt.ScrollBarAlwaysOff
        style : ScrollStyle { color : colors.info }
        property Colors colors : Colors { id: colors }

        QueryGroup {
            id : mainGroup
            width : sv.viewport.width
            canBeDeleted : false
            availableVars : ["","Status","Name","Family","Tier"]
            onChanged: rootObject.changed(mainGroup.m);
            colorsObj : rootObject.colorsObj
        }
    }


//was used for debugging purposes
//    Window {
//        width : Screen.width * 0.8
//        height : Screen.height - 300
//        visible : true
//        x : -width
//        y : 0

//        Row {
//            anchors.fill: parent
//            Text {
//                id : tx
//                width : parent.width/3
//                height : parent.height
//                text : JSON.stringify(mainGroup.m,null,2)
//                Connections {
//                    target : mainGroup
//                    onChanged  : tx.text = JSON.stringify(mainGroup.m,null,2)
//                    onMChanged : tx.text = JSON.stringify(mainGroup.m,null,2)
//                }
//            }

//            Text {
//                id : tx3
//                width : parent.width/3
//                height : parent.height
//                text : JSON.stringify(mainGroup.fromMongoObj(mainGroup.toMongoObj()) ,null ,2);
//                Connections {
//                    target : mainGroup
//                    onChanged  : tx3.text = JSON.stringify(mainGroup.fromMongoObj(mainGroup.toMongoObj()) ,null ,2);
//                    onMChanged : tx3.text = JSON.stringify(mainGroup.fromMongoObj(mainGroup.toMongoObj()) ,null ,2);
//                }
//            }

//            Text {
//                id : tx2
//                width : parent.width/3
//                height : parent.height
//                text : JSON.stringify(mainGroup.mongoObj,null,2)
//                Connections {
//                    target : mainGroup
//                    onChanged  : tx2.text = JSON.stringify(mainGroup.mongoObj,null,2)
//                    onMChanged : tx2.text = JSON.stringify(mainGroup.mongoObj,null,2)
//                }
//            }
//        }

//        Button {
//            text : "test weirtd"
//            onClicked : {
//                console.log("HERPO")
//                var qObj = { "a" : "b", "c" : "d", "$and" : [{"e": "f" }, {"g":"h"}] }
//                var l = mainGroup.fromMongoObj(qObj);
//                mainGroup.m = l;
//                console.log(JSON.stringify(l,null,2))
//            }
//        }
//    }









}
