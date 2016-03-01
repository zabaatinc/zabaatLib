import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Window 2.2
import Zabaat.Material 1.0
import Zabaat.Utility 1.0

Item {
    width : Screen.width
    height : Screen.height - 300

    property var testObject : [ { name : "Shahan", herp : "derp", skill:{name:"carry"} } ,
                                { name : "Brett" , herp : "derp", skill:{name:"tank"} },
                                { name : "Fox"   , herp : "derp", skill:{name:"ganker"} },
                                { name : "Zeke"  , herp : "derp", skill:{name:"initiator"} },

                              ]

    Component.onCompleted: {
        sourceModel.append(testObject)
    }

    Row {
        Button {
            text : "add"
            onClicked: logic.randomAdd()
        }
        Button {
            text : "delete"
            onClicked : logic.randomRemove()
        }
        Button {
            text : 'move'
            onClicked: logic.randomMove()
        }
    }



    QtObject {
        id : logic
        property ListModel sourceModel : ListModel { id : sourceModel; dynamicRoles: true; }
        property var queryTerm : ({name:""})

        function getRandIdx(){
            return Math.floor(Math.random() * sourceModel.count)
        }

        function randomAdd(){
            var idx = getRandIdx()
            var text = Math.floor(Math.random() * 10).toString()
            sourceModel.insert(idx,{ name : text, skill:{name:"rnd"}});
        }

        function randomRemove(){
//            sourceModel.remove(sourceModel.count - 1)
            sourceModel.remove(getRandIdx())
//            sourceModel.remove(2)
        }

        function randomMove(){
            sourceModel.move(0,1,3)
        }

        function formQueryObject(key,op,value){
//            console.log(key,op,value)
            if(key !== ""){
                var obj = {}
                if(op === ""){
                    obj[key] = value;
                }
                else{
                    obj[key] = {}
                    obj[key][op] = value;
                }

                logic.queryTerm = obj
                console.log(JSON.stringify(obj,null,2))
            }
            else
                logic.queryTerm = {}
        }
    }





    Item {
        id : gui
        anchors.fill: parent

        Row {
            id : searchContainer
            width : parent.width
            height : parent.height * 0.1

            ZTextBox{
                id : searchKey
                label : "Search Key"
                width : parent.width * 0.4
                height : parent.height
                onTextChanged : logic.formQueryObject(searchKey.text,searchOp.text,searchBox.text)
            }
            ZTextBox{
                id : searchOp
                label : "Search Key"
                width : parent.width * 0.2
                height : parent.height
                onTextChanged :  logic.formQueryObject(searchKey.text,searchOp.text,searchBox.text)
            }
            ZTextBox{
                id : searchBox
                label : "SearchTerm"
                width : parent.width * 0.4
                height : parent.height
                onTextChanged :  logic.formQueryObject(searchKey.text,searchOp.text,searchBox.text)
            }

        }


        Row {
            id : listContainer
            width : parent.width
            height: parent.height * 0.9
            anchors.bottom: parent.bottom

            ListView {
                id : unfilteredList
                width : parent.width/2
                height : parent.height
                model : sourceModel
                delegate : delegateCmp;
                header : headerCmp;
//                add    : Transition {NumberAnimation{ properties : "x,y"; duration : 333; from : -100; to : 0 } }
//                remove : Transition {NumberAnimation{ properties : "scale"; duration : 333; from : 1; to : 0 }  }
//                move   : Transition {NumberAnimation{ properties : "scale"; duration : 333; from : 0; to : 1 }  }
            }

            ListView {
                id : filteredList
                width : parent.width/2
                height : parent.height
                model : ZSubModel{
                    sourceModel: sourceModel
                    queryTerm  : logic.queryTerm
                }
                delegate : delegateCmp;
                header : headerCmp;
//                add    : Transition {NumberAnimation{ properties : "x,y"; duration : 333; from : -100; to : 0 } }
//                remove : Transition {NumberAnimation{ properties : "scale"; duration : 333; from : 1; to : 0 }  }
//                move   : Transition {NumberAnimation{ properties : "scale"; duration : 333; from : 0; to : 1 }  }
            }
        }

        Component {
            id : delegateCmp
            Rectangle {
                id : delItem
                width  : lvPtr ? lvPtr.width : 100
                height : lvPtr ? lvPtr.height * 0.1 : 100
                border.width: 1
                property var lvPtr : parent.parent ? parent.parent : null
                property var m : lvPtr && lvPtr.model ? lvPtr.model.get(index) : {error:"happens"}
                property int ind : m && !_.isUndefined(m.__relatedIndex) ? m.__relatedIndex : index
//                onMChanged: if(m) console.log(JSON.stringify(m,null,2))

                clip : true
                Flickable {
                    width : parent.width - parent.height
                    height : parent.height
                    contentWidth: text.paintedWidth
                    contentHeight: text.paintedHeight
                    Text {
                        id : text

    //                    horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: delItem.height * 1/6
                        text   : delItem.ind + ":" + JSON.stringify(Functions.object.modelObjectToJs(delItem.m),null,2)
    //                    Component.onCompleted: console.log(delItem.parent.parent)
                    }

                    Text {
                        id : textBig
                        width : delItem.width -  parent.parent.height
                        height : delItem.height
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: delItem.height * 1/3
                        text   : delItem.m ? delItem.ind + ":" + delItem.m.name : ""
    //                    Component.onCompleted: console.log(delItem.parent.parent)
                    }
                }
                ZButton{
                    width    : height
                    height   : parent.height
                    text     : "+"
                    onClicked: delItem.m.name += "s"
                    anchors.right: parent.right
                }


            }


        }
        Component {
            id : headerCmp
            Rectangle {
                id : delItem
                width  : lvPtr ? lvPtr.width : 100
                height : lvPtr ? lvPtr.height * 0.1 : 100
                border.width: 1
                property var lvPtr : parent.parent ? parent.parent : null
                Text {
                    id : text
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: delItem.height * 1/3
                    text   : delItem.lvPtr.count
//                    Component.onCompleted: console.log(delItem.parent.parent)
                }
            }
        }


    }





}
