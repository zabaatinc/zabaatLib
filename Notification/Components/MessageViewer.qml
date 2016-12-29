import QtQuick 2.5
import Zabaat.Base 1.0
ListView {
    id : rootObject
    interactive: contentHeight > height;
    spacing : styleSettings ? rootObject.height *  styleSettings.messageSpacing : 20;
    property var styleSettings
    property real fontSize : -1
    property real minMsgHeight : styleSettings ? height * styleSettings.messageHeight :
                                                 height * 0.15

    cacheBuffer: rootObject.height

    delegate: Item {
        id : delText
        visible: styleSettings && fontSize > 0 ? true : false ;
        width  : rootObject.width
        height : timeContainer.height + msgDisplay.height + 10


        property var    m        : model
        property string msg      : m && m.msg  ? m.msg                     : "??";
        property string date     : m && m.time ? Qt.formatDateTime(m.time) : "??";
        property color  txColor  : styleSettings ? styleSettings.text1 : "black";
        property color  timeColor: styleSettings ? styleSettings.text2 : "white";
        property var    seen     : m  ? m.seen : null;

        function seenFunc() {
            rootObject.model.get(index).seen = true;
        }

        Component.onCompleted: if(visible && seen === false) {
                                   Functions.time.setTimeOut(10, seenFunc)
                               }
        onVisibleChanged: if(visible && seen === false)
                              Functions.time.setTimeOut(10, seenFunc)

        Rectangle {
            id : timeContainer
            color : styleSettings ? styleSettings.success : "blue";
            anchors.fill: timeDisplay
            anchors.margins: -5
            radius : width / 24
            border.width: 1
            border.color: timeDisplay.color

            Text {
                anchors.left: parent.right
                anchors.leftMargin: 5
                font.family : styleSettings ? styleSettings.font : 'Arial'
                text : styleSettings && delText.seen ? styleSettings.seenStr : "";
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: rootObject.fontSize > 0 ? rootObject.fontSize : 10
                textFormat: Text.RichText;  //so we can use FontAwesome or some other font here.
            }
        }


        Text {
            id : timeDisplay
            font.family   : styleSettings ? styleSettings.font : 'Arial'
            font.pixelSize: rootObject.fontSize > 0 ? rootObject.fontSize : 10
            anchors.left: parent.left
            anchors.leftMargin: 5
            text : delText.date
            color : delText.timeColor
        }

        Rectangle {
            anchors.fill: msgDisplay
            color  : styleSettings ? styleSettings.standard : "white";
            border.width: 1
            border.color: "#CCCCCC"
            anchors.margins: -5
//            radius : height / 8
        }

        Text {
            id : msgDisplay
            font.family   : styleSettings ? styleSettings.font : 'Arial'
            font.pixelSize: rootObject.fontSize > 0 ? rootObject.fontSize : 10
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.top: timeContainer.bottom
            anchors.topMargin: 5
            wrapMode: Text.WordWrap
            text : delText.msg
            color : delText.txColor
        }



    }

}
