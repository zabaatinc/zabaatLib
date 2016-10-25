import QtQuick 2.5
import "../../ControllerView"   //for simplebutton
import QtQuick.Controls 1.4
import QtQuick.Window 2.0
import Zabaat.Base 1.0
Rectangle {
    id : rootObject
    color : color1

    property color color1     : colorsObj ? colorsObj.standard : "#ffffff";
    property color color2     : Qt.darker(color1,1.2);
    property color ruleColor  : colorsObj ? colorsObj.info     : "#ff00ff";
    property color deleteColor: colorsObj ? colorsObj.danger   : "#dd0000";
    property color addColor   : colorsObj ? colorsObj.success  : "#00dd55";
    property alias logic : logic;
    property alias lv    : lv;

    property var   colorsObj;

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
        color   : logic.colorToHex(colorsObj ? colorsObj.standard : "#ffffff")
    })
    property var mongoObj : toMongoObj();
    onChanged: {
        mongoObj = toMongoObj();
    }


    function blankM() {
        return {
            items   : [],
            mode    : "AND",
            isGroup : true,
            color   : logic.colorToHex(colorsObj ? colorsObj.standard : "#ffffff")
        }
    }

    function fromMongoObj(obj) {
        //create our list readable format from a mongoQuery
        if(!obj || typeof obj !== 'object')
            return null;

        //processes lines and figures out if it it is a rule or a group
        //and returns it accordingly.
        //grp is an optional param but if provided, we will add the line
        //to it. This will preserve our color coding of %2
        function processLine(line, grp) {
            grp = grp || {};

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
            var andItems = line["$and"];
            var orItems  = line["$or"];
            if(andItems || orItems) { //is grp
                var groupKey = andItems ? "AND" : "OR"
                var group    = logic.addGroup(grp, {mode : groupKey });

                var items = andItems || orItems;
                Lodash.each(items, function(v) {
                    processLine(v,group);   //process line is already gonna add the item in group!
                })
                return group;
            }
            else {  //is an comparasion expression/rule , woot
                var varname = Lodash.keys(line)[0];
                var val     = line[varname];

                //get the first key in val by Lodash.keys(val)[0] . There should onyl be
                //one key in here anyway!!
                var firstKey ;
                if(val === null || val === undefined || typeof val !== 'object')
                    firstKey = null;
                else
                    firstKey = Lodash.keys(val)[0];


                var op      = !firstKey ? "==" : procOp(firstKey);
                val         = !firstKey ?  val : val[firstKey];

                var ruleArgs  = { key : varname, op : op, val : val };
                return logic.addRule(grp, ruleArgs);
            }
        }


        //lets see if we need to perform some ops on this obj before we can move on.
        //mongo accepts queries like { a : b, c : d } but our queryBuilder interface
        //always results in queries { $and : [{a:b},{c:d}] . So , we need to convert
        //to our format.
        var nobj
        var extraKeys = Lodash.keys(obj).filter(function(v,k) {
            return ["$or","$and"].indexOf(v) === -1;
        });
        if(extraKeys.length > 0) {
//            console.log("EXTRAKEYS!", extraKeys, extraKeys.length)
            nobj = { "$and" : [] }  //root level is always an AND brohim!

            Lodash.each(obj, function(v,k) {
                var queryLine = {}
                queryLine[k] = v;
                nobj["$and"].push(queryLine);
            })
        }

        //let's see what we haf to iterate over!!
        var o = nobj || obj;
        o = logic.clone(o);   //for safety of further use of this object !

        //first group thing is flat. remember.
        var mainGroup = logic.addGroup({},true);
//        console.log("MAINGROUP BEGIN", JSON.stringify(mainGroup,null,2))
        Lodash.each(o, function(v,k) {
            if(Lodash.isArray(v)) {
                if(k === "$or")
                    mainGroup.mode = "OR";

                Lodash.each(v, function(v2){
                    processLine(v2, mainGroup);    //will give us a rule or a group to add!
                })
            }
            else {
                processLine(v, mainGroup);    //will give us a rule or a group to add!
            }
        })

        return mainGroup;
    }


    //run through m and turn into a mongo query
    function toMongoObj(m) {
        m = m || rootObject.m;

        function processItems(items, acc) {
            acc = acc || [];

            Lodash.each(items, function(v,k) {

                if(!Lodash.isUndefined(v.op)) {  //we now know that this is a rule
                    if(v.key !== "") {
                        var mongoRule = evalExpression(v.key,v.op,v.val);
                        acc.push(mongoRule);
                    }
                }
                else {  //we know that is a group so we need to recurse
                    acc.push(processGroup(v));
                }
            })

            return acc;
        }
        function processGroup(grp) {
            if(!grp)
                return null;

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

        function clone(obj){
            return JSON.parse(JSON.stringify(obj));
        }

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

        function addGroup(m, args) {
            m = m || rootObject.m;
            if(!m.items)
                m.items = [];

            var group = { isGroup : true }
            group.mode  = args && args.mode ? args.mode : "AND";
            group.items = args && args.items ? args.items : [];
            group.color = m.items.length % 2 === 0 ? colorToHex(color1) : colorToHex(color2);

            m.items.push(group);

            if(m === rootObject.m) {
                changed();
                lv.refresh();
            }

            return group;
        }

        function addRule(m, args){
            m = m || rootObject.m;

            var rule = {   }
            rule.key = args && args.key ? args.key : ""
            rule.val = args && args.val ? args.val : ""
            rule.op  = args && args.op  ? args.op  : ""


            if(!m.items)
                m.items = [];

            m.items.push(rule);

            if(m === rootObject.m) {
                changed();
                lv.refresh();
            }

            return rule;
        }

        function deleteItem(idx){
            if(m && m.items && m.items.length > idx) {
                m.items.splice(idx,1);
            }
            changed();
            lv.refresh();
        }


    }
    QtObject {
        id : guiWars
        property int depth     : 0
    }

    Item {
        id    : gui
        width : parent.width
        height: childrenRect.height


        Item {
            id     : topControls
            width  : parent.width
            height : cellHeight

            //udpate colors
            Connections {
                target : rootObject
                onRuleColorChanged : {
                    controls_groupMode_AND.colorFunc();
                    controls_groupMode_OR.colorFunc();
                }
                onColor1Changed : {
                    controls_groupMode_AND.colorFunc();
                    controls_groupMode_OR.colorFunc();
                }
                onMChanged : {
                    controls_groupMode_AND.colorFunc();
                    controls_groupMode_OR.colorFunc();
                }
            }


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
                    color : colorFunc();
                    function colorFunc(){
                         return color = m && m.mode === text ? ruleColor : color1
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
                         return color = m && m.mode === text ? ruleColor : color1
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
                    color     : addColor
                    textColor : 'white'
                    onClicked : logic.addRule()
                }
                SimpleButton {
                    width : minBtnWidth * 2
                    height : parent.height
                    text      : "+ Add group"
                    color     : addColor
                    textColor : 'white'
                    onClicked : logic.addGroup()
                }
                SimpleButton {
                    width : visible? minBtnWidth  *2 : 0
                    height : parent.height
                    text      : "x Delete"
                    color     : deleteColor
                    textColor : 'white'
                    visible : canBeDeleted
                    onClicked : deleteMe();
                }


            }
        }

//        Rectangle {
//            anchors.fill: lv
//            color : 'purple'
//            opacity : 0.5
//            z : Number.MAX_VALUE
//        }

        SimpleListView {
            id : lv
            width : parent.width
//            height : contentItem.childrenRect.height

            anchors.top      : topControls.bottom
            anchors.topMargin: cellHeight * 1/2
            spacing : 5
            model : rootObject.m ? rootObject.m.items : null
            minHeight : cellHeight
            function refresh() {
                model = null
                model = rootObject.m ? rootObject.m.items : null;
            }

            delegate: Item {
                id : del
                width          : lv.width
                height         : delLoader.height
                property var m : rootObject && rootObject.m && rootObject.m.items ? rootObject.m.items[index] : null
                property int _index : index
                Loader {
                    id : delLoader
                    anchors.right: parent.right
                    anchors.rightMargin: parent.width * 0.005
                    width : parent.width * 0.97
                    height : delLoader.item ? delLoader.item.height : cellHeight
                    source : !parent.m ?  "" :
                                         parent.m.isGroup ? "QueryGroup.qml" : "QueryRule.qml"
                    onLoaded : {
                        item.anchors.fill  = null;
                        item.anchors.right = delLoader.right
                        item.width         = Qt.binding(function() { return delLoader.width  })

                        if(item.hasOwnProperty("cellHeight"))
                            item.cellHeight    = cellHeight


                        item.availableVars = Qt.binding(function() { return rootObject.availableVars })
                        if(typeof item.deleteMe === 'function') {
                            item.deleteMe.connect(function() { logic.deleteItem(index); })
                            if(item.hasOwnProperty('canBeDeleted'))
                                item.canBeDeleted  = true;
                        }
                        if(typeof item.changed === 'function') {
                            item.changed.connect(function() {
//                                console.log("OH POOPERS CALLING CHANGED!!", JSON.stringify(item.m))
                                rootObject.changed();
                            });
                        }

                        if(item.hasOwnProperty("colorsObj")) {  //is group cause our groups have that
                            item.colorsObj = Qt.binding(function() { return rootObject.colorsObj })
                        }
                        else {
                            item.color         = Qt.binding(function() { return rootObject.ruleColor   })
                            item.deleteColor   = Qt.binding(function() { return rootObject.deleteColor })
                        }

                        item.m             = Qt.binding(function() { return del.m })
                    }
                }
                z : index === lv.currentIndex ? Number.MAX_VALUE : 0

//                        Text {
//                            anchors.centerIn: parent
//                            text : index
//                            font.pointSize: 32
//                        }

            }


        }


    }


    Rectangle {
       id : blocker
       anchors.fill: parent
       color : 'gray'
       opacity : 0.5
       MouseArea {
           anchors.fill: parent
           hoverEnabled: true
       }
       visible : !m
    }



}
