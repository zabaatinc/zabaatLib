import QtQuick 2.5
import QtQuick.Controls 1.4
Item {
    id : rootObject
    property var m
    property string path : m && m.path ? m.path : ""
    property string type : m && m.type ? m.type : ""

    property var d : {
        switch(type) {
            case 'set'         : return m.data
            case 'get'         : return m.res
            case 'runUpdate'   : return m.data
            default            : return null
        }
    }


    SimpleButton {
        id : titleBar
        width : parent.width
        height : parent.height * 0.1
        visible : m ? true : false
        color : {
            switch(type) {
                case 'set'   : return Qt.rgba(0,1,0.5);
                case 'get'   : return Qt.rgba(1,1,0);
                case 'del'   : return Qt.rgba(1,0.1,0);
                case 'reset' : return Qt.rgba(0.2,0.2,0.2);
                default      : return Qt.rgba(0,0.5,1);
            }
        }
        text : type
        textColor : 'white'
        font.pixelSize: height * 1/2
    }
    Column {
        id : theRest
        anchors.bottom: parent.bottom
        width : parent.width
        height : parent.height - titleBar.height
        visible : m ? true : false

        SimpleButton {
            id : viewPath
            visible : path !== ""
            width : parent.width
            height : visible ? parent.height * 0.05 : 0
            font.pixelSize: height * 1/2
            text : path
        }

        //SET & GET
        ScrollView {
            id : sv
            width : parent.width
            height : visible ? parent.height - viewPath.height : 0
            visible : d ? true : false
            Text {
                text : typeof d === 'object' ? JSON.stringify(d,null,2) : d ? d : ""
                width : sv.width
                height : sv.height
                font.pixelSize: 14
            }
        }
    }


    Text {
        id : undefinedMessage
        anchors.fill: parent
        visible : !m
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text : "Nothing Selected"
        font.pixelSize : height * 1/6
    }





}
