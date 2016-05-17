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
        spacing : h/3
        property int h : 32

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

        ZTextBox {
            width : parent.width/4
            height : parent.h
            label : "Error Toast"
            onAccepted : Toasts.dialog("Herpitudes", "Please tell me if your herpled today" , function(){ console.log("accept")} ,
                                                                                      function(){ console.log("decline")})
        }

        ZTextBox {
            width : parent.width/4
            height : parent.h
            label : "Error Toast"
            onAccepted : Toasts.dialogWithInput("QUESTION", "What is your name" , function(a){ console.log("accept",a)} ,
                                                                                      function(){ console.log("decline")} ,
                                                                                      {state : 'warning', label : "answer", focusFunc : function(){console.log("I FOCUS") }  })
//            Component.onCompleted: forceActiveFocus()
        }



        ZTextBox {
            width : parent.width/4
            height : parent.h
            label : "List toast"
            onAccepted : Toasts.listOptions("List",  lm, function(a){ console.log("accept",JSON.stringify(a))} ,
                                                                        function(){ console.log("decline")} ,
                                                                        {state : 'warning', label : "answer", focusFunc : function(){console.log("I FOCUS") }  })
//            Component.onCompleted: forceActiveFocus()
        }

        ZTextBox {
            width : parent.width/4
            height : parent.h
            label : "List toast"
            onAccepted : Toasts.listOptions("List", lm, function(a){ console.log("accept",JSON.stringify(a))} ,
                                                                        function(){ console.log("decline")} ,
                                                                        { columns: 2 })
            Component.onCompleted: forceActiveFocus()
        }


    }


    ListModel {
        id : lm
        ListElement { name : "red" }
        ListElement { name : "blue" }
        ListElement { name : "green" }
        ListElement { name : "purple" }
        ListElement { name : "black" }
        ListElement { name : "white" }
        ListElement { name : "raindbow" }
        ListElement { name : "silver" }
        ListElement { name : "gold" }
        ListElement { name : "magenta" }
        ListElement { name : "fuschia" }
    }

//    Window {
//        width : 640
//        height : 480
//        visible : true
//        Component.onCompleted: WindowManager.registerWindow(this);


//        ZTextBox {
//            width : parent.width/4
//            height : parent.height/3
//            label : "Normal Toast"
//            onAccepted : Toasts.create(text,{title:label},null,0.5,0.25)
//            anchors.centerIn: parent
//        }
//    }

}
