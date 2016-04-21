import QtQuick 2.4
import Zabaat.Material 1.0
ZToastSimple {
    id : rootObject
    objectName : "ZToastDialogInput"

    property string answer     : ""
    property string textAccept : "Ok"
    property string textCancel : "Cancel"
    property string label      : ""

    property var acceptFunc : null
    property var cancelFunc : null
    property var focusFunc  : null
    property string okBtnState     : rootObject.state
    property string cancelBtnState : rootObject.state

    onAttemptingDestruction : if(cancelFunc)
                                  cancelFunc()
}
