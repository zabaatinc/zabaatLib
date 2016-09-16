import QtQuick 2.5
import "../../ControllerView"   //for simplebutton
import QtQuick.Controls 1.4
import QtQuick.Window 2.0
import "../Lodash"
Rectangle {
    id : rootObject
    color : colors.info
    height : Math.max(gui.height , cellHeight * 3);
    property int minBtnWidth    : Screen.width * 0.025
    property int cellHeight     : Screen.height * 0.025
    property bool canBeDeleted  : false
    property var  availableVars
    border.width: 1

    property var m : ({
        items   : [],
        mode    : "AND",
        isGroup : true
    })

    QtObject {
        id : logic
        property int uid : 0
        function addGroup() {
            var group = {
                isGroup : true,
                mode    : "AND",
                items   : [] ,
            }
            group.uid = uid++;
            console.log(_.keys(group) , _.values(group));

            m.items.push(group);
            lv.refresh();
        }

        function addRule(){
            var rule = {
                isGroup : false,
                key : "",
                val : "",
                op : "",
                complete : false,
            }
            m.items.push(rule);
            lv.refresh();
        }

        function deleteGroup(){
            console.log(m.deleteFunc)
//            console.log(JSON.stringify(m,null,2))
            if(m.deleteFunc)
                m.deleteFunc();

            lv.refresh();
        }

        function investigate() {

        }
    }

    QtObject {
        id : guiWars
        property int depth     : 0
        property Colors colors : Colors { id : colors }
    }



    Item {
        id    : gui
        width : parent.width
        height: childrenRect.height


        Item {
            id     : topControls
            width  : parent.width
            height : cellHeight
            Row {
                id : controls_groupMode
                width : childrenRect.width
                height : parent.height
                anchors.left: parent.left
                SimpleButton {
                    id : controls_groupMode_AND
                    width : minBtnWidth
                    height : parent.height
                    text : "AND"
                    onClicked : {
                        m.mode = text
                        controls_groupMode_AND.colorFunc();
                        controls_groupMode_OR.colorFunc();
                    }
                    color     : colorFunc();
                    function colorFunc(){
                         return color = m.mode === text ? colors.warning : colors.standard
                    }
                }
                SimpleButton {
                    id : controls_groupMode_OR
                    width : minBtnWidth
                    height : parent.height
                    text : "OR"
                    onClicked : {
                        m.mode = text
                        controls_groupMode_AND.colorFunc();
                        controls_groupMode_OR.colorFunc();
                    }
                    color     : colorFunc();
                    function colorFunc(){
                         return color = m.mode === text ? colors.warning : colors.standard
                    }
                }
            }
            Row {
                id : controls_add
                width : childrenRect.width
                height : parent.height
                anchors.right: parent.right
                SimpleButton {
                    width : minBtnWidth * 2
                    height : parent.height
                    text      : "+ Add rule"
                    color     : colors.success
                    textColor : 'white'
                    onClicked : logic.addRule()
                }
                SimpleButton {
                    width : minBtnWidth * 2
                    height : parent.height
                    text      : "+ Add group"
                    color     : colors.success
                    textColor : 'white'
                    onClicked : logic.addGroup()
                }
                SimpleButton {
                    width : visible? minBtnWidth  *2 : 0
                    height : parent.height
                    text      : "x Delete"
                    color     : colors.danger
                    textColor : 'white'
                    visible : canBeDeleted
                    onClicked : logic.deleteGroup()
                }


            }
        }

        ListView {
            id : lv
            width : parent.width
            height : lv.contentItem.childrenRect.height
            model : m ? m.items : null
            anchors.top : topControls.bottom
            anchors.topMargin: cellHeight * 1/2

            function refresh() {
                model = null
                model = Qt.binding(function() { return m ? m.items : null })
            }

            delegate: Item {
                id : del
                width          : lv.width
                height         : delLoader.height
                property var m : rootObject.m.items[index]
                Loader {
                    id : delLoader
                    anchors.right: parent.right
                    width : parent.width * 0.98
                    height : delLoader.item ? delLoader.item.height : cellHeight
                    source : parent.m.isGroup ? "QueryGroup.qml" : "QueryRule.qml"
                    onLoaded : {
                        item.anchors.fill  = null;
                        item.anchors.right = delLoader.right
                        item.width         = Qt.binding(function() { return delLoader.width  })

                        if(item.hasOwnProperty('canBeDeleted'))
                            item.canBeDeleted  = true;

                        var group = lv.model[index]
                        console.log(_.keys(group) , _.values(group));
                        item.m             = lv.model[index]
                        item.color         = Qt.lighter(rootObject.color)
                    }
                }
                z : index === lv.currentIndex ? Number.MAX_VALUE : 0
            }

            Text {
                anchors.right: parent.right
                text : parent.height + "," + lv.count
                anchors.rightMargin: 20
            }
        }

    }




}
