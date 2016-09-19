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

    property var mongoObj : toMongoObj();
    onChanged: mongoObj = toMongoObj();


    function fromMongoObj(obj) {
        //create our list readable format from a mongoQuery
        if(!obj || typeof obj !== 'object')
            return null;




        function processLine(obj) {

            function procOp(op){
                switch(op) {
                    case "$eq" : return "=="      ;
                    case "$ne" : return "!="      ;
                    case "$gt" : return ">"       ;
                    case "$gte": return ">="      ;
                    case "$lt" : return "<"       ;
                    case "$lte": return "<="      ;
                    case "$in" : return "contains";
                    case "$nin": return "notin"   ;
                }
            }


            //THIS ASSUMES THAT WE ARE NOT DUMB ENOUGH TO PUT
            //"$and" and "$or" in the same object! DOE. COULD THAT HAPPEN?
            var andItems = obj["$and"];
            var orItems  = obj["$or"];
            if(andItems || orItems) { //is grp
                var groupKey = andItems ? "AND" : "OR"
                var group = {
                    items  : [],
                    mode   : groupKey,
                    isGroup: true
                }

                var items = andItems || orItems;
                _.each(items, function(v) {
                     group.items.push(processLine(v));
                })
                return group;
            }
            else {  //is an comparasion expression/rule , woot
                var varname = _.keys(obj)[0];
                var val     = obj[varname];
                var op      = typeof val !== "object" ? "==" : procOp(_.keys(val)[0]);
                val         = typeof val !== "object" ? val  : val[_.keys(val)[0]];
//                var op      = typeof obj[varname] !== "object" ? "==" :
                var rule    = { key : varname, op : op, val : val };
                return rule;
            }
        }


        //this means we got a mongoObj we did not generate,
        //since we start with $and and $or. Always! We can convert this to an and!
        var group = {
            items  : [],
            mode   : "AND",
            isGroup: true
        }

        var extraKeys = _.keys(obj).filter(function(v) { return ["$or","$and"].indexOf(v) === -1; });
        if(extraKeys > 0) {
            _.each(obj, function(v) {
                group.items.push(processLine(v));
            })
        }
        else {
            _.each(obj, function(v) {
                group.items.push(processLine(v));
            })
        }

        return group;
    }


    //run through m and turn into a mongo query
    function toMongoObj() {
        function processItems(items, acc) {
            acc = acc || [];

            _.each(items, function(v,k) {

                if(!_.isUndefined(v.op)) {  //we now know that this is a rule
                    console.log("INFERED", JSON.stringify(v), "AS A RULE")
                    if(v.key !== "") {
                        var mongoRule = evalExpression(v.key,v.op,v.val);
                        acc.push(mongoRule);
                    }
                }
                else {  //we know that is a group so we need to recurse
                    console.log("INFERED", JSON.stringify(v), "AS A GROUP")
                    acc.push(processGroup(v));
                }
            })

            return acc;
        }
        function processGroup(grp) {
            var q = {}
            var k =  grp.mode === "AND" ? "$and" : "$or";
            q[k] = processItems(grp.items, []);
            return q;
        }
        function evalExpression(key,op,v) {
            var o  = {};
            switch(op) {
                case "==": o[key] = v;             return o;
                case "!=": o[key] = { "$ne" : v }; return o;
                case ">" : o[key] = { "$gt" : v }; return o;
                case ">=": o[key] = { "$gte": v} ; return o;
                case "<" : o[key] = { "$lt" : v} ; return o;
                case "<=": o[key] = { "$lte": v} ; return o;
                case "contains": o[key] = { "$in" : v};  return o;
                case "notin"   : o[key] = { "$nin": v};  return o;
            }
        }

        return processGroup(m);
    }



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
