//A little different, this is supposed to be loaded into ZComponentToast
import QtQuick 2.5
import Zabaat.Material 1.0
import Zabaat.Base 1.0
Item  {
    id : ro
    property string state
//    height : tItem.width
//    width : tItem.height
    property real implicitWidth: tItem.width
    property real implicitHeight: tItem.height
    property alias text : tItem.text
//    signal requestDestruction();

    ZText {
        id : tItem
        property string dState : 'f10pt-paintedwidth-paintedheight'
        state : ro.state ? ro.state+"-" + dState : dState
//        Component.onCompleted: {
//            var fn = function() {
//                tItem.state = Qt.binding(function() { return ro.state ? ro.state+"-" + tItem.dState : tItem.dState})
//            }
//            Functions.time.setTimeOut(20, fn);
//        }
    }


}


