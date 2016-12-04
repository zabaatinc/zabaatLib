import QtQuick 2.4
import Zabaat.Material 1.0
ZToastSimple {
    id : rootObject
    objectName : "ZToastDialog"

    property string textAccept : FAR.check
    property string textCancel : FAR.close

    property var acceptFunc : null
    property var cancelFunc : null

    property string okBtnState : rootObject.state
    property string cancelBtnState : rootObject.state

    onAttemptingDestruction : if(cancelFunc)
                                  cancelFunc()
}
