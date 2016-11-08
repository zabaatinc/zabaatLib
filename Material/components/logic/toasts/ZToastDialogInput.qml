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
    property string textboxState   : "standard-f3-b1"

    onAttemptingDestruction : if(cancelFunc)
                                  cancelFunc()
}
