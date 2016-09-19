import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import "Lodash"
import "QueryBuilderComponents"
import QtQuick.Window 2.0
import "../ControllerView"
//provides a nice gui to create query objects
//
Rectangle {
    id : rootObject
    height : mainGroup.height


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

        }
    }



    Window {
        width : Screen.width * 0.8
        height : Screen.height - 300
        visible : true
        x : -width
        y : 0

        Row {
            anchors.fill: parent
            Text {
                id : tx
                width : parent.width/3
                height : parent.height
                text : JSON.stringify(mainGroup.m,null,2)
                Connections {
                    target : mainGroup
                    onChanged  : tx.text = JSON.stringify(mainGroup.m,null,2)
                    onMChanged : tx.text = JSON.stringify(mainGroup.m,null,2)
                }
            }

            Text {
                id : tx3
                width : parent.width/3
                height : parent.height
                text : JSON.stringify(mainGroup.fromMongoObj(mainGroup.toMongoObj()) ,null ,2);
                Connections {
                    target : mainGroup
                    onChanged  : tx3.text = JSON.stringify(mainGroup.fromMongoObj(mainGroup.toMongoObj()) ,null ,2);
                    onMChanged : tx3.text = JSON.stringify(mainGroup.fromMongoObj(mainGroup.toMongoObj()) ,null ,2);
                }
            }

            Text {
                id : tx2
                width : parent.width/3
                height : parent.height
                text : JSON.stringify(mainGroup.mongoObj,null,2)
                Connections {
                    target : mainGroup
                    onChanged  : tx2.text = JSON.stringify(mainGroup.mongoObj,null,2)
                    onMChanged : tx2.text = JSON.stringify(mainGroup.mongoObj,null,2)
                }
            }
        }


    }









}
