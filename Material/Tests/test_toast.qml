import Zabaat.Material 1.0
import QtQuick 2.5
import QtQuick.Window 2.2

Item {
    Column {
        anchors.right: parent.right
        Text { text : "Toasts.count:" + Toasts.count   }
        Text {
            text : "json:" + Toasts.json
        }
    }


    Column {
        anchors.fill: parent
        spacing : parent.height * 0.1
        property int h : parent.height/3 - (spacing * 3)

        ZTextBox {
            width : parent.width/4
            height : parent.h
            label : "Normal Toast"
            onAccepted : Toasts.create(text,{title:label},null,0.5,0.25)
        }

        ZTextBox {
            width : parent.width/4
            height : parent.h
            label : "Blocking Toast"
            onAccepted : Toasts.createBlocking(text,{title:label});
        }

        ZTextBox {
            width : parent.width/4
            height : parent.h
            label : "Permanent Toast"
            onAccepted : Toasts.createPermanent(text,{title:label});
        }

        ZTextBox {
            width : parent.width/4
            height : parent.h
            label : "Permanent Blocking Toast"
            onAccepted : Toasts.createPermanentBlocking(text,{title:label});
        }

        ZTextBox {
            width : parent.width/4
            height : parent.h
            label : "Error Toast"
            onAccepted : Toasts.error(text, "NOES")
        }

        ZTextBox {
            width : parent.width/4
            height : parent.h
            label : "Error Toast"
            onAccepted : Toasts.error({derp:"happened too many times",slurp:"sometimes rhymes"}, "NOES")
        }


    }


    Window {
        width : 640
        height : 480
        visible : true
        Component.onCompleted: WindowManager.registerWindow(this);


        ZTextBox {
            width : parent.width/4
            height : parent.height/3
            label : "Normal Toast"
            onAccepted : Toasts.create(text,{title:label},null,0.5,0.25)
            anchors.centerIn: parent
        }
    }

}
