import QtQuick 2.0
import Zabaat.Utility 1.0
import QtQuick.Controls 1.4
Rectangle {
    color : 'darkGray'

    Component.onCompleted: {
        cl.cache(Qt.resolvedUrl("CachedLoader/RoundedSquare.qml"))
        cl.cache(circle);
        cl.cache(square);
    }

    function randColor() {
        return Qt.rgba(Math.random(), Math.random(), Math.random())
    }


    Column {
        Row {
            Button{ text : "Square"               ; onClicked : cl.doLoad(square, {color : randColor() } ) }
            Button{ text : "Circle"               ; onClicked : cl.doLoad(circle, {color : randColor() } ) }
            Button{ text : "RoundedSquare"        ; onClicked : cl.doLoad(Qt.resolvedUrl("CachedLoader/RoundedSquare.qml"), {color : randColor() } ) }
            Button{ text : "RoundedSquareUncached"; onClicked :  cl.doLoad(Qt.resolvedUrl("CachedLoader/RoundedSquareUncached.qml"), {color : randColor() } ) }
        }
        Row {
            Button{ text : "Square"               ; onClicked : cl.doLoad(square, {color : randColor() } ,true ) }
            Button{ text : "Circle"               ; onClicked : cl.doLoad(circle, {color : randColor() } ,true) }
            Button{ text : "RoundedSquare"        ; onClicked : cl.doLoad(Qt.resolvedUrl("CachedLoader/RoundedSquare.qml"), {color : randColor() } ,true) }
            Button{ text : "RoundedSquareUncached"; onClicked :  cl.doLoad(Qt.resolvedUrl("CachedLoader/RoundedSquareUncached.qml"), {color : randColor() } ,true) }
        }
    }



    CachedLoader {
        id : cl
        anchors.centerIn: parent
        width : parent.width/2
        height : parent.height/2

        Text {
            anchors.centerIn: parent
            text : "source:"             + cl.source           + "\n" +
                   "sourceComponent:"    + cl.sourceComponent  + "\n" +
                   "asynchronous:"       + cl.asynchronous     + "\n" +
                   "active:"             + cl.active           + "\n" +
                   "item:"               + cl.item             + "\n" +
                   "status:"             + cl.status           + "\n" +
                   "progress:"           + cl.progress
        }

    }


    Component { id : circle; Rectangle { radius : height/2; border.width: 1; NumberAnimation on opacity { from : 0; to : 1; duration : 1000; running : true; }}}
    Component { id : square; Rectangle { border.width: 1                   ; NumberAnimation on opacity { from : 0; to : 1; duration : 1000; running : true; }}}


}
