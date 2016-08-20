import QtQuick 2.5
import QtQuick.Controls 1.4
import Zabaat.MVVM 1.0
import Zabaat.HelperTools 1.0
import Zabaat.Material 1.0
import Zabaat.Utility 1.0
Item {
    id : rootObject



    //increments numbers recursively in object !
    property string lastStr : '{ "names":[{"id":11,"val":"Shahan"}] }'
    function incNumbers(obj, i){
        i = i || 1;

        if(typeof obj !== 'object')
            return;

        for(var o in obj){
            var val = obj[o]
            var type = typeof val
            if(type === 'number')
                obj[o] += i;
            else if(type === 'object')
                incNumbers(val,i);
        }
    }

    Row {
        id : inputRow
        width : parent.width
        height : parent.height * 0.1
        ZTextBox {
            id : textbox_path
            width : parent.width * 0.2
            height : parent.height
            label : "Path"
            onAccepted : ra.get(text);
        }
        ZTextBox {
            id : textbox_set
            width : parent.width * 0.2
            height : parent.height
            label : "Data"
            onAccepted : ra.set(textbox_path.text, text);
        }
        ZButton {
            id : textbox_set_js
            width : parent.width * 0.05
            height : parent.height
            onClicked : {
                //Qt.Popup()
                Toasts.createComponentPermanentBlocking(popupCmp,null,null,0.8,0.8)
            }
            text : "js"
        }
        ZButton {
            id : textbox_set_js_dummy
            width : parent.width * 0.05
            height : parent.height
            property int dummyId : 0
            onClicked : {
                //Qt.Popup()
                var tx = textbox_path.text
                var obj = { hater:Math.random() > 0.5 ? true : false }
//                if(tx.split("/").length > 0)

                ra.set(tx, obj);
//                Toasts.createComponentPermanentBlocking(popupCmp,null,null,0.8,0.8)
            }
            text : "Dummy js"
        }

        ZButton {
            id : btn_delete
            width : parent.width * 0.2
            height : parent.height
            text : "Delete"
            onClicked : ra.del(textbox_path.text)
        }

        ZButton {
            id : btn_reset
            width : parent.width * 0.2
            height : parent.height
            text : "Reset"
            onClicked : ra.reset();
        }

        ZButton {
            id : btn_update
            width : parent.width * 0.2
            height : parent.height
            text : "runUpdate"
            onClicked : ra.runUpdate(incNumbers(ra.priv.arr));
        }



    }

    RESTFULArrayView {
        id : rav
        width : parent.width
        height : parent.height - inputRow.height
        anchors.bottom: parent.bottom
        ptr_RESTFULArray: RESTFULArray {
            id : ra
        }
    }

    Component {
        id : popupCmp
        Rectangle {
            id :popupDel
            border.width: 1
            color : "lightgray"
            signal requestDestruction()
            Rectangle {
                anchors.fill: parent
                anchors.margins: 5
                border.width: 1
                TextArea {
                    id: popupDelText
                    anchors.fill: parent
                    font.pointSize: 14
                    Component.onCompleted: {
                        forceActiveFocus()
                        text = lastStr
                    }
                    wrapMode: Text.WordWrap
                }
            }
            Row {
                anchors.right: parent.right
                anchors.top: parent.bottom
                width: childrenRect.width
                height : parent.height * 0.1
                ZButton {
                    text : "OK"
                    width : height * 2
                    height : parent.height
                    onClicked : {
                        try {
                            var obj = JSON.parse(popupDelText.text);
                            ra.set(textbox_path.text, obj);
                            lastStr = popupDelText.text
                            popupDel.requestDestruction()
                        }catch(e){
                            Toasts.create("error")
                        }
                    }
                }

                ZButton {
                    width : height * 2
                    height : parent.height
                    text : "Cancel"
                    onClicked : {
                        lastStr = popupDelText.text
                        popupDel.requestDestruction()
                    }
                }
            }
        }
    }

}
