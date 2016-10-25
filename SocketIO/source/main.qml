import QtQuick 2.5
import QtQuick.Controls 1.4
import Zabaat.SocketIO 1.0


ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("qmlsocketIO")

    function cb(result){
        for(var i =0; i < arguments.length; i++){
            var item = arguments[i]
            if(typeof item === 'string'){
                try {
                    var val = JSON.parse(item)
                    console.log(i, val, JSON.stringify(val,null,2))
                }
                catch(e){
                    console.log(i, item)
                }
            }


        }
    }


    ZSocketIO {
        id : sio
        onIsConnectedChanged : console.log(isConnected, details);
        onServerResponse     : console.log("Server Response" , value, JSON.stringify(value,null,2))
        registeredEvents     : ["message","user"]

        Component.onCompleted: sio.reconnectLimit = 5;
    }





//    Text {
//        anchors.centerIn: parent
//        text : sio.sessionId
//    }

    TextInput {
        id : urlInput
        text : "/admin/echo"
        anchors.centerIn: parent
        font.pixelSize: 32
    }

    Row {
        width : parent.width * 0.25
        height : parent.height * 0.5
        anchors.bottom: parent.bottom

        function doSend(){
            //(QString url, QString params = JS, QString headers = JS)
            console.log("doSend")
            sio.sailsGet(urlInput.text, {text:ti.text} , cb)
        }

        Rectangle {
            height : parent.height
            width : parent.width/2
            border.width: 1
            TextInput {
                id : ti
                anchors.fill: parent
                onAccepted: parent.parent.doSend()
            }

            Button {
                anchors.bottom: parent.bottom
                onClicked:  parent.parent.doSend()
            }
        }
        Rectangle {
            height : parent.height
            width : parent.width/2
            border.width: 1
            Text {
                anchors.fill: parent
            }
        }
    }



    property string serverAddr : "127.0.0.1"  // "192.168.1.102"
    Column {
        anchors.right: parent.right
        Button {
            onClicked: sio.connect("ws://" + serverAddr + ":1337", {__sails_io_sdk_version : "1.2.0" })
            text : "connect to local echo server"
        }
        Button {
            //shrimphouse.archwingstudios.com:1337

            onClicked: sio.connect("ws://192.168.0.85:1337" , {__sails_io_sdk_version : "1.2.0" })
            text : "connect to shrimphouse"
        }
        Button {
            text : "derp"
            onClicked : {
                 sio.sailsGet("/admin/" + text, null , cb)
            }
        }
        Button {
            text : "echo"
            onClicked : {
                 sio.sailsGet("/admin/" + text, null , cb)
            }
        }
        Button {
            text : "timestampStream"
            onClicked : {
                 sio.sailsGet("/admin/" + text, null , cb)
            }
        }
        Button {
            text : "whoAmI"
            onClicked : {
                 sio.sailsGet("/admin/" + text, null , cb)
            }
        }
        Button {
            text : "query"
            onClicked : {
                 sio.sailsGet("/admin/" + text, null , cb)
            }
        }


        Button {
            text : "userSubTest"
            onClicked : {
                 sio.sailsGet("/admin/" + text, null , cb)
            }
        }



        Button {
            onClicked: sio.disconnect();
            text : "disconnect"
        }
    }


    Row {



        Button {
            text : "TEST ARRAY"
            onClicked : {
                var arr = [0,1,2]
                sio.test2(arr);
            }
        }

        Button {
            text : "TEST Object"
            onClicked : {
                var obj = { firstName : "Shahan", lastName : "Kazi", titles : ["Wolf","Wolfy"] }
                sio.test2(obj);
            }
        }

        Column {
            Text {
                text : "isReconnecting:" +sio.reconnecting
            }
            Text {
                text : "attempted reconnects:" +sio.attemptedReconnects
            }
            Text {
                text : "dc time:" +  sio.disconnectedTime
            }
        }


    }


}
