import QtQuick 2.5
import QtQuick.Controls 1.4
import "../"
import Zabaat.Material 1.0
Item {
    id : rootObject

    property var a
    property var myArr : [{name:"shahan",hobbies:["a","b"]} ,
                          {name:"brett" ,hobbies:["b","c"]}
                         ]

    Component.onCompleted: {
        a = amFactory.createObject(rootObject);
        var f = function(){
            aText.text = a.length + "\n" + JSON.stringify(a.arr,null,2)
        }

        a.arrChanged.connect(f)
        a.updated.connect(f);
        a.created.connect(f);
        a.deleted.connect(f);



        a.arr = myArr;
    }

    Text {
        id: aText
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 5
    }




    Column {
        width : parent.width
        height : parent.height * 0.2
        Row  {
            width : parent.width
            height : parent.height /2
            ZTextBox {
                width : parent.width
                height : parent.height
                label : 'get(path)'
                onAccepted: {
                    var o = a.get(text)
                    return typeof o === 'object' ? console.log(JSON.stringify(o)) : console.log(o)
                }

                state : "cliplabel"
            }
        }
        Row  {
            width : parent.width
            height : parent.height /2
            ZTextBox {
                id : setPathText
                width : parent.width * 0.325
                height : parent.height
                label : 'path'
//                onAccepted: console.log(a.get(text))
                state : "cliplabel"
            }
            ZTextBox {
                width : parent.width * 0.325
                height : parent.height
                label : 'value'
                state : "cliplabel"
                onAccepted: {
                    a.set(setPathText.text, text);
                    console.log(JSON.stringify(a.arr))
                }
            }
            ZButton {
                width : parent.width * 0.25
                height : parent.height
                onClicked : {
                    a.set("2",{name : 'derp' })
                }
            }
        }
    }



    Component {
        id : amFactory
        ArrayModel {
            id : amDel
            onUpdated: {
                console.log("UPDATE @", path);
                console.log("OLD", JSON.stringify(oldValue))
                console.log("NEW", JSON.stringify(value))
                console.log("END UPDATE")
            }
            onCreated: {
                console.log("CREATE @", path);
                console.log("NEW", JSON.stringify(value))
                console.log("END CREATE")
            }


        }
    }




}
