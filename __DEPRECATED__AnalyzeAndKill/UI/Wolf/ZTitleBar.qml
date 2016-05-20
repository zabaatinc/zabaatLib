import QtQuick 2.0
import Zabaat.Misc.Global 1.0
import QtQuick.Window 2.0
import Zabaat.UI.Fonts 1.0
import "zBaseComponents"
Rectangle
{
    id : rootObject
    width : minWidth
    height: minHeight

    //used when resizing manually using mouseArea
    property real minWidth  : 320
    property real minHeight : 240

    property string title : "ZTitle"
    property var winPtr : null
    onWinPtrChanged: if(winPtr && winPtr.toString().toLowerCase().indexOf("window") !== -1){
                         connectActive.target = winPtr
                     }

    Connections {
        id : connectActive
        target : null
        onActiveChanged : {
//            console.log("ACTIVE CHANGED!!!", winPtr, winPtr.active)
            if(winPtr.active)
                focusAnimationContainer.playFocusAnimation()
        }
    }

    color                           : winPtr && winPtr.activeFocusItem ?  focusColor : unfocusColor
    property color focusColor       : ZGlobal.style.accent
    property color unfocusColor     : ZGlobal.style._default
    property color focusTextColor   : ZGlobal.style.text.color2
    property color unfocusTextColor : ZGlobal.style.text.color1

//    property color _temp : "black"
//    Component.onCompleted: {
//       focusColor       = ZGlobal.style.accent
//       unfocusColor     = Qt.lighter(ZGlobal.style.accent)
//       focusTextColor   = ZGlobal.style.text.color2
//       unfocusTextColor = ZGlobal.style.text.color1
//       _temp           = unfocusColor
//    }
//    Connections {
//        target : winPtr
//        onActiveFocusItemChanged: {
//            if(activeFocusItem){
//                //got focused
//                ZGlobal.style.accent = _temp
//            }
//            else{
//                _temp= ZGlobal.style.accent
//                ZGlobal.style.accent = unfocusColor
//            }
//        }
//    }

    property bool haveClose     : true
    property bool haveMaximize  : true
    property bool haveMinimize  : true
    onHaveCloseChanged:    if(!haveClose)    _btnRow.spacingMulti--;    else _btnRow.spacingMulti++
    onHaveMaximizeChanged: if(!haveMaximize) _btnRow.spacingMulti--;    else _btnRow.spacingMulti++
    onHaveMinimizeChanged: if(!haveMinimize) _btnRow.spacingMulti--;    else _btnRow.spacingMulti++


    property bool allowResizeBotRt : true
    property bool allowResizeRt    : true
    property bool allowResizeTop   : true
    property bool allowResizeLeft  : true
    property bool allowResizeBot   : true
    property alias btnRow          : _btnRow

    property var minFunc   : null
    property var maxFunc   : null
    property var closeFunc : null

    border.width: 2
    Text{
        text : title
        font:  ZGlobal.style.text.heading1
        color : winPtr && winPtr.activeFocusItem ? rootObject.focusTextColor : rootObject.unfocusTextColor
        visible : title.length > 0

        width : parent.width
        height : parent.height
        scale : {
            if(paintedWidth > width && paintedHeight > height)
                return Math.min(width/paintedWidth , height/paintedHeight)
            else if(paintedWidth > width)
                return width/paintedWidth
            else if(paintedHeight > height)
                return height/paintedHeight
            return 1
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    MouseArea{
        anchors.fill: parent
        property var clickPos : ({x:1,y:1})
        onPressed: clickPos = Qt.point(mouse.x, mouse.y)
        enabled : winPtr

        onPositionChanged: {
            var delta  = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
            var pts = Qt.point(winPtr.x + delta.x, winPtr.y + delta.y)

            winPtr.x = pts.x
            winPtr.y = pts.y
//            console.log("HEY I HAPPEN")
        }
        onDoubleClicked: {
                if(!maxBtn.flip && winPtr.showMaximized)    winPtr.showMaximized()
                else if(winPtr.showNormal)                  winPtr.showNormal()

                maxBtn.flip = !maxBtn.flip
        }
    }

    //resize areas!

    MouseArea{
        id : resizeAreaRight
        enabled : winPtr && allowResizeRt
        width   : winPtr ? 8 : 0
        height  : winPtr? winPtr.height : 0
        x       : winPtr ? winPtr.width - width : 0

        cursorShape: Qt.SizeHorCursor
        property int clickPos : 1
        onPressed: clickPos = mouse.x
        onPositionChanged: {
            var delta      = mouse.x - clickPos

            if(delta < 0 && winPtr.width <= minWidth)         delta = 0

            winPtr.width  += delta
        }
    }
    MouseArea{
        id : resizeAreaLeft
        enabled : winPtr && allowResizeLeft
        width   : winPtr ? 8 : 0
        height  : winPtr? winPtr.height : 0
        x       : 0

        cursorShape: Qt.SizeHorCursor
        property int clickPos : 1
        onPressed: clickPos = mouse.x
        onPositionChanged: {
            var delta      = clickPos - mouse.x

            if(delta < 0 && winPtr.width <= minWidth)
                delta = 0

            winPtr.width  += delta
            winPtr.x -= delta
        }
    }
    MouseArea{
        id : resizeAreaTop
        enabled : winPtr && allowResizeTop
        width   : winPtr ? winPtr.width : 0
        height  : winPtr? 8 : 0
        y       : 0

        cursorShape: Qt.SizeVerCursor
        property int clickPos : 1
        onPressed: clickPos = mouse.y
        onPositionChanged: {
            var delta      = clickPos - mouse.y

            if(delta < 0 && winPtr.height <= minHeight)         delta = 0

            winPtr.height  += delta
            winPtr.y -= delta
        }
    }
    MouseArea{
        id : resizeAreaBot
        enabled : winPtr && allowResizeBot
        width   : winPtr ? winPtr.width : 0
        height  : winPtr? 8 : 0
        y       : winPtr? winPtr.height - height : 0

        cursorShape: Qt.SizeVerCursor
        property int clickPos : 1
        onPressed: clickPos = mouse.y
        onPositionChanged: {
            var delta      = mouse.y - clickPos

            if(delta < 0 && winPtr.height <= minHeight)         delta = 0

            winPtr.height  += delta
        }
    }
    MouseArea{
        id : resizeAreaBotRight
        enabled : winPtr && allowResizeBotRt
        width   : 8
        height  : width
        x : winPtr ? winPtr.width - width : 0
        y : winPtr ? winPtr.height - height : 0

        cursorShape: Qt.SizeFDiagCursor
        property var clickPos : ({x:1,y:1})
        onPressed: clickPos = Qt.point(mouse.x, mouse.y)
        onPositionChanged: {
            var delta      = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)

            if(delta.x < 0 && winPtr.width <= minWidth)                delta.x = 0
            if(delta.y < 0 && winPtr.height <= minHeight)              delta.y = 0

            winPtr.width  += delta.x
            winPtr.height += delta.y
        }
    }

    //btns at the top!
    Row{
        id : _btnRow
        anchors.right: parent.right
        property int spacingMulti: 2
        onSpacingChanged: if     (spacingMulti < 0) spacingMulti = 0;
                          else if(spacingMulti > 2) spacingMulti = 2

        spacing : 0//10
        width : closeBtn.width + maxBtn.width + minBtn.width +  spacing * spacingMulti
        height : parent.height

        ZBase_Button{
            id : minBtn
            text : ""
            fontAwesomeIcon: "\uf068"
            onBtnClicked: {
                if(minFunc)               minFunc()
                else if(winPtr)           winPtr.showMinimized()
            }

            visible : haveMinimize
            width   : haveMinimize ? 32 : 0
            height : parent.height
            defaultColor: rootObject.color
            textColor: winPtr && winPtr.activeFocusItem ? rootObject.focusTextColor : rootObject.unfocusTextColor
        }
        ZBase_Button{
            id : maxBtn
            text : ""
            fontAwesomeIcon: "\uf096"

            property bool flip : false
            onBtnClicked : {
                if(maxFunc){
                    console.log("CALLING MAX FUNC")
                    maxFunc()
                }
                else if(winPtr)
                {
                    if(!flip)  winPtr.showMaximized()
                    else       winPtr.showNormal()
                        flip = !flip
                }
            }

            visible : haveMaximize
            width   : haveMaximize ? 32 : 0
            height  : parent.height
            defaultColor : rootObject.color
            textColor: winPtr && winPtr.activeFocusItem ? rootObject.focusTextColor : rootObject.unfocusTextColor
        }
        ZBase_Button{
            id : closeBtn
            defaultColor :  winPtr && !winPtr.activeFocusItem ? Qt.darker(ZGlobal.style.danger) : ZGlobal.style.danger
            text : ""
            fontAwesomeIcon: "\uf00d"

            onBtnClicked :{
                if(closeFunc)               closeFunc()
                else if(winPtr.closeFunc)   winPtr.closeFunc()
                else if(winPtr)             winPtr.close()
            }

            visible : haveClose
            width   : haveClose ? 32 : 0
            height  : parent.height
        }
    }


    Item {
        id : focusAnimationContainer
        anchors.fill: parent
        z : 99999

        Rectangle {
            id     : titleBarMascot
            width  : parent.width / 90
            height : parent.height / 4
            visible: false
            enabled : false
            radius : height / 3
            color  : ZGlobal.style.text.color2

            property int animDuration : 1500

            NumberAnimation on x {
                id : moveAnim
                to : rootObject.width
                duration  : titleBarMascot.animDuration
                onStopped : focusAnimationContainer.reset()
            }
            SequentialAnimation on y {
                id : sineAnim
                running : moveAnim.running
                loops : Animation.Infinite
                NumberAnimation  {
                    from     : 0
                    to       : rootObject.height
                    duration : titleBarMascot.animDuration/8
                    easing.type: Easing.Bezier
                }
                NumberAnimation  {
                    to       : 0
                    from     : rootObject.height
                    duration : titleBarMascot.animDuration/8
                    onStopped : focusAnimationContainer.reset()
                    easing.type: Easing.Bezier
                }
            }
        }

        function reset(){
            titleBarMascot.x = 0
            titleBarMascot.rotation = 0
            titleBarMascot.visible = false
        }
        function playFocusAnimation(){
            titleBarMascot.visible = true
//            rotAnim.start()
            moveAnim.start()
        }
    }


}
