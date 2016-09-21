import QtQuick 2.4
import Zabaat.Material 1.0
ZToastSimple{
    id : rootObject
    objectName : "ZToastError"

    //additional properties for error
    property var       err : null

    property string    filterButtonState         : "default-f3-b1"
    property string    filterButtonStateSelected : "danger-f3-b1"

    property ListModel stackModel       : ListModel { id: stackModel;       dynamicRoles : true }
    property ListModel serverStackModel : ListModel { id: serverStackModel; dynamicRoles : true }
    property ListModel errorModel       : ListModel { id: errorModel;       dynamicRoles : true }

    property var saveFunc               : Toasts.logFunc        //provide this if you want to be able to write!

    property alias logic : logic
    QtObject {
        id : logic
        function prettyTrace(stack){
            var c = []
            for(var s = 0; s < stack.length; ++s){
                var line = stack[s]

                var a = line.split("@")
                console.log(JSON.stringify(line,null,2), JSON.stringify(a,null,2))
                if(a.length >= 2) {
                    var name = a[0]

                    a = a[1].split(":")

                    var lineNum = a[a.length-1]
                    var fileName = a[a.length-2]

                    if(name === "")
                        name = "(anonymous)"

                    c.push({fn:name,line:lineNum,file:fileName})
                }
                else{
                    c.push({fn:"unknown",line:line,file:""})
                }




            }
//            console.log(JSON.stringify(c,null,2))
            return c
        }
        function updateStackModel(stack){
            stackModel.clear()
            stackModel.append(prettyTrace(stack))
        }

        function prettyError(err){
            if(err){
                var arr = []
                var type = helpers.getType(err)
                if(type === "array"){
                    for(var a  = 0; a < err.length; ++a){
                        var errLine = err[a]
                        arr.push({key:a,data:JSON.stringify(errLine,null,2) })
                    }
                }
                else if(type.indexOf("model") !== -1){
                    for(a  = 0; a < err.count; ++a){
                        errLine = err.get(a)
                        arr.push({key:a,data:JSON.stringify(errLine,null,2) })
                    }
                }
                else if(type === "object"){
                    for(a in err){
                        if(a === 'serverStack')
                            continue

                        errLine = err[a]
                        arr.push({key:a,data:JSON.stringify(errLine,null,2) })
                    }
                }
                else if(err !== null && err !== 'undefined'){
                    arr.push({key:"message",data:err})
                }
                return arr
            }
            return null;
        }
        function updateErrorModel(){
            errorModel.clear()
            var obj = prettyError(err)
            if(obj)
                errorModel.append(obj)
        }
        function updateServerStackModel(serverStack){
            serverStackModel.clear()
            var obj = prettyError(serverStack)
            if(obj)
                serverStackModel.append(obj)
        }

        function doUpdate(stack, serverStack){
            updateErrorModel()
            updateServerStackModel(serverStack)
            updateStackModel(stack)
        }

        function toJSON(){
            function listmodelToArray(lm){
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
                    if(type === 'string' || type === 'number' || type === 'date')
                        arr.push(item)
                    else {
                        var obj = {};
                        for(var k in item){
                            //exclude objectname
                            var ex = k.toLowerCase()
                            if(or(ex, "objectname","objectnamechanged") || ex.indexOf("__") === 0 )
                                continue

                            var val     = item[k]
                            if(isUndef(val)){
                                console.log(k, "is", val)
                                continue
                            }

                            type        = typeof val
                            var typeStr = val.toString().toLowerCase()
        //                    console.log(k, val ,type,typeStr)
                            if(or(type,"string","number","date","bool","boolean"))
                                obj[k] = val;
                            else if(typeStr.indexOf("listmodel") !== -1 || typeStr.indexOf("proxymodel") !== -1)
                                obj[k] = listmodelToArray(val)
        //                    }
                            else
                                obj[k] = Lodash.clone(val)
        //                    }

                        }
                        arr.push(obj)
                    }
                }
                return arr;
            }

            return JSON.stringify( {
                     date       : Qt.formatDateTime(new Date()).toString(),
                     err        : listmodelToArray(errorModel),
                     stack      : listmodelToArray(stackModel),
                     serverStack:listmodelToArray(serverStackModel)
                   } , null , 2)
        }


        property QtObject helpers : QtObject {
            id: helpers
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
    }


    onErrChanged: if(err) {
                      var stack = err.stack
                      if(!stack){
                          var e     = new Error('dummy')
                          var ss = e.stack.toString().split("\n")
                          ss.splice(0,4)   //just cause we want to get to the useful stuff and not the stuff that generated this error!
                          stack = ss;
                      }
                      logic.doUpdate(stack, err.serverStack)
                      if(Toasts.alwaysLog && saveFunc){
                          saveFunc(logic.toJSON())
                      }
                  }







}
