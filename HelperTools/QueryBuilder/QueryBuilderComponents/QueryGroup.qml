import QtQuick 2.5
import "../../ControllerView"   //for simplebutton
import QtQuick.Controls 1.4
import QtQuick.Window 2.0
import "../Lodash"
Rectangle {
    id : rootObject
    color : color1

    property color color1 : colors.standard
    property color color2 : Qt.darker(colors.standard,1.2)

    height : Math.max(gui.height + cellHeight, cellHeight * 3);
    property int minBtnWidth    : Screen.width * 0.025
    property int cellHeight     : Screen.height * 0.025
    property bool canBeDeleted  : false
    property var  availableVars
    border.width: 1
    signal deleteMe();
    signal changed();

    property var m : ({
        items   : [],
        mode    : "AND",
        isGroup : true,
    })



    QtObject {
        id : logic
        function colorToHex(color){
            //http://stackoverflow.com/questions/5623838/rgb-to-hex-and-hex-to-rgb
            function componentToHex(c) {
                var hex = c.toString(16);
                return hex.length == 1 ? "0" + hex : hex;
            }
            var r = Math.floor(color.r * 255);
            var g = Math.floor(color.g * 255);
            var b = Math.floor(color.b * 255);

            return "#" + componentToHex(r) + componentToHex(g) + componentToHex(b);
        }

        function addGroup() {
            var group = {
                isGroup : true,
                mode    : "AND",
                items   : [] ,
            }
            group.color = m.items.length % 2 === 0 ? colorToHex(color1) : colorToHex(color2);
//            console.log(_.keys(group) , _.values(group));

            m.items.push(group);


            changed();
            listLoader.refresh();
        }

        function addRule(){
            var rule = {
                key : "",
                val : "",
                op : "",
                color   : colorToHex(colors.info)
            }
            m.items.push(rule);
            changed();
            listLoader.refresh();
        }

        function deleteItem(idx){
            if(m && m.items && m.items.length > idx) {
                m.items.splice(idx,1);
            }
            changed();
            listLoader.refresh();
        }

        function toMongoQuery(lines){
            lines = lines || (m ? m.items : undefined)
            if(!lines)
                return {}

            _.each(lines,function(v,k){
                if(v.isGroup) {

                }
                else {  //is expr

                }
            })
        }

        function fromMongoQuery(obj){

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
                        if(m.mode != text) {
                            m.mode = text
                            controls_groupMode_AND.colorFunc();
                            controls_groupMode_OR.colorFunc();
                            changed();
                        }
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
                        if(m.mode != text) {
                            m.mode = text
                            controls_groupMode_AND.colorFunc();
                            controls_groupMode_OR.colorFunc();
                            changed();
                        }
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
                    onClicked : deleteMe();
                }


            }
        }
        Loader {
            id : listLoader
            width : parent.width
            height: item ? item.height  : cellHeight
            anchors.top : topControls.bottom
            anchors.topMargin: cellHeight * 1/2

            function refresh(){
                sourceComponent = null;
                sourceComponent =listCmp
            }

            sourceComponent : listCmp
            Component{
                id : listCmp
                ListView {
                    id : lv
                    width : rootObject.width
                    height : lv.contentItem.childrenRect.height
                    spacing : 5
                    model : m ? m.items : null
                    function refresh() {
                        model = null
                        model = m.items

                        if(!canBeDeleted)
                            console.log(JSON.stringify(m,null,2))
                    }

                    delegate: Item {
                        id : del
                        width          : lv.width
                        height         : delLoader.height
                        property var m : rootObject.m.items[index]
                        property int _index : index
                        Loader {
                            id : delLoader
                            anchors.right: parent.right
                            anchors.rightMargin: parent.width * 0.005
                            width : parent.width * 0.97
                            height : delLoader.item ? delLoader.item.height : cellHeight
                            source : parent.m.isGroup ? "QueryGroup.qml" : "QueryRule.qml"
                            onLoaded : {
                                item.anchors.fill  = null;
                                item.anchors.right = delLoader.right
                                item.width         = Qt.binding(function() { return delLoader.width  })

                                if(item.hasOwnProperty("cellHeight"))
                                    item.cellHeight    = cellHeight
//                                if(!item.isGroup) {
//                                    item.height = Qt.binding(function() { return cellHeight })
//                                }


                                item.availableVars = Qt.binding(function() { return rootObject.availableVars })
                                if(typeof item.deleteMe === 'function') {
                                    item.deleteMe.connect(function() { logic.deleteItem(index); })
                                    if(item.hasOwnProperty('canBeDeleted'))
                                        item.canBeDeleted  = true;
                                }
                                if(typeof item.changed === 'function') {
                                    item.changed.connect(rootObject.changed);
                                }

                                item.m             = Qt.binding(function() { return del.m })
                                item.color         = del.m && del.m.color ? del.m.color : rootObject.color
                            }
                        }
                        z : index === lv.currentIndex ? Number.MAX_VALUE : 0
                    }


                }

            }
        }
    }




}
