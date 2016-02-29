import QtQuick 2.5
import Zabaat.Utility 1.0 as U  //replace later
ListModel {
    id: rootObject
    property var sourceModel : null
    property var queryTerm   : null
    onSourceModelChanged: logic.init()
    onQueryTermChanged  : logic.init()


    function setRelatedIdx(index, thisIndex){
        if(thisIndex === null || typeof thisIndex === 'undefined')
            thisIndex = rootObject.count -1

        var obj = rootObject.get(thisIndex)
        obj.__relatedIndex = index;
    }

    property QtObject logic : QtObject{
        id : logic
        property Connections connections : Connections {
            target : sourceModel ? sourceModel : null
            onRowsInserted   : {
                var start = arguments[1]
                var end   = arguments[2]
                var count = end - start + 1

                //let's increment the other rows!!
                for(var i = 0 ; i < rootObject.count; ++i){
                    var item = rootObject.get(i)
                    if(item && item.__relatedIndex >= start){
                        item.__relatedIndex += count
                    }
                }

                for(var i = start; i <= end; ++i){
                    var newItem = sourceModel.get(i)
                    var matchItem = logic.match(newItem)
                    if(matchItem) { //we need to make sure if this occurs, that we push the other rows!!
                        rootObject.append(newItem)
                        setRelatedIdx(i)
                    }
                }

//                console.log("INSERTED",start,end)
//                for(var k in arguments) console.log(k,arguments[k])
            }
            onRowsMoved      : {
//                for(var i = 0; i < arguments.length; ++i){
//                    var a = arguments[i]
//                    if(a.toString() === "QModelIndex()"){
//                        console.log(a.row, a.column, a.rows)
//                    }
//                    else
//                        console.log(a)
//                }
                console.log("---------")
                var start           = arguments[1]
                var end             = arguments[2]
                var count           = end - start +1
                var destinationEnd  = arguments[4] -1 //this is where the
                var startEnd        = destinationEnd - (end-start);

                var arrOrig = helperFunctions.getArr(start,end)
                var arrDest = helperFunctions.getArr(startEnd,destinationEnd)
//                console.log("orig:" , arrOrig)
//                console.log("dest:" , arrDest)

                var moveConstant = startEnd - start
                console.log(moveConstant)
                for(var i = 0; i < rootObject.count; ++i){
                    var item = rootObject.get(i)
                    if(item){
                        var r   = item.__relatedIndex
                        if(r < start){
                            item.__relatedIndex += count
                        }
                        else if(r >= start && r <= end){
                            item.__relatedIndex += moveConstant
                        }
                        else if(r < destinationEnd + count){
                            item.__relatedIndex -= count
                        }
                    }
                }
//                console.log(count,"rows moved from", start,":",end,"to",startEnd,":",destinationEnd)
            }
            onRowsRemoved    : {
                var start = arguments[1]
                var end   = arguments[2]

                //rows removed signal always happens in an array

                var count = end - start + 1 //this is the amount of things that need it's indexes updated

                //first let's find the items that were deleted, and remove them from our model
                var iteration = 0;
                for(var s = start; s <= end; s++){
                    for(var i = rootObject.count -1; i >=0; --i){
//                        console.log("s",s,"i",i)
                        var item = rootObject.get(i)
                        if(item){
                            if(item.__relatedIndex === s){
//                                console.log("match!")
                                rootObject.remove(i);
                            }
                            //updates the relatedIndexes
                            else if(iteration === 0 && item.__relatedIndex > end){
                                item.__relatedIndex -= count
                            }
                        }
                    }
                    ++iteration
                }
                console.log("removed",start,end,count)
            }
//            onColumnsInserted: { console.log(arguments) }
//            onColumnsMoved   : { console.log(arguments) }
//            onColumnsRemoved : { console.log(arguments) }
//            onCountChanged   : logic.findMatches()
            onDataChanged    : {
//                var start = arguments[1]
//                var end   = arguments[2]

//                for(var i = 0; i < end.length; ++i)
//                    console.log(i,end[i])
                var idx         = arguments[1].row
                var changedItem = sourceModel.get(idx)
                for(var i = 0; i < rootObject.count; ++i){
                    var item = rootObject.get(i)
                    if(idx === item.__relatedIndex){
                        var matchItem = logic.match(changedItem)
                        rootObject.remove(i)
                        if(matchItem){
                            rootObject.insert(i,changedItem)
                            setRelatedIdx(i,i)
                        }
                    }
                }

//                logic.findMatches()
            }
            onModelReset     : logic.findMatches()
        }

        function init(){
            rootObject.clear()
            findMatches()
        }
        function findMatches(){
            rootObject.clear()
            if(!sourceModel || !queryTerm || sourceModel.count === 0){
                return;
            }

//            console.log("Finding matches",sourceModel.count)
            for(var i = 0 ; i < sourceModel.count; ++i){
                var modelItem = sourceModel.get(i)
//                console.log(i, JSON.stringify(modelItem,null,2))
                var matchItem = match(modelItem)
                if(matchItem){
                    rootObject.append(modelItem)
                    setRelatedIdx(i)
//                    for(var k in obj){
//                        if(k !== 'objectName' && k !== 'objectNameChanged' && k.indexOf("__") === -1 )
//                        {
//                            obj[k] = Qt.binding(function() {  var m = sourceModel ? sourceModel.get(i) : null;
//                                                              return m ? m[k] : "HURR"
//                                                           })
//                        }
//                    }
                }
            }
        }
        function match(modelItem){  //the brains of the whole deal!
//            console.log("match")
            var qObj = queryTerm
            if(!qObj)
                return

            var op   = qObj.op ? qObj.op : "contains"
            var count = 0;
            for(var q in queryTerm){
                if(q === "op")
                    continue

                var queryVal = queryTerm[q]
                if(helperFunctions.getFromArray(booleanLogic.connectorTokens,q,null,true) !== -1){
//                    console.log("OH SHIT CONNECTOR TOKENS")
                }
                else {
                    var mObj   = q.indexOf(".") === -1 ? modelItem[q] : helperFunctions.deepGet(modelItem,q)
//                    console.log(JSON.stringify(modelItem), JSON.stringify(mObj))

                    var result = booleanLogic.operationExecute(mObj,op,queryVal)
//                    console.log(q , "match:" , JSON.stringify(mObj), op,JSON.stringify(queryVal), " = " , result)
                    if(!result){
                        return false;
                    }
                }
                count++
            }
//            console.log(count)
            return count === 0 ?  false : true;
        }


        property QtObject booleanLogic : QtObject {
            id : booleanLogic

            property var connectorTokens : ["and","or","&&" ,'||']
            property var tokens:[ "not","equals","gt","gte","lt","lte","contains"
                                 ,"!=" , "=="   ,">" ,">=" ,"<" ,"<="]

            //determines if the op matches
            //returns true or false
            function operationExecute(item1,op,item2){
                var t1 = helperFunctions.getType(item1)
                var t2 = helperFunctions.getType(item2)
                var validOperator = helperFunctions.getFromArray(tokens,op,null,true) !== -1

                if(!validOperator){
//                    console.error("not a valid operator",op)
                    return false;
                }
//                console.log(t1)

                //if the types are different, they are not equal. duh.
                //make special note of the != op.
                if(t1 !== t2){
                    return helperFunctions.or(op,"!=","not") ? true : false
                }
                else {
                    //normal js data type, can be checked
                    if(t1 === 'function')   //for simplicity and sanity, we will say that all functions are the same. HAPPY?
                        return true;
                    else if(helperFunctions.or(t1.toLowerCase(),"string","number","date","datetime")){
//                        console.log("@@ STD")
                        return stdDataTypeExpression(item1,op,item2)
                    }
                    //only these operators apply for other types!!
                    else if(helperFunctions.or(op,"equals","==","not","!=")) {
                        if(t1 === 'object'){
//                            console.log("@@ OBJ")
                            return objEquality(item1,op,item2)
                        }
                        else if(t1 === 'array'){
//                            console.log("@@ ARRAY")
                            return arrayEquality(item1,op,item2)
                        }
                        else if(helperFunctions.isListModel(item1)) { // (including listmodels!)
//                            console.log("@@ LIST")
                            return listEquality(item1,op,item2)
                        }
                        else { //leaves us in the realm of qml equality checks!
//                            console.log("@@ QML")
                            return qmlObjectEquality(item1,op,item2)
                        }
                    }
//                    console.log("@@ NONE")
                    return false
                }
            }

            function arrayEquality(arr1,op,arr2){   //expects sorted array!?
                var expectedRes = helperFunctions.or(op,"==","equals") ? true : false
                if(arr1.length !== arr2.length){
                    return false === expectedRes;
                }
                for(var i = 0; i < arr1.length; ++i){
                    var i1 = arr1[i]
                    var i2 = arr2[i]
                    if(!operationExecute(i1,"==",i2))
                        return false === expectedRes
                }
                return true === expectedRes
            }
            function objEquality(item1,op,item2){
                var expectedRes        = helperFunctions.or(op,"==","equals") ? true : false
                var haveSameProperties = arrayEquality(helperFunctions.getProperties(item1), "==",  helperFunctions.getProperties(item2))
                if(!haveSameProperties)
                    return false && expectedRes

                //now let's go over each property!!
                for(var k in item1){
                    var i1 = item1[k]
                    var i2 = item2[k]
                    if(!operationExecute(i1,"==",i2))
                        return false === expectedRes
                }
                return true === expectedRes
            }
            function listEquality(list1,op,list2){
                var expectedRes = helperFunctions.or(op,"==","equals") ? true : false
                if(list1.count !== list2.count)
                    return false === expectedRes
                for(var i = 0; i < arr1.length; ++i){
                    var i1 = list1.get(i)
                    var i2 = list2.get(i)
                    if(!operationExecute(i1,"==",i2))
                        return false === expectedRes
                }
                return true === expectedRes
            }
            function qmlObjectEquality(obj1,op,obj2){
                //for sake of simplicity, we will only check their qml names!
                var expectedRes = helperFunctions.or(op,"==","equals") ? true : false
                return (helperFunctions.qmlName(obj1) === helperFunctions.qmlName(obj2)) === expectedRes
            }
            function stdDataTypeExpression(item1,op,item2){
//                console.log(item1,op,item2)
                switch(op.toLowerCase()){
                    case "equals": return item1 === item2;
                    case "=="    : return item1 === item2;
                    case "gt"    : return item1 >   item2;
                    case ">"     : return item1 >   item2;
                    case "gte"   : return item1 >=  item2;
                    case ">="    : return item1 >=  item2;
                    case "lt"    : return item1 <   item2;
                    case "<"     : return item1 <   item2;
                    case "lte"   : return item1 <=  item2;
                    case "<="    : return item1 <=  item2;
                    case "not"   : return item1 !== item2;
                    case "!="    : return item1 !== item2;
                    case "contains" : return item1.toString().indexOf(item2.toString()) !== -1
                }
                return false;
            }
        }
        property QtObject helperFunctions : QtObject {
            id : helperFunctions
            function or(val){
                if(arguments.length > 1){
                    for(var i = 1 ; i < arguments.length; ++i){
                        if(val === arguments[i])
                            return true;
                    }
                }
                return false
            }

            function getArr(start,end){
                var arr = []
                if(isDef(start,end) && end > start){
                    for(var i = start; i <= end; ++i)
                        arr.push(i);
                }
                return arr
            }

            function isUndef(){
                if(arguments.length === 0)
                    return true

                for(var i = 0; i < arguments.length ; i++){
                    var item = arguments[i]
                    if(item === null || typeof item === 'undefined')
                        return true
                }
                return false
            }
            function isDef(){
                if(arguments.length === 0)
                    return false

                for(var i = 0; i < arguments.length; i++){
                    var item = arguments[i]
                    if(item === null || typeof item === 'undefined')
                        return false
                }
                return true
            }
            function deepGet(obj, propStr){
                if(isUndef(obj, propStr))
                    return null

        //            console.log(propStr)
                var propArray = []
                if(typeof propStr === "string"){
                    //turn this into a nice array that we can just walk over!!
                    //[1]foo.bar[0].green[0]

                    //first lets convert the []s into dots
                    while(propStr.indexOf("[") !== -1){
                        var startIdx = propStr.indexOf("[")
                        var endIdx   = propStr.indexOf("]")

                        if(startIdx +1  !== endIdx ){
                            var varname = propStr.slice(startIdx+1, endIdx )
                            propArray.push(varname)
        //                        console.log(varname)
                            //remove the whole between [ and ]
                        }
                        propStr = propStr.replace(propStr.slice(startIdx, endIdx +1)  , "@")
        //                    console.log(propStr)
                    }

                    //now subdivide on "."
                    propStr            = propStr.split(".")
                    var propArrCounter = propArray.length - 1
                    for(var i = propStr.length - 1; i >= 0; i--){

                        while(propStr[i].indexOf("@") !== -1){
                            varname = propStr[i]
                            var idx = propStr[i].indexOf("@")
                            if(idx !== -1){
                                if(idx === 0){  //insert var before
                                    propStr[i] = varname.slice(1)
                                    propStr.splice(i,0, propArray[propArrCounter])
                                    propArrCounter--
                                }
                                else{           //insert var after (this is at the end)
                                   propStr[i] = varname.slice(0,-1)
                                   propStr.splice(i+1,0, propArray[propArrCounter])
                                   propArrCounter--
                                }
                            }
                        }
                    }
                }
                propArray = propStr
        //            console.log("end = > ", propArray)

                if(isDef(obj,propArray)){
                    //iterate!!
                    var objPtr = obj
                    for(var p in propArray){
                        var prop = propArray[p]
                        if(isDef(objPtr[prop])){
                            objPtr = objPtr[prop]
                        }
                        else
                            return null
                    }
                    return objPtr
                }
                else
                    return null
            }
            function has(obj, propStr){
               if(isDef(deepGet(obj,propStr)))
                   return true
               return false
            }

            function getProperties(obj, exclude, doesNotContain){
                var propArr = []

                function indexOf(array,item){
                    var i = 0, length = array && array.length;
                    for (; i < length; i++)
                        if (array[i] === item) return i;
                    return -1;
                }

                if(!isUndef(obj)) {
                    if(toString.call(obj) === '[object Array]'){  //is array
                        for(var i = 0; i < obj.length ; i++){
                            propArr.push(i)
                        }
                    }
                    else{
                        for(var o in obj){
                            var doesNotContainPass = -2
                            if(doesNotContain)
                                doesNotContainPass = o.indexOf(doesNotContain)

                            if(doesNotContainPass < 0)  //-1 && -2 are both passes!!
                            {
                                if(!isUndef(exclude) && !isUndef(exclude.length) &&  exclude.length > 0)
                                {
                                    if(indexOf(exclude,o) === -1)
                                        propArr.push(o)
                                }
                                else {
                                    propArr.push(o)
                                }
                            }
                        }
                    }
                }

                propArr.sort()
                return propArr
            }

            function getFromList(list,value,prop, giveMeIndex) {
                if(!list)
                    return giveMeIndex ? -1 : null;

                for(var i = 0 ; i < list.count; ++i){
                    var item = list.get(i)
                    if(item){
                        if((prop === null || typeof prop === 'undefined') && booleanLogic.objEquality(item,value))
                            return giveMeIndex ? i : item;
                        else if(item[prop] && item[prop] === value)
                            return giveMeIndex ? i : item;
                    }
                }
                return giveMeIndex ? -1 : null;
            }
            function getFromArray(arr,value,prop, giveMeIndex){
                if(!arr)
                    return giveMeIndex ? -1 : null;

                for(var i = 0 ; i < arr.length; ++i){
                    var item = arr[i]
                    if(item){
                        if((prop === null || typeof prop === 'undefined') && item === value) {
                            return giveMeIndex ? i : item;
                        }
                        else if(item[prop] && item[prop] === value)
                            return giveMeIndex ? i : item;
                    }
                }
                return giveMeIndex ? -1 : null;
            }

            function getType(obj){
                if(obj === null)
                    return null;
                var type = typeof obj
                if(type === 'object'){
                    if(toString.call(obj) === '[object Array]')
                        return "array"
                    var qName = qmlName(obj)
                    return qName === "" ? "object" : qName
                }
                else {
                    return type;
                }
            }
            function qmlName(obj){ //every qml item is going to have an objectName
                if(obj && obj.hasOwnProperty && obj.hasOwnProperty("objectName")){
                    var name = obj.toString()
                    var idx = name.indexOf("(")
                    return idx !== -1 ? name.slice(0,idx) : name;
                }
                return ""
            }

            function isListModel(obj){
                if(obj === null || typeof obj === 'undefined')
                    return false;
                return obj.hasOwnProperty("objectName") &&
                       obj.hasOwnProperty("count")      &&
                       typeof obj.get === 'function'
            }

        }

    }




}
