//function WorkerScript(_model , _sourceModel){
//    model       = _model;
//    sourceModel = _sourceModel;
//    queryTerm   = null;
//}
//var sourceModel = null;
//var rootModel   = null;
//var queryTerm   = null;
//var operationQ  = [];
.pragma library

function sendMessage(msg, debug) {
    var d           = msg.data
    var rootModel   = d.model
    var sourceModel = d.sourceModel
    var queryTerm   = d.queryTerm

    var s            = msg.sort
    var sortRoles    = s.roles
    var userCmpFunc  = s.fn


    var debugMsg = function(){
        if(debug){
            console.log.apply(this,arguments)
        }
    }

    var logic = {
        setRelatedIdx: function(index, thisIndex){
    //        console.log("set related index")
            if(!rootModel)
                return;

            if(thisIndex === null || typeof thisIndex === 'undefined')
                thisIndex = rootModel.count -1

            var obj = rootModel.get(thisIndex)
            obj.__relatedIndex = index;
        },

        findMatches: function(){
    //        console.log("finding matches for", JSON.stringify(queryTerm), sourceModel, model)
            if(!rootModel || !sourceModel || !queryTerm || sourceModel.count === 0)
                return;

            rootModel.clear()
            for(var i = 0 ; i < sourceModel.count; i++){
    //            console.log(i)
                var modelItem = sourceModel.get(i)
    //            console.log(matchItem)
                if(logic.match(modelItem)){
    //                console.log(JSON.stringify(modelItem,null,2))
                    if(typeof modelItem.toJSON === 'function')
                        rootModel.append(modelItem.toJSON())
                    else
                        rootModel.append(modelItem)

                    logic.setRelatedIdx(i)
    //                console.log("COPY", JSON.stringify(rootModel.get(i),null,2))
                }
            }
    //        console.log("finished finding matches")
//            rootModel.sync()
        },

        getOperator : function(obj){
            if(typeof obj !== 'object')
                return "$contains";

            for(var o in obj){
                if(o.charAt(0) === "$")
                    return o
            }
            return "$contains"
        },

        getQueryRhs : function(obj) {
            if(typeof obj !== 'object')
                return obj

            for(var o in obj){
                return obj[o]
            }
            return obj
        },


        match : function(modelItem, queryObj){  //the brains of the whole deal!
    //        console.log("matching")
            if(!queryObj)
                queryObj = queryTerm

            for(var q in queryObj){
                var queryVal = queryObj[q]
                var op       = logic.getOperator(queryVal)


                if(q.charAt(0) !== "$"){    //is a variable name
                    var mObj   = q.indexOf(".") === -1 ? modelItem[q] : helperFunctions.deepGet(modelItem,q)
                    return  booleanLogic.operationExecute(mObj, op , logic.getQueryRhs(queryVal))
                }
                else {
                    var innerQTerm;
    //                    var numMatches = 0;
                    if(q === "$or" || q === "||"){
                        for(var i = 0; i < queryVal.length; ++i){
                            if(logic.match(modelItem, queryVal[i]))
                                return true;
                        }
                        return false;
                    }
                    else if(q === "$nor" || q === "!||"){
                        for(i = 0; i < queryVal.length; ++i){
                            if(logic.match(modelItem, queryVal[i]))
                                return false;
                        }
                        return true;
                    }
                    else if(q === "$and" || q === "&&"){
                        for(i = 0; i < queryVal.length; ++i){
                            if(!logic.match(modelItem, queryVal[i])){
                                return false;
                            }
                        }
                        return true;
                    }
                    else if(q === "$nand"|| q === "!&&"){     //opposite of and!
                        for(i = 0; i < queryVal.length; ++i){
                            if(!logic.match(modelItem, queryVal[i])){
                                return true;
                            }
                        }
                        return false;
                    }
                    else if(q === "$xor"){
                        var numMatches = 0;
                        for(i = 0; i < queryVal.length; ++i){
                            if(logic.match(modelItem,queryVal[i])){
                                numMatches++
                                if(numMatches > 1) //we can only have 1!! ITS EXCLUSIVE OR!!
                                    return false;
                            }
                        }
                        if(numMatches)
                            return true;
                    }
                }

                //illegal token??
                return false;
            }
            return false;
        }



    }
    var booleanLogic = {
        connectorTokens : ["$and","$or", "$xor", "$nand" , "&&" ,'||'] ,
        tokens          :[ "$not","$equals","$gt","$gte","$lt","$lte","$contains","!=" , "=="   ,">" ,">=" ,"<" ,"<="] ,


        //determines if the op matches
        //returns true or false
        operationExecute : function(item1,op,item2){
            var t1 = helperFunctions.getType(item1)
            var t2 = helperFunctions.getType(item2)
            var validOperator = helperFunctions.getFromArray(booleanLogic.tokens,op,null,true) !== -1

//            console.log("operationExecute",item1,op,JSON.stringify(item2))

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
                    return booleanLogic.stdDataTypeExpression(item1,op,item2)
                }
                //only these operators apply for other types!!
                else if(helperFunctions.or(op,"equals","==","not","!=")) {
                    if(t1 === 'object'){
    //                            console.log("@@ OBJ")
                        return booleanLogic.objEquality(item1,op,item2)
                    }
                    else if(t1 === 'array'){
    //                            console.log("@@ ARRAY")
                        return booleanLogic.arrayEquality(item1,op,item2)
                    }
                    else if(helperFunctions.isListModel(item1)) { // (including listmodels!)
    //                            console.log("@@ LIST")
                        return booleanLogic.listEquality(item1,op,item2)
                    }
                    else { //leaves us in the realm of qml equality checks!
    //                            console.log("@@ QML")
                        return booleanLogic.qmlObjectEquality(item1,op,item2)
                    }
                }
    //                    console.log("@@ NONE")
                return false
            }
        } ,


        arrayEquality : function(arr1,op,arr2){   //expects sorted array!?
            var expectedRes = helperFunctions.or(op,"==","equals") ? true : false
            if(arr1.length !== arr2.length){
                return false === expectedRes;
            }
            for(var i = 0; i < arr1.length; ++i){
                var i1 = arr1[i]
                var i2 = arr2[i]
                if(!booleanLogic.operationExecute(i1,"==",i2))
                    return false === expectedRes
            }
            return true === expectedRes
        },
        objEquality : function(item1,op,item2){
            var expectedRes        = helperFunctions.or(op,"==","equals") ? true : false
            var haveSameProperties = booleanLogic.arrayEquality(helperFunctions.getProperties(item1), "==",  helperFunctions.getProperties(item2))
            if(!haveSameProperties)
                return false && expectedRes

            //now let's go over each property!!
            for(var k in item1){
                var i1 = item1[k]
                var i2 = item2[k]
                if(!booleanLogic.operationExecute(i1,"==",i2))
                    return false === expectedRes
            }
            return true === expectedRes
        },
        listEquality : function(list1,op,list2){
            var expectedRes = helperFunctions.or(op,"==","equals") ? true : false
            if(list1.count !== list2.count)
                return false === expectedRes
            for(var i = 0; i < arr1.length; ++i){
                var i1 = list1.get(i)
                var i2 = list2.get(i)
                if(!booleanLogic.operationExecute(i1,"==",i2))
                    return false === expectedRes
            }
            return true === expectedRes
        },
        qmlObjectEquality : function(obj1,op,obj2){
            //for sake of simplicity, we will only check their qml names!
            var expectedRes = helperFunctions.or(op,"==","equals") ? true : false
            return (helperFunctions.qmlName(obj1) === helperFunctions.qmlName(obj2)) === expectedRes
        },
        stdDataTypeExpression : function(item1,op,item2){
    //                console.log(item1,op,item2)
            switch(op.toLowerCase()){
                case "$equals": return item1 === item2;
                case "=="    : return item1 === item2;
                case "$gt"    : return item1 >   item2;
                case ">"     : return item1 >   item2;
                case "$gte"   : return item1 >=  item2;
                case ">="    : return item1 >=  item2;
                case "$lt"    : return item1 <   item2;
                case "<"     : return item1 <   item2;
                case "$lte"   : return item1 <=  item2;
                case "<="    : return item1 <=  item2;
                case "$not"   : return item1 !== item2;
                case "!="    : return item1 !== item2;
                case "$contains" : return item1.toString().indexOf(item2.toString()) !== -1
            }
            return false;
        }

    }
    var helperFunctions = {

        or : function(val){
            if(arguments.length > 1){
                for(var i = 1 ; i < arguments.length; ++i){
                    if(val === arguments[i])
                        return true;
                }
            }
            return false
        },

        getArr : function(start,end){
    //                console.log(start,end)
            var arr = []
            if(helperFunctions.isDef(start,end) && end >= start){
                for(var i = start; i <= end; ++i)
                    arr.push(i);
            }
            return arr
        },

        isUndef : function(){
            if(arguments.length === 0)
                return true

            for(var i = 0; i < arguments.length ; i++){
                var item = arguments[i]
                if(item === null || typeof item === 'undefined')
                    return true
            }
            return false
        },

        isDef : function(){
            if(arguments.length === 0)
                return false

            for(var i = 0; i < arguments.length; i++){
                var item = arguments[i]
                if(item === null || typeof item === 'undefined')
                    return false
            }
            return true
        },

        deepGet : function(obj, propStr){
            if(helperFunctions.isUndef(obj, propStr))
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

            if(helperFunctions.isDef(obj,propArray)){
                //iterate!!
                var objPtr = obj
                for(var p in propArray){
                    var prop = propArray[p]
                    if(helperFunctions.isDef(objPtr[prop])){
                        objPtr = objPtr[prop]
                    }
                    else
                        return null
                }
                return objPtr
            }
            else
                return null
        },

        has : function(obj, propStr){
           if(helperFunctions.isDef(helperFunctions.deepGet(obj,propStr)))
               return true
           return false
        },


        getProperties : function(obj, exclude, doesNotContain){
            var propArr = []

            function indexOf(array,item){
                var i = 0, length = array && array.length;
                for (; i < length; i++)
                    if (array[i] === item) return i;
                return -1;
            }

            if(!helperFunctions.isUndef(obj)) {
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
                            if(!helperFunctions.isUndef(exclude) && !helperFunctions.isUndef(exclude.length) &&  exclude.length > 0)
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
        },

        getFromList : function(list,value,prop, giveMeIndex) {
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
        },

        getFromArray : function(arr,value,prop, giveMeIndex){
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
        },

        getType : function(obj){
            if(obj === null)
                return null;
            var type = typeof obj
            if(type === 'object'){
                if(toString.call(obj) === '[object Array]')
                    return "array"
                var qName = helperFunctions.qmlName(obj)
                return qName === "" ? "object" : qName
            }
            else {
                return type;
            }
        },

        qmlName : function(obj){ //every qml item is going to have an objectName
            if(obj && obj.hasOwnProperty && obj.hasOwnProperty("objectName")){
                var name = obj.toString()
                var idx = name.indexOf("(")
                return idx !== -1 ? name.slice(0,idx) : name;
            }
            return ""
        },

        isListModel: function(obj){
            if(obj === null || typeof obj === 'undefined')
                return false;
            return obj.hasOwnProperty("objectName") &&
                   obj.hasOwnProperty("count")      &&
                   typeof obj.get === 'function'
        }




    }

    var handleRowsInserted = function(start,end,count){
        //let's increment the other rows!!
        for(var i = 0 ; i < rootModel.count; ++i){
            var item = rootModel.get(i)
            if(item && item.__relatedIndex >= start){
                item.__relatedIndex += count
            }
        }
    //    console.log(JSON.stringify(sourceModel.get(start),null,2) , sourceModel.count)
    //    console.log("-------------------------------------------------------")

        for(i = start; i <= end; ++i){
            var newItem = sourceModel.get(i)
            var matchItem = logic.match(newItem)
            if(matchItem) { //we need to make sure if this occurs, that we push the other rows!!
                rootModel.append(newItem)
                logic.setRelatedIdx(i)
            }
        }
//        rootModel.sync()
    //    console.log("JS:: handleRowsInserted Finished")
    }
    var handleRowsMoved = function(start,end,startEnd,destinationEnd,count){
        var arrOrig = helperFunctions.getArr(start,end)
        var arrDest = helperFunctions.getArr(startEnd,destinationEnd)
    //                console.log("orig:" , arrOrig)
    //                console.log("dest:" , arrDest)

        var moveConstant = startEnd - start
    //                console.log(moveConstant, arrOrig, arrDest)
        for(var i = 0; i < rootModel.count; ++i){
            var item = rootModel.get(i)
            if(item){
                var r   = item.__relatedIndex
                if(r < start){
    //                            console.log("r < start", item.name, r)
                    item.__relatedIndex += count
                }
                else if(r >= start && r <= end){
    //                            console.log("r mid", item.name, r)
                    item.__relatedIndex += moveConstant
                }
                else if(r <= destinationEnd ){
    //                            console.log("r last", item.name, r)
                    item.__relatedIndex -= count
                }
            }
        }
    //    console.log("move Finished")
//        rootModel.sync()
    }
    var handleRowsRemoved = function(start,end,count){

        for(var i = rootModel.count -1; i >=0; --i){
    //                        console.log("s",s,"i",i)
            var item = rootModel.get(i)
            if(item){
                var r    = item.__relatedIndex
                if(r >= start && r <= end){
                    rootModel.remove(i);
                }
                else if(item.__relatedIndex > end){
                    item.__relatedIndex -= count
                }
            }
        }
//        rootModel.sync()
    }
    var handleDataChanged = function(idx){
//        debugMsg("Data Changed handler",idx)
        var changedItem = sourceModel.get(idx)

        //if exists remove it cause it may not match anymore
        for(var i = 0; i < rootModel.count; ++i){
            var item = rootModel.get(i)
            if(idx === item.__relatedIndex){
//                debugMsg("remove @",i, JSON.stringify(changedItem,null,2))
//                debugMsg("removed @",i)
                rootModel.remove(i)
                break;
            }
        }

        //if it matches, now add it.
        var matchItem = logic.match(changedItem)
        if(matchItem){
            rootModel.insert(i,changedItem)
            logic.setRelatedIdx(idx,i)
//            debugMsg("insert @",i,"with relative idx", idx)
        }
//        rootModel.sync()
    }



    /* A[] --> Array to be sorted, http://www.geeksforgeeks.org/iterative-quick-sort/
       l  --> Starting index,
       h  --> Ending index */
    var quickSortIterative = function (l, h){

        function cmpFunc(a,b) {

            function defaultCmpFunc(aVal,bVal,roles){
                if(roles === null || typeof roles === 'undefined' ){
    //                console.log("roiles are undefined")
                    if(aVal < bVal)
                        return -1
                    else if(aVal > bVal)
                        return 1
                    return 0
                }

    //            console.log(roles)
                for(var r = 0; r < roles.length; ++r){

                    var role = roles[r]
    //                console.log("on Role", role)
                    var v1 = role.indexOf(".") !== -1 ? helperFunctions.deepGet(aVal,role) : aVal[role]
                    var v2 = role.indexOf(".") !== -1 ? helperFunctions.deepGet(bVal,role) : bVal[role]

    //                console.log("____ ITERATING OVER ____" , role)

                        if(v1 === v2 ) {
    //                        console.log(v1,"is eqto", v2)
                            continue
                        }
                        else if(v1 < v2) {
    //                        console.log(v1,"is lt", v2)
                            return -1
                        }
                        else {
    //                        console.log(v1,"is gt", v2)
                            return 1
                        }

                }
                return 0
            }


            var sfunc = userCmpFunc ? userCmpFunc : defaultCmpFunc
            var aVal  = rootModel.get(a)
            var bVal  = rootModel.get(b)

            return sfunc(aVal,bVal, sortRoles)
        }
        function swap(a,b){
            if (a<b) {
                rootModel.move(a,b,1);
                rootModel.move(b-1,a,1);
            }
            else if (a>b) {
                rootModel.move(b,a,1);
                rootModel.move(a-1,b,1);
            }
        }
        function partition (l, h) { //l = startIndex, h = endIndex
            var arr = rootModel

//            var x = arr.get(h);
            var i = l - 1;

            for (var j = l; j <= h- 1; j++)
            {
                if (cmpFunc(j,h) <= 0)
                {
                    i++;
                    swap (i, j);
                }
            }
            swap (i + 1, h);
            return (i + 1);
        }

        // Create an auxiliary stack
        var stack = [] //[ h - l + 1 ];

        // initialize top of stack
        var top = -1;

        // push initial values of l and h to stack
        stack[ ++top ] = l;
        stack[ ++top ] = h;

        // Keep popping from stack while is not empty
        while ( top >= 0 )
        {
            // Pop h and l
            h = stack[ top-- ];
            l = stack[ top-- ];

            // Set pivot element at its correct position
            // in sorted array
            var p = partition( l, h );

            // If there are elements on left side of pivot,
            // then push left side to stack
            if ( p-1 > l )
            {
                stack[ ++top ] = l;
                stack[ ++top ] = p - 1;
            }

            // If there are elements on right side of pivot,
            // then push right side to stack
            if ( p+1 < h )
            {
                stack[ ++top ] = p + 1;
                stack[ ++top ] = h;
            }
        }
    }










//    console.log(rootModel,sourceModel,queryTerm)
    if(rootModel && sourceModel && queryTerm){
        switch(msg.type) {
            case "rowsInserted": handleRowsInserted(d.start,d.end,d.count);                          break;
            case "rowsRemoved" : handleRowsRemoved(d.start,d.end,d.count) ;                          break;
            case "rowsMoved"   : handleRowsMoved(d.start,d.end,d.startEnd,d.destinationEnd,d.count); break;
            case "dataChanged" : handleDataChanged(d.idx);                                           break;
            case "sort"        : quicksort(0,rootModel.count);                                       break;
            default            : logic.findMatches();
        }
    }

    if(rootModel.count > 0) {
//        console.time("quicksort")
        quickSortIterative(0,rootModel.count - 1);
//        console.timeEnd("quicksort")
    }




//    console.log("QUICK SORTING FROM", 0, "TO", rootModel.count)


//    if(rootModel)
//        rootModel.finishedScriptTask()
//    return true;
//    WorkerScript.sendMessage({killme:"now"})
}




