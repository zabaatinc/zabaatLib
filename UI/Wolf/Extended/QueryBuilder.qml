import QtQuick 2.4
import "../"
import Zabaat.Misc.Global 1.0
import Zabaat.UI.Fonts 1.0

ZTracer {       //valid types are string,number,money,date,null
    id : rootObject
    anchors.fill: null
    color : "black"

    property var fields        : []
    property var fields_widths : null   //will be equal width if this is not provided
    property var fields_types  : null   //we will consider them as string if this is null
    property var fields_labels : null
    property var demoneyFunc   : null

    signal queryChanged(var query)
    onFieldsChanged       : functions.init()
    onFields_typesChanged : functions.assignFieldTypes()
    onFields_widthsChanged: if(fields_widths)   functions.remainingWidthPercent = functions.calcRemaining()
    onFields_labelsChanged: if(fields_labels)   functions.assignLabels()

    property var   buildFunc : function(obj,key,value){     //this gets called and can be replaced for more fanciness
                                            obj[key] = value
                                       }
    function getQueryObj(){
        return functions.queryObj
    }

    property alias haveSearchIcon    : _seachIcon.visible


    ZButton {
        id      : _seachIcon
        enabled : false
        height  : rootObject.height
        width   : visible ? height : 0
        text    : ""
        icon    : FontAwesome.search
        iconPtr.font.pointSize : height * 0.4
    }
    Row {
        id    : boxesRow
        width : parent.width - _seachIcon.width
        height : parent.height
        anchors.left: _seachIcon.right

        property var map        : []
    }
    QtObject {
        id : functions
        property var    queryObj              : null
        property double remainingWidthPercent : 0
        onRemainingWidthPercentChanged: console.log("REMAINING WITDH PRECENT", remainingWidthPercent)

        property Component searchBoxFactory : Component {
            id : searchBoxFactory
            ZTwoWayTextBox {
                id : me
                property string name  : ""
                property int    index : -1
                height : rootObject.height
                width  : name !== "" && index !== -1 ? functions.getMyWidth(name,index) : 0
                onAccepted: if(name !== "" && index !== -1){
                                functions.queryChanged(name, index, text)
                            }
                labelName     : ZGlobal.functions.beautifyString(name)
                haveLabelRect : true
                state         : "top"
            }
        }

        function init(){
            if(fields){
                ZGlobal.functions.clearChildren(boxesRow)
                boxesRow.map = []

                for(var i = 0; i < fields.length; i++){
                    var f = fields[i]
                    var obj = searchBoxFactory.createObject(boxesRow)
                    obj.name  = f
                    obj.index = i

                    //map them
                    boxesRow.map.push(obj)
                }

                if(fields_widths)   functions.remainingWidthPercent = functions.calcRemaining()
                assignFieldTypes()
                assignLabels()
                rootObject.queryChanged({})     //lets do this for funzies
            }
        }
        function queryChanged(name, index, text){
            if(queryObj === null)
                queryObj = {}

            var type = ZGlobal.functions.getType(fields)
            var f    = type === "array" ? fields[index] : fields[name]
            if(queryObj[f] !== text){
                if(text === ""){
                    delete queryObj[f]
                    rootObject.queryChanged(queryObj)
                }
                else {
                    if(fields_types !== null){
                        var ftypestype = ZGlobal.functions.getType(fields_types)
                        var itemType   = ftypestype === "array" ? fields_types[index] : fields_types[name]
                        switch(itemType){
                            case "number":  buildFunc(queryObj,f,+text);
                                            break;

                            case "date"  :  var date    = new Date(text);
                                            buildFunc(queryObj,f,date.toISOString())
                                            break;

                            case "money" :  if(demoneyFunc)
                                                buildFunc(queryObj,f,demoneyFunc(text))
                                            else
                                                buildFunc(queryObj,f,+text)
                                            break;

                            default      :  buildFunc(queryObj,f,text)
                                            break;
                        }
                        rootObject.queryChanged(queryObj);
                    }
                    else {
                        buildFunc(queryObj,f,text)
                        rootObject.queryChanged(queryObj)
                    }
                }
            }
        }
        function getMyWidth(name, index){
            var type = ZGlobal.functions.getType(fields_widths)
            if(type === "array") {

                if(ZGlobal.functions.isDef(fields_widths[index])) {
//                    console.log(index , "=" , fields_widths[index])
                    return fields_widths[index] * boxesRow.width
                }
//                console.log(index , "=" , remainingWidthPercent)
                return boxesRow.width * remainingWidthPercent
            }
            else if(type === "object"){
                if(ZGlobal.functions.isDef(fields_widths[name]))
                    return fields_widths[name] * boxesRow.width
                return boxesRow.width * remainingWidthPercent
            }
            return boxesRow.width / fields.length
        }
        function calcRemaining(type){
            if(ZGlobal.functions.isDef(fields_widths,fields)){
                var count = fields.length;
                var total = 1;
                if(ZGlobal.functions.isUndef(type))
                    type = ZGlobal.functions.getType(fields_widths)

                for(var f in fields_widths){
                    var widthObj = fields_widths[f]
                    if(ZGlobal.functions.isDef(widthObj)){
                        total -= widthObj
                        count--;
                    }
                }
//                console.log("total",total, "count",count)
            }

            return total > 0 && count > 0 ? total/count : 0
        }
        function assignFieldTypes(){
            if(fields && fields_types && boxesRow.map && boxesRow.map.length > 0){
                var propertyType = ZGlobal.functions.getType(fields_types)
                for(var i = 0; i < fields.length; i++){
                    var f = fields[i]
                    var fType = propertyType === "array" ? fields_types[i] : fields_types[f]
                    var item  = boxesRow.map[i]
                    if(item) {
                        switch(fType){
                            case "time"   : item.validator = timeRegex; item.helpText = "hh:mm AP"  ; break;
                            case "date"   : item.validator = dateRegex; item.helpText = "mm/dd/yyyy"; break;
                            default       : item.validator = null;      item.helpText = "";           break;
                        }
                    }
                }
            }
        }
        function assignLabels(){
            if(fields && fields_labels && boxesRow.map && boxesRow.map.length > 0){
                var propertyType = ZGlobal.functions.getType(fields_labels)
                for(var i = 0; i < fields.length; i++){
                    var f = fields[i]
                    var label = propertyType === "array" ? fields_labels[i] : fields_labels[f]
                    if(ZGlobal.functions.isDef(label)){
                        var item  = boxesRow.map[i]
                        item.labelName = label
                    }
                }
            }
        }


    }
    RegExpValidator{ id: dateRegex;  regExp : ZGlobal.regularExpressions.dateSlashesOnly }
    RegExpValidator{ id: timeRegex;  regExp : ZGlobal.regularExpressions.time            }

}

