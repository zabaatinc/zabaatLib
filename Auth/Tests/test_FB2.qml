import QtQuick 2.5
import Zabaat.Auth 1.0
import Zabaat.Utility 1.0
Item {


    Facebook {
        anchors.centerIn: parent
        width : parent.width
        height : parent.height
        appId        : "1587909424854598"
        appSecret    : "6aa74dc057a670a8300f49691cea248a"   //is used to make session long lived?
        redirect_url : "http://studiiio.global:1337/auth/facebook"
        ZTracer {}
    }



}
