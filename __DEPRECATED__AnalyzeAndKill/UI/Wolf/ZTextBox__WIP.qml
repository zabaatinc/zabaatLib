import QtQuick 2.5
import QtQuick.Window 2.0
Item {
    id : rootObject
    //states "", "left","right","top
    property real inputAreaRatio : 1/2

    property alias labelName     : label.text
    property alias label         : label.text

    property alias labelColorBg : labelContainer.color
    property alias labelColor   : label.color

    property alias textColor    : input.color
    property alias textColorBg  : inputContainer.color
    property alias color        : inputContainer.color

    property alias text         : input.text
    property bool  isPassword   : false

    property alias font : input.font

    property string state       : ""    //to override qt's states. dont' need TEEHEE.
    signal   accepted()




    Rectangle {
        id : inputContainer
        width         : logic.size.x
        height        : logic.size.y
        anchors.left  : rootObject.state === "right"  ? parent.left   : undefined
        anchors.top   : rootObject.state === ""       ? parent.top    : undefined
        anchors.right : rootObject.state === "left"   ? parent.right  : undefined
        anchors.bottom: rootObject.state === "top"    ? parent.bottom : undefined
        border.width: 1
        color : "transparent"
        property bool mouseWithinElipses : false

        MouseArea{  //just to grab focus!
            anchors.fill: parent
            onClicked : input.forceActiveFocus()
        }
        Text {
            id : displayText
            anchors.centerIn   : parent
            verticalAlignment  : Text.AlignVCenter
            font               : input.font
            Rectangle {
                id : cursor
                width  : 3
                height : parent.height * 0.8
                anchors.verticalCenter: parent.verticalCenter
                x           : logic.cursorPos < logic.textCutOffX ? logic.cursorPos : logic.textCutOffX
                visible     : input.activeFocus
                color       : labelColorBg
                border.width: 1

                SequentialAnimation {
                    id : scaleAnimation
                    property int duration : 200

                    NumberAnimation {
                        target: cursor; property: "scale";
                        duration: scaleAnimation.duration/2 ;
                        easing.type: Easing.InOutQuad;
                        from : 1; to : 1.4;
                    }
                    NumberAnimation {
                        target: cursor; property: "scale";
                        duration: scaleAnimation.duration/2 ;
                        easing.type: Easing.InOutQuad;
                        from : 1.4; to : 1;
                    }
                }
            }

        }
        TextInput {
            id : input
            width                : contentWidth
            height               : parent.height
            font.pointSize       : 16
            onTextChanged        : logic.textChangedFunc()
            onAccepted           : rootObject.accepted()
            opacity              : 0
            onSelectedTextChanged: logic.selectionFunc()
            activeFocusOnTab     : true
            echoMode: isPassword ? TextInput.Password : TextInput.Normal
        }

        ZButton {
            text : ""
            icon : "\uf141"
            height : parent.height
            width  : height
            visible :  logic.remaining.length > 0 && !rootObject.isPassword
            anchors.right: parent.right

            onHovered:  { inputContainer.mouseWithinElipses = true; remainingRect.refreshVisible() }
            onUnhovered:  inputContainer.mouseWithinElipses = false

        }

        Rectangle {
            id : selectionRect
            color : 'red'
            opacity : 0.5
            height : parent.height
            width : 0
        }


    }
    Rectangle {
        id : labelContainer
        width  : rootObject.state === "left" || rootObject.state === "right" ? rootObject.width  - logic.size.x : rootObject.width
        height : rootObject.state === "" || rootObject.state === "top" ? rootObject.height - logic.size.y : rootObject.height
        border.width: 1
        anchors.left  : rootObject.state === "left"  ? parent.left   : undefined
        anchors.top   : rootObject.state === "top"   ? parent.top    : undefined
        anchors.right : rootObject.state === "right" ? parent.right  : undefined
        anchors.bottom: rootObject.state === ""      ? parent.bottom : undefined

        Text {
            id : label
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment  : Text.AlignVCenter
            font : input.font
        }
    }
    Rectangle {
        id : remainingRect
        width : parent.width
        anchors.top: inputContainer.bottom  //we can cover the label. YEs WE WILL
        height : remainingText.height
        visible : false
        property int hideCounter : 0

        function refreshVisible(){
            if(!isPassword){
                visible = true
                hideCounter = 2500
            }
        }

        Text {
            id : remainingText
            width : parent.width * 0.9
            horizontalAlignment: Text.AlignHCenter
            anchors.centerIn: parent
            text : logic.remaining
            font : input.font
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
        Timer {
            id : devisibilityTimer
            interval : 100
            running  : !inputContainer.mouseWithinElipses && remainingRect.visible
            repeat : true
            onTriggered : {
                remainingRect.hideCounter -= interval
                if(remainingRect.hideCounter <= 0){
                    remainingRect.visible = false
                    stop()
                }
            }
        }
        Rectangle { anchors.fill: parent ; border.width: 1; color : 'transparent' }
    }

    QtObject {
        id : logic
        property point size: {
            if(label.text === "")
                return Qt.point(rootObject.width , rootObject.height)
            else if(rootObject.state === "left" || rootObject.state === "right"){
                return Qt.point(rootObject.width * inputAreaRatio, rootObject.height)
            }
            else if(rootObject.state === "" || rootObject.state === "top"){
                return Qt.point(rootObject.width, rootObject.height * inputAreaRatio)
            }
        }
        property string remaining : ""
        property int    textCutOffX : inputContainer.width * 0.9
        property int    cursorPos   : input.positionToRectangle(input.cursorPosition).x

        function textChangedFunc(){
            displayText.text = logic.displayFunction()
            scaleAnimation.start()
        }
        function displayFunction (){
            if(input.contentWidth > textCutOffX){
                var idx = input.positionAt(textCutOffX, 0 )
                if(idx !== -1) {
                    remainingRect.refreshVisible()
                    remaining = input.displayText.slice(idx)
                    return      input.displayText.substring(0,idx)
                }
            }
            remainingRect.visible = false
            remaining = ""
            return input.displayText
        }
        function selectionFunc(){
            var start = input.positionToRectangle(input.selectionStart).x
            var end   = input.positionToRectangle(input.selectionEnd).x

            selectionRect.x = start + input.mapToItem(inputContainer).x
            selectionRect.width = end - start

            console.log("SELECTION", input.selectedText, start, end - start)
        }
    }

}

