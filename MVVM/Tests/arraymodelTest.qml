import QtQuick 2.5
import QtQuick.Controls 1.4
import "../"
import Zabaat.Material 1.0
Item {
    id : rootObject

    property var a
    property var myArr : [{name:"shahan",hobbies:["programming","b"]} ,
                          {name:"brett" ,hobbies:["programming","c"]}
                         ]

    Component.onCompleted: {
        a = amFactory.createObject(rootObject);
        var f = function(){
            aText.text = a.length + "\n" + JSON.stringify(a.arr,null,2)
            bText.text = JSON.stringify(a.__priv.maps,null,2)
        }

        a.arrChanged.connect(f)
        a.updated.connect(f);
        a.created.connect(f);
        a.deleted.connect(f);
        a.mapsAdded.connect(f);
        a.mapsDeleted.connect(f);

        a.init(myArr, ['hobbies.0']);
//        a.arr = myArr;
    }

    Text {
        id: aText
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 5
    }

    Text {
        id: bText
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 5
    }




    Column {
        width : parent.width
        height : parent.height * 0.2
        ZTextBox {
            id : pathText
            width : parent.width
            height : parent.height /2
            label : 'get(path)'
            onAccepted: {
                var o = a.get(text)
                return typeof o === 'object' ? console.log(JSON.stringify(o)) : console.log(o)
            }

            state : "cliplabel"
        }
        Row  {
            width : parent.width
            height : parent.height /2
            ZTextBox {
                width : parent.width * 0.325
                height : parent.height
                label : 'value'
                state : "cliplabel"
                onAccepted: {
                    a.set(pathText.text, text);
                    console.log(JSON.stringify(a.arr))
                }
            }
            ZButton {
                width : parent.width * 0.25
                height : parent.height
                text : "Set to {name:'derp'}"
                onClicked : {
                    a.set(pathText.text ,{name : 'derp' })
                }
            }
        }
    }



    Component {
        id : amFactory
        ArrayModel {
            id : amDel
            onUpdated: {
//                console.log("UPDATE @", path);
//                console.log("OLD", JSON.stringify(oldValue))
//                console.log("NEW", JSON.stringify(value))
//                console.log("END UPDATE")
            }
            onCreated: {
//                console.log("CREATE @", path);
//                console.log("NEW", JSON.stringify(value))
//                console.log("END CREATE")
            }
            onMapsAdded  : console.log("mapEntryAdded @" ,mapName, group, index)
            onMapsDeleted: console.log("mapEntryDeleted @" ,mapName, group, index)
        }
    }




}
