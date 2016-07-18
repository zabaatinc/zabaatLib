import QtQuick 2.5
import Zabaat.Auth 1.0
import Zabaat.Utility 1.0
Item {


    Facebook {
        id : fb
        anchors.centerIn: parent
        width : parent.width
        height : parent.height
        input.appId        : "1587909424854598"
        input.readyFlag: true
        onAppCodeReceived: {
            console.log("APP CODE RECEIVED:", code);
        }

        ZTracer {

        }
    }






}
