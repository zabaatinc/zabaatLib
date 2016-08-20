import QtQuick 2.5
import QtQuick.Controls 1.4
Item {
    id : rootObject
    property var m
    property string path : m ? m.path : ""
    property string type : m ? m.type : ""

    SimpleButton {
        id : titleBar
        width : parent.width
        height : parent.height * 0.1
        visible : m ? true : false
        color : type === 'create' ? Qt.rgba(0,1,0.5) :
                                    type === 'update' ? Qt.rgba(0,0.5,1) : Qt.rgba(1,0.1,0);
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


        ScrollView {
            id : createView
            width : parent.width
            height : visible ? parent.height - viewPath.height : 0
//            property var d : m ? m.data : null
//            property string dStr : typeof d === 'object' ? JSON.stringify(d,null,2) : d ? d : ""
            property string dStr : m ? m.data : ""
            visible : type === 'create'
            Text {
                text : createView.dStr
                width : parent.width
                height : parent.height
                font.pixelSize: 14
            }
        }

        SplitView {
            id : updateView
            width : parent.width
            height : visible ? parent.height - viewPath.height : 0
//            property var d : m ? m.data : null
//            property var od : m ? m.oldData : null
//            property string dStr  : typeof d === 'object'  ? JSON.stringify(d,null,2)  : d  ? d  : ""
//            property string odStr : typeof od === 'object' ? JSON.stringify(od,null,2) : od ? od : ""

            property string dStr  : m && m.data    ? m.data    : ""
            property string odStr : m && m.oldData ? m.oldData : ""

            visible : type === 'update'
            Column {
                id : oldDataColumn
                width : parent.width/2
                height : parent.height
                SimpleButton {
                    text : "old"
                    width : parent.width
                    height : parent.height * 0.1
                }
                ScrollView {
                    width : parent.width
                    height : parent.height * 0.9
                    Text {
                        text : updateView.odStr
                        width : parent.width
                        height : parent.height
                        font.pixelSize: 14
                    }
                }
            }
            Column {
                id : newDataColumn
                width : parent.width/2
                height : parent.height
                SimpleButton {
                    text : "new"
                    width : parent.width
                    height : parent.height * 0.1
                }
                ScrollView {
                    width : parent.width
                    height : parent.height * 0.9
                    Text {
                        text : updateView.dStr
                        width : parent.width
                        height : parent.height
                        font.pixelSize: 14
                    }
                }
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
