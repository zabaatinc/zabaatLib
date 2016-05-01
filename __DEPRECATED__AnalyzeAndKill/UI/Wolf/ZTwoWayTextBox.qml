import QtQuick 2.4
import "zBaseComponents"

FocusScope {
    id : rootObject
    property bool updateValueAutomatically : true
    property bool updateValueOnFocusLost   : true

    signal accepted(string text)
    signal click()
    signal gotFocus()
    signal lostFocus()
    signal hovered()
    signal unhovered()
    signal cursorPositionChanged(int pos)

    property alias text          : displayBox.text
    property alias textInputStyle: displayBox.textInputStyle
    property alias isPassword    : displayBox.isPassword
    property alias defaultVal    : displayBox.defaultVal
    property alias inputAreaRatio: displayBox.inputAreaRatio
    property alias font          : displayBox.font
    property alias fontFamily    : displayBox.fontFamily
    property alias fontColor     : displayBox.fontColor
    property alias labelColorBg  : displayBox.labelColorBg
    property alias labelColor    : displayBox.labelColor
    property alias color         : displayBox.color
    property alias outlineColor  : displayBox.outlineColor
    property alias fontName      : displayBox.fontName
    property alias labelName     : displayBox.labelName
    property alias state         : displayBox.state
    property alias outlineVisible: displayBox.outlineVisible
    property alias haveLabelRect : displayBox.haveLabelRect
    property alias snugFit       : displayBox.snugFit
    property alias animDuration  : displayBox.animDuration
    property alias padding       : displayBox.padding
    property alias validator     : displayBox.validator
    property alias helpText      : editor.helpText

    activeFocusOnTab    : true
    onFocusChanged      : editor.focus = focus
    Keys.onEnterPressed : if(!delayFocusTimer.running) editor.focus = true
    Keys.onReturnPressed: if(!delayFocusTimer.running) editor.focus = true

    ZBase_TextBox {
        id : displayBox
        isEnabled: false
        activeFocusOnTab: false
        anchors.fill: parent
    }
    MouseArea {
        anchors.fill: parent
        onClicked   : editor.focus = true
    }
    ZBase_TextBox {
        id : editor
        anchors.fill: displayBox
        visible : focus

        //COPYING PAPA
        textInputStyle: displayBox.textInputStyle
        isPassword    : displayBox.isPassword
        defaultVal    : displayBox.defaultVal
        inputAreaRatio: displayBox.inputAreaRatio
        font          : displayBox.font
        fontFamily    : displayBox.fontFamily
        fontColor     : displayBox.fontColor
        labelColorBg  : displayBox.labelColorBg
        labelColor    : displayBox.labelColor
        color         : displayBox.color
        outlineColor  : displayBox.outlineColor
        fontName      : displayBox.fontName
        labelName     : displayBox.labelName
        state         : displayBox.state
        outlineVisible: displayBox.outlineVisible
        haveLabelRect : displayBox.haveLabelRect
        snugFit       : displayBox.snugFit
        animDuration  : displayBox.animDuration
        padding       : displayBox.padding
        validator     : displayBox.validator

        //PASSING ALONG THE SIGNALS
        activeFocusOnTab: true
        onClick     : displayBox.click()
        onGotFocus  : displayBox.gotFocus()
        onLostFocus : displayBox.lostFocus()
        onHovered   : displayBox.hovered()
        onUnhovered : displayBox.unhovered()
        onCursorPositionChanged: displayBox.cursorPositionChanged(pos)

        onAccepted     : { delayFocusTimer.start(); valChangeFunc() }
        onFocusChanged : {
            if(focus){
                editor.text = displayBox.text
                editor.dTextInput.selectAll()
            }
            else if(updateValueOnFocusLost) {
                valChangeFunc()
            }
        }

        function valChangeFunc(){
            if(text != displayBox.text){
                if(updateValueAutomatically)
                    displayBox.text = text
                parent.accepted(text)
            }
            focus = false
        }

        Keys.onEscapePressed: editor.focus = false

        ZTracer{
            color : "black"
            borderWidth: 3
            parent : editor.dInputBg
        }
    }
    Timer {
        id : delayFocusTimer
        interval: 10
        running : false
        repeat : false
    }

}






