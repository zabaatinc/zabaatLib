import QtQuick 2.4
import Zabaat.Misc.Global 1.0
Item {
    id : rootObject
    //Feed it an array of QML objects nad it will keep checking them for ready
    property var     objectList : null
    property bool    autoInit   : true
    property var     checkKey   : "status" //string or array is acceptable
    property var  acceptReadyVal: Component.Ready
    property alias   timer      : checker.interval

    signal allReady()
//    onAllReady: console.log("******-----> ALL ARE READY ****<---- ")

    Timer {
        id : checker
        interval : 200
        repeat : true
        running : autoInit && objectList !== null
        onTriggered : if(functions.check()) { rootObject.allReady() ; stop() }
    }
    QtObject {
        id : functions
        property var objectListType        : ""
        property var checkKeyType          : ""
        property var acceptReadyValType    : ""

        function check(){
            objectListType     = ZGlobal.functions.getType(objectList)
            checkKeyType       = ZGlobal.functions.getType(checkKey)
            acceptReadyValType = ZGlobal.functions.getType(acceptReadyVal)

            if(objectList && objectListType === "array"){
                for(var a = 0; a < objectList.length; a++){
                    var obj = objectList[a]
                    if(ZGlobal.functions.isDef(obj)){
                        var key            = checkKeyType       === "string" ? checkKey : checkKey[a]
                        var val            = acceptReadyValType !== "array"  ? acceptReadyVal : acceptReadyVal[a]
//                        console.log("checking", key, ":", obj[key], " === ", val, " = ", obj[key] === val)
                        if(obj[key] !== val)
                            return false
                    }
                }

                return true
            }
            return false
        }
    }

    function begin() {
        checker.running = true
    }


}

