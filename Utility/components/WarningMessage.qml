import QtQuick 2.4
import QtQuick.Controls 1.4
FocusScope {
    id : rootObject
    width: 100
    height: 62

    signal ok(string memo)
    signal cancel()

    property alias title    : titleMessage.text
    property alias message  : details.text
    property alias memo     : memo.text
    property int cellHeight : height / 5
    property double animDuration : 60000 / 12
    property alias okBtn : btnOk
    property alias cancelBtn : btnCancel
    property bool   requireMemo : true
    property int    memoLenRequirement : 15


    ZTracer{
        id : iconContainer
        width : icon.width
        height : icon.paintedHeight
        anchors.fill: null

        border.color : "black"
        border.width: 0

        Text {
            id : icon
            font.pointSize: cellHeight * 3
            text : "!"
            height : cellHeight * 3
        }
    }
    ZTracer {
        id : titleContainer
        width : parent.width - iconContainer.width
        height : cellHeight
        anchors.left: iconContainer.right
        anchors.fill: null

        border.color   : "black"
//        color : ZGlobal.style.danger

        Text {
            id : titleMessage
            anchors.centerIn: parent
            font.pointSize: cellHeight / 2
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text : "YOU ARE A HERPING DERP"
            color : "black"
        }

        MouseArea {
            anchors.fill: titleContainer
            drag.target: rootObject
        }

    }


    ZTracer {
        id: detailsContainer
        anchors.fill: null
        anchors.left: iconContainer.right
        anchors.top: titleContainer.bottom
        width : titleContainer.width
        height : requireMemo ? (iconContainer.height - titleContainer.height) * 0.75 : (iconContainer.height - titleContainer.height)
        border.color : 'black'
//        color : Qt.darker(ZGlobal.style._default)

        Text {
            id : details
            width : parent.width * 0.90
            height : parent.height * 0.95
            anchors.centerIn: parent
//            Component.onCompleted: ZGlobal.functions.fitToParent_Snug(this)
            text : "there was once a man upon the road his brain was squirming like a toad and he didnt know what to do"
            font.pointSize: cellHeight / 4
            enabled: false
            wrapMode : Text.WrapAnywhere
//            color : ZGlobal.style.text.color2
        }
    }
    ZTracer {
        id: memoContainer
        anchors.fill: null
        anchors.left: iconContainer.right
        anchors.top: detailsContainer.bottom

        width : titleContainer.width
        height : requireMemo ? (iconContainer.height - titleContainer.height) * 0.25 : 0
        border.color : 'black'
//        color : ZGlobal.style.text.color2
        clip : true
        visible: requireMemo

        TextInput {
            id : memo
            text : "Memo..."
            font.pointSize: cellHeight / 4
            wrapMode : Text.NoWrap
//            color : ZGlobal.style.text.color1
            width  : parent.width
            height : parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            onFocusChanged: if(focus){
                                if(text === "Memo...")
                                    text = ""
                            }
            activeFocusOnTab : true

        }
    }


    Item {
        id : btnContainer
        width : parent.width - iconContainer.width
        height : cellHeight
        anchors.left: titleContainer.left
        anchors.top: memoContainer.bottom
        anchors.topMargin: 5

        Button {
            id : btnCancel
            text : "Cancel"
            height : parent.height
            width : parent.width * 0.75
            anchors.left: parent.left
            activeFocusOnTab : true
        }
        Button {
            id : btnOk
            text : "Ok"
            enabled : !requireMemo ?  true : memo.text.length > memoLenRequirement ? true : false
            height : cellHeight
            width : parent.width * 0.22
            anchors.right: parent.right
            activeFocusOnTab : true
            onClicked: rootObject.ok(memo.text)
        }
    }


    Keys.onEscapePressed: rootObject.cancel()



}

