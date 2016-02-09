import QtQuick 2.4
import Zabaat.UI.Fonts 1.0
import Zabaat.UI.Wolf 1.1
import Zabaat.Misc.Global 1.0
import "."

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


    property bool   requireMemo : true
    property int    memoLenRequirement : 15


    ZTracer{
        id : iconContainer
        width : icon.width
        height : icon.paintedHeight
        anchors.fill: null

        color : "black"
        bgColor : "transparent"
        borderWidth: 0

        Text {
            id : icon
            font.family: "FontAwesome"
            font.pointSize: cellHeight * 3
            text : FontAwesome.exclamation
            height : cellHeight * 3

            SequentialAnimation on color {
                loops : Animation.Infinite
                running : true

                ColorAnimation { to: "darkRed";  duration: animDuration / 2; easing.type : Easing.OutExpo}
                ColorAnimation { to: ZGlobal.style.danger    ;  duration: animDuration / 2; easing.type : Easing.InOutCirc }
            }
        }
    }
    ZTracer {
        id : titleContainer
        width : parent.width - iconContainer.width
        height : cellHeight
        anchors.left: iconContainer.right
        anchors.fill: null

        color   : "black"
        bgColor : ZGlobal.style.danger

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
        color : 'black'
        bgColor : Qt.darker(ZGlobal.style._default)

        Text {
            id : details
            Component.onCompleted: ZGlobal.functions.fitToParent_Snug(this)
            text : "there was once a man upon the road his brain was squirming like a toad and he didnt know what to do"
            font.pointSize: cellHeight / 4
            enabled: false
            wrapMode : Text.WrapAnywhere
            color : ZGlobal.style.text.color2
        }
    }
    ZTracer {
        id: memoContainer
        anchors.fill: null
        anchors.left: iconContainer.right
        anchors.top: detailsContainer.bottom

        width : titleContainer.width
        height : requireMemo ? (iconContainer.height - titleContainer.height) * 0.25 : 0
        color : 'black'
        bgColor : ZGlobal.style.text.color2
        clip : true
        visible: requireMemo

        TextInput {
            id : memo
            text : "Memo..."
            font.pointSize: cellHeight / 4
            wrapMode : Text.NoWrap
            color : ZGlobal.style.text.color1
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

        ZButton {
            text : "Cancel"
            height : parent.height
            width : parent.width * 0.75
            anchors.left: parent.left
            defaultColor : focus ? ZGlobal.style.success : Qt.darker(ZGlobal.style.success)
            textColor : ZGlobal.style.text.color2
            activeFocusOnTab : true
            onHovered: focus = true
            onUnhovered: focus = false
            onBtnClicked: rootObject.cancel()
        }
        ZButton {
            text : ""
            enabled : !requireMemo ?  true : memo.text.length > memoLenRequirement ? true : false
            icon : FontAwesome.check
            height : cellHeight
            width : parent.width * 0.22
            anchors.right: parent.right
            defaultColor : !enabled ? ZGlobal.style._default : focus ? ZGlobal.style.danger : Qt.darker(ZGlobal.style.danger)
            textColor : ZGlobal.style.text.color2
            activeFocusOnTab : true
            onHovered: focus = true
            onUnhovered: focus = false
            onBtnClicked: rootObject.ok(memo.text)

        }
    }


    Keys.onEscapePressed: rootObject.cancel()



}

