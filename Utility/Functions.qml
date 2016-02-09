import QtQuick 2.0
import "functions"
pragma Singleton
QtObject {
    property MathFunctions   math   : MathFunctions   {}
    property StringFunctions string : StringFunctions {}
    property LogicFunctions  logic  : LogicFunctions  {}
    property TimeFunctions   time   : TimeFunctions   {}
    property ObjectFunctions object : ObjectFunctions {}
    property FileFunctions   file   : FileFunctions {}
    property ListFunctions   list   : ListFunctions {}
    property XHRFunctions    xhr    : XHRFunctions {}
}
