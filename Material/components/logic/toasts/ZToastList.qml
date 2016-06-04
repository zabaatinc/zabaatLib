import QtQuick 2.4
import Zabaat.Material 1.0
ZToastSimple {
    id : rootObject
    objectName : "ZToastList"

    property var model        : null   //the list!!!
    property var modelType : {
        if(model){
            if(toString.call(model) === '[object Array]')
                return "array"
            else if(typeof model === 'object'){
                if(model.toString().toLowerCase().indexOf('model') !== -1)
                    return "listmodel"
                else
                    return "object"
            }
        }
        return undefined
    }

//    property string textAccept : "Ok"
    property string textCancel     : "Cancel"
    property string label          : ""


    property var acceptFunc        : null
    property var cancelFunc        : null
    property var focusFunc         : null

    property string delegateBtnState : rootObject.state + "-b1-rounded-f3"
    property int columns : 1
//    property int rows    : -1

    onAttemptingDestruction : if(cancelFunc)
                                  cancelFunc()
}
