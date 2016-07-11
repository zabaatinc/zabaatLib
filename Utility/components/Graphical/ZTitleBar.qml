import QtQuick 2.0
Item {
    id : rootObject
    width : winPtr? winPtr.width  : minWidth
    height: winPtr? winPtr.height : minHeight

    property var   winPtr
    property color color     : 'maroon'

    //used when resizing manually using mouseArea
    property real minWidth  : 320
    property real minHeight : 240

    property string title           : "ZTitle"
    property var   buttonDelegate   : btnDel
    property alias logic            : logic
    property alias gui              : gui
    property alias btnRow           : _btnRow



    QtObject {
        id : logic
        property bool flipMax  : false
        property var minFunc   : f1
        property var maxFunc   : f2
        property var closeFunc : f3
        property bool allowResizeBotRt : true
        property bool allowResizeRt    : true
        property bool allowResizeTop   : true
        property bool allowResizeLeft  : true
        property bool allowResizeBot   : true

        function f1(){
            if(winPtr)
                winPtr.showMinimized()
        }
        function f2(){
            if(winPtr)
            {
                if(!flipMax)  winPtr.showMaximized()
                else          winPtr.showNormal()
            }
            flipMax = !flipMax
        }
        function f3(){
            if(typeof winPtr.closeFunc === 'function')
                winPtr.closeFunc()
            else if(winPtr)
                winPtr.close()
        }
    }

    Item{
        id : gui
        anchors.fill: parent

        property color focusColor       : rootObject.color
        property color unfocusColor     : Qt.darker(rootObject.color)

        property color focusTextColor   : "white"
        property color unfocusTextColor : focusTextColor
        property color animColor        : 'yellow'
        property alias fontFamily       : text.font.family
        property bool haveClose     : true
        property bool haveMaximize  : true
        property bool haveMinimize  : true
        property string minText : "-"
        property string maxText : "[]"
        property string closeText : "X"
        property real   resizeAreaPx : 15
        property real   barSize : 30
        property alias  border  : borderRect.border

        //mouse Areas
        Item {
            id : mouseAreas
            anchors.fill: parent
            MouseArea{
                width : parent.width
                height : gui.barSize
                property var clickPos : ({x:1,y:1})
                onPressed: clickPos = Qt.point(mouse.x, mouse.y)
                enabled : winPtr ? true : false

                onPositionChanged: {
                    var delta  = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                    var pts = Qt.point(winPtr.x + delta.x, winPtr.y + delta.y)
                    winPtr.x = pts.x
                    winPtr.y = pts.y
                }
                onDoubleClicked: {
                        if(!logic.flipMax && winPtr.showMaximized)    winPtr.showMaximized()
                        else if(winPtr.showNormal)                  winPtr.showNormal()

                        logic.flipMax = !logic.flipMax
                }
            }
            MouseArea{
                id : resizeAreaRight
                enabled : winPtr && logic.allowResizeRt ? true : false
                width   : winPtr ? 8 : 0
                height  : winPtr? winPtr.height : 0
                x       : winPtr ? winPtr.width - width : 0

                cursorShape: Qt.SizeHorCursor
                property int clickPos : 1
                onPressed: clickPos = mouse.x
                onPositionChanged: {
                    var delta      = mouse.x - clickPos
                    if(delta < 0 && winPtr.width <= minWidth)
                        delta = 0
                    winPtr.width  += delta
                }
            }
            MouseArea{
                id : resizeAreaLeft
                enabled : winPtr && logic.allowResizeLeft ? true : false
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
                enabled : winPtr && logic.allowResizeTop? true : false
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
                enabled : winPtr && logic.allowResizeBot? true : false
                width   : winPtr ? winPtr.width : 0
                height  : winPtr? gui.resizeAreaPx : 0
                y       : winPtr? winPtr.height - height : 0

                cursorShape: Qt.SizeVerCursor
                property int clickPos : 1
                onPressed        : clickPos = mouse.y
                onPositionChanged: {
                    var delta      = mouse.y - clickPos
                    if(delta < 0 && winPtr.height <= minHeight)
                        delta = 0

                    winPtr.setHeight(winPtr.height + delta)
                }
            }
            MouseArea{
                id : resizeAreaBotRight
                enabled : winPtr && logic.allowResizeBotRt? true : false
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
        }

        //background
        Rectangle {
            id : bar
            border.width: 2
            color : winPtr && winPtr.activeFocusItem ?  gui.focusColor : gui.unfocusColor
            width : parent.width
            height : gui.barSize

            //Title Text
            Text{
                id: text
                text    : title
                anchors.fill: parent
                color   : winPtr && winPtr.activeFocusItem ? gui.focusTextColor : gui.unfocusTextColor
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

            //btns at the top!
            Row{
                id : _btnRow
                anchors.right: parent.right
                width  : childrenRect.width
                height : parent.height


                Component.onCompleted: {
                    var min   = btnLoaderFactory.createObject(_btnRow)
                    var max   = btnLoaderFactory.createObject(_btnRow)
                    var close = btnLoaderFactory.createObject(_btnRow)

                    min.visible   = Qt.binding(function(){ return gui.haveMinimize  })
                    max.visible   = Qt.binding(function(){ return gui.haveMaximize  })
                    close.visible = Qt.binding(function(){ return gui.haveClose})

                    var hf = function() { return gui.barSize }

                    min.height   =  min.width = Qt.binding(hf)
                    max.height   =  max.width = Qt.binding(hf)
                    close.height =  close.width = Qt.binding(hf)

                    min.func   = logic.minFunc
                    max.func   = logic.maxFunc
                    close.func = logic.closeFunc
                    min.text   = Qt.binding(function() { return gui.minText } )
                    max.text   = Qt.binding(function() { return gui.maxText } )
                    close.text = Qt.binding(function() { return gui.closeText } )
                }
            }

            Item {
                id : focusAnimationContainer
                anchors.fill: parent
                z : Number.MAX_VALUE
                Connections {
                    id : connectActive
                    target : winPtr ? winPtr : null
                    onActiveChanged : {
                        if(winPtr.active)
                            focusAnimationContainer.playFocusAnimation()
                    }
                }

                Rectangle {
                    id     : titleBarMascot
                    width  : parent.width / 90
                    height : parent.height / 4
                    visible: false
                    enabled : false
                    radius : height / 3
                    color  : gui.animColor

                    property int animDuration : 1500

                    NumberAnimation on x {
                        id : moveAnim
                        to : bar.width
                        duration  : titleBarMascot.animDuration
                        onStopped : focusAnimationContainer.reset()
                    }
                    SequentialAnimation on y {
                        id : sineAnim
                        running : moveAnim.running
                        loops : Animation.Infinite
                        NumberAnimation  {
                            from     : 0
                            to       : bar.height
                            duration : titleBarMascot.animDuration/8
                            easing.type: Easing.Bezier
                        }
                        NumberAnimation  {
                            to       : 0
                            from     : bar.height
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

        //borderRect
        Rectangle {
            id : borderRect
            anchors.fill: parent
            border.width: 2
            color : 'transparent'
        }


        Item {
            id : components

            Component {
                id : btnLoaderFactory
                Loader {
                    id :btnLoaderDel
                    property string text
                    property var func
                    width : visible ? height : 0
                    height : rootObject.heights
                    sourceComponent : rootObject.buttonDelegate
                    onLoaded : {
                        if(item.hasOwnProperty('text')) {
                            item.text = Qt.binding(function() { return btnLoaderDel.text} )
                        }
                        if(item.clicked === 'function') {
                            item.clicked.connect(function() {
                                if(typeof btnLoaderDel.func === 'function')
                                    btnLoaderDel.func()
                            })
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled : parent.item && typeof parent.item.clicked !== 'function'
                        onClicked : if(typeof parent.func === 'function')
                                        parent.func()
                    }
                }
            }
            Component {
                id : btnDel
                Rectangle {
                    property string text
                    color : gui.unfocusColor
                    border.width: 1
                    Text {
                        anchors.fill: parent
                        font.family: gui.fontFamily
                        font.pixelSize: height * 1/3
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color : 'white'
                        text  : parent.text
                    }
                }
            }

        }

    }





}
