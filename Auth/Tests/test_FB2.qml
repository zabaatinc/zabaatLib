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
//        input.appSecret    : "6aa74dc057a670a8300f49691cea248a"   //is used to make session long lived?
        input.redirectUrl  : "http://studiiio.global:1337/auth/facebook"

//        output.onTokenChanged: console.log("TOKEN",output.token)

        ZTracer {

        }
    }

    Column {
        Text {
            text : fb.output.token

        }
    }




}
