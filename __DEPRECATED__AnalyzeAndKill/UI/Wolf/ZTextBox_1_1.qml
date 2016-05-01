import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import Zabaat.Misc.Global 1.0

FocusScope
{
    id : rootObject
    width: 217
    height: 40

    property var self : this

    signal isDying(var obj)
    signal accepted()
    Component.onDestruction: isDying(this)
//    Component.onCompleted: state = ""


    signal click()
    signal gotFocus()
    signal lostFocus()
    signal hovered()
    signal unhovered()
    signal cursorPositionChanged(int pos)
    property string defaultVal     : ""

    property real inputAreaRatio   : 2/3

    property bool   isEnabled      : true
    property alias  text           : zInput.text
    property alias  font           : zInput.font
    property alias  fontFamily     : zInput.font.family
    property color  fontColor : ZGlobal.style.text.color1
    property alias  labelColorBg   : labelRect.color
    property alias  labelColor     : label.color
    property alias  color           : inputBgk.color
    property alias  border          : inputBgk.border

    property alias  textInputStyle : zInput.inputMethodHints
    property color  outlineColor   : ZGlobal.style.accent
    property alias  dTextInput     : zInput
    property alias  dLabelRect     : labelRect
    property alias  dInputBg       : inputBgk
    property alias  dShadowBox     : shadow
//    property alias  validator       : zInput.validator
    property alias  helpText        : helperText.text

    //Get unique property values
    property var uniqueProperties : ["text","fontColor","outlineColor","font","fontName","labelName","isPassword","padding"]
    property var uniqueSignals	  : ({gotFocus:[], lostFocus:[], cursorPositionChanged:["int"] })

    property string  fontName :"FontAwesome"
    property string  labelName:"Label"
    property double labelSize : 10
    property bool isPassword: false
    property int passMaskDelay:0

    property alias outlineLeft   : lineLeft
    property alias outlineRight  : lineRight
    property alias outlineBottom : line
    property bool   outlineVisible : false
    property bool   haveLabelRect : false

    property alias paintedWidth : shadow.paintedWidth
    property alias paintedHeight : shadow.paintedHeight

    property bool   snugFit : false
    property int animDuration : 1000
    property int padding      : 5
    property alias wrapMode : zInput.wrapMode


    onFocusChanged: if(focus)
                    {
                        zInput.focus = true
                        zInput.forceActiveFocus()
                    }

    Rectangle{
        id          : inputBgk
        color       : ZGlobal.style.text.color2
        anchors.left: rootObject.left
        anchors.top : rootObject.top
        width       : rootObject.width
        height      : label.text.length > 0 ? rootObject.height * inputAreaRatio : rootObject.height;
        border.width: 1
        border.color: 'black'
    }


    Text{
        id : shadow
        height             : label.text.length > 0 ? rootObject.height * inputAreaRatio : rootObject.height;
        text               : zInput.text
        font               : zInput.font
        opacity: 0
        enabled : snugFit
        visible : snugFit
        onPaintedWidthChanged: if(snugFit && text.length > 0){
                                   rootObject.width = paintedWidth + 20
                               }
    }
    Text{
        id : helperText
        anchors.fill: zInput
        text   : ""
        font   : zInput.font
        enabled : snugFit
        visible : text.length > 0 && zInput.text.length === 0
        color   : Qt.darker(inputBgk.color, 1.5)
        horizontalAlignment: zInput.horizontalAlignment
        verticalAlignment  : zInput.verticalAlignment
        wrapMode           : zInput.wrapMode
    }

    TextArea {
        id : zInput
        width              : inputBgk.width  - padding
        height             : inputBgk.height - padding/2
        anchors.centerIn   : inputBgk
        enabled            : isEnabled
        textFormat         : TextEdit.AutoText

//        activeFocusOnTab : true
        //clip: true
        horizontalAlignment: textInputStyle != Qt.ImhMultiLine ? Text.AlignHCenter : Text.AlignLeft
        verticalAlignment  : textInputStyle != Qt.ImhMultiLine ? Text.AlignVCenter : Text.AlignTop
        style : TextAreaStyle {
            id : textStyle
            textColor           : fontColor
            backgroundColor     : color
            corner              : null
            frame               : null
            incrementControl    : null
            decrementControl    : null
            scrollBarBackground : null
            transientScrollBars : true
            handle : Item {
                implicitWidth : 14
                implicitHeight: 26
                Rectangle {
                    color               : ZGlobal.style.info
                    anchors.fill        : parent
                    anchors.topMargin   : 6
                    anchors.leftMargin  : 4
                    anchors.rightMargin : 4
                    anchors.bottomMargin: 6
                }
            }
//            control           : TextArea
//            font              : font
//            renderType        : int
//            selectedTextColor : color
//            selectionColor    : color
//            textMargin        : real
        }
//        color : ZGlobal.style.text.color1
//        onAccepted:rootObject.accepted()
//        echoMode: isPassword? TextInput.Password : TextInput.Normal
//        passwordMaskDelay: passMaskDelay
//        passwordCharacter: "*"
        onFocusChanged:
        {
            if(text == " - ")         text = ""
            if(focus)                 gotFocus()
            else                      lostFocus()
        }

//        transform : Scale {
//            origin.x : zInput.width
//            origin.y : zInput.height/2
//            xScale   : textInputStyle !== Qt.ImhMultiLine  && (zInput.contentWidth > zInput.width) ? zInput.width / zInput.contentWidth : 1
//            yScale   : xScale
//        }


//        scale    : textInputStyle !== Qt.ImhMultiLine  && (contentWidth > width) ? width / contentWidth : 1
        wrapMode : TextInput.WordWrap

        text :""
        focus: true


        font.family   : ZGlobal.style.text.normal.family
        font.pointSize: ZGlobal.style.text.normal.pointSize
        font.bold     : ZGlobal.style.text.normal.bold
        font.italic   : ZGlobal.style.text.normal.italic



        onCursorPositionChanged: rootObject.cursorPositionChanged(cursorPosition)

        Keys.onReleased:
        {
            if(focus)
            {
                if     (event.key === Qt.Key_Z & event.modifier === Qt.ControlModifier)           undo()
                else if(event.key === Qt.Key_Z & event.modifier === Qt.ControlModifier)           redo()
                else if(event.key === Qt.Key_Enter & event.modifier === Qt.ShiftModifier)         text += "\n"
                event.accepted = true
            }
        }


    }
    Rectangle{
        id : labelRect
        color : ZGlobal.style.accent
        width : parent.width
        height : parent.height * (1 - inputAreaRatio)
        visible : rootObject.haveLabelRect && label.text.length > 0
        border.width: 1

        anchors.left      : rootObject.left
        anchors.top       : outlineVisible ? line.bottom : zInput.bottom
        anchors.topMargin : outlineVisible ? 2 : 0
    }
    Text     {
        id: label
        anchors.centerIn: labelRect
        color : !labelRect.visible ? ZGlobal.style.text.color1 : ZGlobal.style.text.color2
        text: rootObject.labelName
        font.family:rootObject.fontName
        font.pointSize: labelSize ? labelSize : rootObject.fontSize
    }




    Rectangle
    {  // line under the text
        id:line
        width       : inputBgk.width
        anchors.left: inputBgk.left
        height: 2
        color: outlineColor
        anchors.top: inputBgk.bottom
        visible : outlineVisible
        //anchors.bottomMargin: parent.height/-2.5
    }

    Rectangle
    {  // right hook
        id:lineRight
        width: line.height
        height: parent.height/5
        color: outlineColor
        anchors.right:line.right
        anchors.rightMargin:line.height*-1
        anchors.bottom: line.bottom
        visible : outlineVisible
    }

    Rectangle
    {  // left hook
        id:lineLeft
        width: line.height
        height: parent.height/5
        color: outlineColor
        anchors.left:line.left
        anchors.leftMargin:line.height*-1
        anchors.bottom: line.bottom
        visible : outlineVisible
    }

    MouseArea
    {
        anchors.fill:parent
        hoverEnabled: true
        onClicked:
        {
            zInput.forceActiveFocus()
            zInput.cursorPosition = zInput.positionAt(mouse.x, mouse.y)
            rootObject.click()
        }
        onDoubleClicked:
        {
            zInput.selectAll();
            zInput.forceActiveFocus()
        }
        onEntered : rootObject.hovered();
        onExited  : rootObject.unhovered();


    }

    transitions: Transition {
       AnchorAnimation {
        duration: animDuration
        easing.type: Easing.InOutQuad
       }
    }
    states : [
        State{  //bottom
            name : ""
            PropertyChanges {
                target: inputBgk
                width : rootObject.width
                height: label.text.length > 0 ? rootObject.height * inputAreaRatio : rootObject.height;
                anchors.topMargin  : 0
                anchors.leftMargin : 0
            }
            PropertyChanges {
                target            : labelRect;
                width             : label.text.length > 0 ? rootObject.width : 0
                height            : label.text.length > 0 ? rootObject.height * (1 - inputAreaRatio) : 0
                anchors.topMargin : outlineVisible ?  2 : 0
            }
            AnchorChanges{
                target : inputBgk
                anchors.top        : rootObject.top
                anchors.left       : rootObject.left
            }
            AnchorChanges{
                target            : labelRect
                anchors.left      : rootObject.left
                anchors.top       : outlineVisible ? line.bottom : zInput.bottom
                anchors.verticalCenter: undefined
                anchors.horizontalCenter: undefined
            }

        }
        ,
        State{
            name : "left"
            PropertyChanges{
                target                : inputBgk
                width                 : label.text.length > 0 ? rootObject.width * inputAreaRatio : rootObject.width ;
                height                : rootObject.height
                anchors.topMargin     : 0
                anchors.leftMargin    : 0
                //anchors.verticalCenter: rootObject.verticalCenter
            }
            PropertyChanges{
               target            : labelRect
               width             : label.text.length > 0 ? rootObject.width * (1 - inputAreaRatio) : 0
               height            : label.text.length > 0 ? rootObject.height : 0
               anchors.topMargin : 0
            }
            AnchorChanges{
                target : inputBgk
                anchors.top           : rootObject.top
                anchors.left          : labelRect.right
            }
            AnchorChanges{
                target            : labelRect
                anchors.left      : rootObject.left
                anchors.top       : rootObject.top
                anchors.verticalCenter: rootObject.verticalCenter
                anchors.horizontalCenter: undefined
            }
        }
        ,
        State{
            name : "right"
            PropertyChanges{
                target : inputBgk
                width                 : label.text.length > 0 ? rootObject.width * inputAreaRatio: rootObject.width;
                height                : rootObject.height
                anchors.topMargin     : 0
                anchors.leftMargin    : 0
//                anchors.verticalCenter: rootObject.verticalCenter
            }
            PropertyChanges{
               target : labelRect
               width             : label.text.length > 0 ? rootObject.width * (1 - inputAreaRatio) : 0
               height            : label.text.length > 0 ? rootObject.height : 0
            }
            AnchorChanges{
                target : inputBgk
                anchors.left          : rootObject.left
                anchors.top           : rootObject.top
            }
            AnchorChanges{
                target            : labelRect
                anchors.top       : rootObject.top
                anchors.left      : zInput.right
                anchors.verticalCenter: rootObject.verticalCenter
                anchors.horizontalCenter: undefined
            }
        }
        ,
        State{
            name : "top"
            PropertyChanges {
                target: inputBgk
                width : rootObject.width
                height: label.text.length > 0 ? rootObject.height * inputAreaRatio : rootObject.height;
                anchors.topMargin     : 0
                anchors.leftMargin    : 0
            }
            PropertyChanges {
                target: labelRect;
                width             : label.text.length > 0 ? rootObject.width : 0
                height            : label.text.length > 0 ? rootObject.height * (1 - inputAreaRatio) : 0
                anchors.topMargin : 0
            }
            AnchorChanges{
                target : inputBgk
                anchors.top        : labelRect.bottom
                anchors.left       : rootObject.left
            }
            AnchorChanges{
                target            : labelRect
                anchors.top       : rootObject.top
                anchors.left      : rootObject.left
                anchors.verticalCenter: undefined
                anchors.horizontalCenter: undefined
            }
        }
    ]





}
