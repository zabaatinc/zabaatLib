import QtQuick 2.0
QtObject {
    //OBJECT
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
        var obj =  {}

        for(var k in mo){
            if(k !== 'objectName' &&  k !== 'objectNameChanged' && k.indexOf("__") === -1)
                obj[k] = mo[k]
        }

        return obj
    }
    function listmodelToArray(lm){
//        QQmlListModel
        var ret = []
        if(lm.toString().toLowerCase().indexOf("model") !== -1 && lm.count) {
            for(var i = 0; i < lm.count; i++){
                var modelItem = lm.get(i)
                ret.push(modelObjectToJs(modelItem))
            }
        }
        return ret;
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
        return propArr
    }
}
