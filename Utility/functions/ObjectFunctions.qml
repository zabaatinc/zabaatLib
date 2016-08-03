import QtQuick 2.0

QtObject {
    id : rootObject
    objectName : "ObjectFunctions"
    //OBJECT
    function clone(obj) {
        return JSON.parse(JSON.stringify(obj))
    }
    function keys(obj, exclude){
        return getProperties(obj, exclude);
    }
    function values(obj, exclude){
        function indexOf(array,item){
            var i = 0, length = array && array.length;
            for (; i < length; i++)
                if (array[i] === item) return i;
            return -1;
        }

        var vals =  []
        if(obj !== null && typeof obj !== 'undefined'){

            for(var v in obj){
                if(!isUndef(exclude) && !isUndef(exclude.length) &&  exclude.length > 0)
                {
                    if(indexOf(exclude,v) === -1)
                        vals.push(obj[v])
                }
                else
                    vals.push(obj[v])

            }

        }
        console.log("RETURNING" , vals)
        return vals;
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


    function deepSet(obj, propStr, value) {
        var success = true;
        var isFunc  = typeof value === 'function'

        if(isUndef(obj, propStr))
            return false

        if(!propStr) {
            try {
                obj = isFunc ? Qt.binding(value) : value
            }catch(e) {
                success = false;
                console.log(rootObject, e, "unable to set", obj, 'to', value)
            }
            return success
        }

//            console.log(propStr)
        var propStrType = toString.call(propStr)
        var propArray = propStrType === '[object String]' ? propertyStringToArray(propStr) :
                                        '[object Array]'  ? propStr : null;

        var currentPropsWalked = ""
        if(isDef(obj,propArray)){
            //iterate!!
            var objPtr = obj
            for(var p = 0; p < propArray.length; ++p){
                var prop = propArray[p]
                var isLastIteration = p === propArray.length -1
                currentPropsWalked += currentPropsWalked === "" ? prop : "." + prop


                if(isDef(objPtr[prop])){
                    if(!isLastIteration){
                        objPtr = objPtr[prop]
                    }
                    else {

                        try {
                            objPtr[prop] = isFunc ? Qt.binding(value) : value
                        }catch(e) {
                            console.log(rootObject, e, "unable to set", obj , ".", currentPropsWalked, 'to', value)
                            success = false;
                        }
                        return success;
                    }
                }
                else {
                    //this property doesnt exist, we should create it!!
                    //first let's determine if it's creatable. We must be inside an array or object!
                    if(typeof objPtr === 'object'){ //should work for array as well, will create undefines in the middle

                        if(!isLastIteration) {
                            //read the property name, if its a number, kind of assume that it's array?
                            objPtr[prop] = { }
                            objPtr = objPtr[prop]
                        }
                        else {
                            try {
                                objPtr[prop] = isFunc ? Qt.binding(value) : value
                            }catch(e) {
                                console.log(rootObject, e, "unable to set", obj , ".", currentPropsWalked, 'to', value)
                                success = false;
                            }
                            return success;
                        }
                    }
                    else {
                        console.error("Cannot create new property at" , currentPropsWalked)
                        return false;
                    }
                }
            }
            return objPtr


        }
        else
            return false
    }
    function deepGet(obj, propStr){
        if(isUndef(obj, propStr))
            return undefined

        if(propStr === "")
            return obj

        var propStrType = toString.call(propStr)
        var propArray = propStrType === '[object String]' ? propertyStringToArray(propStr) :
                                        '[object Array]'  ? propStr : null;

        if(isDef(obj,propArray)){
            //iterate!!
            var objPtr = obj
            for(var p in propArray){
                var prop = propArray[p]
                if(isDef(objPtr[prop])){
                    objPtr = objPtr[prop]
                }
                else
                    return undefined
            }
            return objPtr
        }
        else
            return undefined
    }

    //turn this into a nice array that we can just walk over!!
    //[1]foo.bar[0].green[0]
    function propertyStringToArray(propStr){
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
                }
                propStr = propStr.replace(propStr.slice(startIdx, endIdx +1)  , "@")
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
        return propStr; //at this poiint its an array!
    }

    function has(obj, propStr){
       if(isDef(deepGet(obj,propStr)))
           return true
       return false
    }
    function getNewObject(name,parent){
        var cmp = Qt.createComponent(name)
        if(cmp.status !== Component.Ready)
            console.error("Zabaat.Utility.Functions.getNewObject", name,cmp.errorString())
        return cmp.createObject(parent)
    }
    function getQmlObject(imports,qmlStr,parent) {
        var str = ""
        if(typeof imports !== 'string')
        {
            for(var i in imports)
                str += "import " + imports[i] + ";\n"
        }
        else
            str = "import " + imports + ";"

        var obj = Qt.createQmlObject(str + qmlStr,parent,null)
        return obj
    }
    function clearChildren(obj){
        if(obj && typeof obj.children !== 'undefined'){
            for(var i = obj.children.length - 1; i > -1; i--){
                var child = obj.children[i]
                child.parent = null
                child.destroy()
            }
        }
    }
    function modelObjectToJs(mo){
//        console.log(mo)
        function or(val){
            if(arguments.length > 1){
                for(var i = 1 ; i < arguments.length; ++i){
                    if(val === arguments[i])
                        return true;
                }
            }
            return false
        }

        var obj =  {}
        for(var k in mo){
            if(or(k.toLowerCase(), "objectname","objectnamechanged") || k.indexOf("__") === 0 )
                continue

            var val     = mo[k]
            var type    = typeof val
            var typeStr = val ? val.toString().toLowerCase() : null
//                    console.log(k, val ,type,typeStr)
            if(or(type,"string","number","date","bool","boolean"))
                obj[k] = val;
            else if(typeStr === null)
                obj[k] = null;
            else if(typeStr.indexOf("listmodel") !== -1 || typeStr.indexOf("proxymodel") !== -1)
                obj[k] = listmodelToArray(val)
//                    }
            else
                obj[k] = clone(val)
        }

        return obj
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

    function listmodelToArray(lm){

        function or(val){
            if(arguments.length > 1){
                for(var i = 1 ; i < arguments.length; ++i){
                    if(val === arguments[i])
                        return true;
                }
            }
            return false
        }

        var arr = []
        if(!lm)
            return 0;

        for(var i = 0; i < lm.count; ++i){
            var item = lm.get(i)
            var type = typeof item

            if(type === 'string' || type === 'number' || type === 'date' || type === "bool" || type === "boolean") {
                arr.push(item)
            }
            else {  //is an object?
//                console.log("objecttype =", item.toString().toLowerCase())
//                if(item.toString().toLowerCase().indexOf("rolemodelnode") !== -1) {
//                    for(var k in item)
//                        console.log(k, item[k])
//                }

                var obj = {};
                for(var k in item){
                    //exclude objectname
                    var ex = k.toLowerCase()
                    if(or(ex, "objectname","objectnamechanged") || ex.indexOf("__") === 0 )
                        continue

                    var val = item[k]
                    if(isUndef(val)){
//                        console.log(rootObject, k, "is", val , type)
                        continue
                    }

                    var type2   = typeof val
                    var typeStr = val.toString().toLowerCase()
//                    console.log(k, val ,type,typeStr)
                    if(or(type2,"string","number","date","bool","boolean"))
                        obj[k] = val;
                    else if(typeStr.indexOf("listmodel") !== -1 || typeStr.indexOf("proxymodel") !== -1)
                        obj[k] = listmodelToArray(val)
//                    }
                    else
                        obj[k] = clone(val)
//                    }

                }
                arr.push(obj)
            }
        }
        return arr;
    }

    function isArray(obj){
        return toString.call(obj) === '[object Array]';
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


}
