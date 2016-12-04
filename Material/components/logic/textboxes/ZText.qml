import Zabaat.Material 1.0
ZObject {
    id : rootObject
    objectName: "ZText"

    property string text : ""

    function paintedWidth() { return skinFunc(arguments.callee.name) }
    function paintedHeight() { return skinFunc(arguments.callee.name) }
}

