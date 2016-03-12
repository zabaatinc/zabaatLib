import Zabaat.Material 1.0
import QtQuick 2.5
Item {

    Column {
        anchors.fill: parent
        spacing : parent.height * 0.1
        property int h : parent.height/3 - (spacing * 2)

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
    }


}
