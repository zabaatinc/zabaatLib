import Zabaat.Material 1.0
ZObject {
    objectName : "ZChip"

    property string text         : ""
    property string label        : ""
    property bool   labelIsImage : false
    property string closeButtonState : 'disabled-circle-f2'
    property string closeButtonText  : FAR.close

    signal clicked()
    signal close()

}
