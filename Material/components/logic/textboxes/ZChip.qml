import Zabaat.Material 1.0
ZObject {
    id : rootObject
    objectName : "ZChip"

    property string text             : ""
    property string label            : ""
    property bool   labelIsImage     : false
    property string closeButtonState : 'danger-circle-f2'
    property string closeButtonText  : FAR.close
    property real implicitWidth : height * 1.5
    property real maxWidth      : Number.MAX_VALUE
    signal clicked()
    signal close()

    disableShowsGraphically: true;

    function setColor(color) {
        return skinFunc(arguments.callee.name, {color:color})
    }

}
