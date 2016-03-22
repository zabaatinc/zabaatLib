import QtQuick 2.4

Item {
    id : rootObject
    property color color       : "pink"
    property alias borderWidth : _border.width
    property alias borderColor : _border.color

    onColorChanged: canvas.requestPaint()
    onBorderWidthChanged: canvas.requestPaint()
    onBorderColorChanged: canvas.requestPaint()


    Canvas {
        id : canvas
        width  : parent.width
        height : parent.height + triHeight
        //renderTarget : Canvas.FramebufferObject
        renderStrategy: Canvas.Immediate

        property double triHeight  : rootObject.height * 0.2
        property int bubbleStartAt : 3
        onPaint: {
            var ctx = getContext("2d")
            ctx.save()

            ctx.lineWidth   = rootObject.borderWidth
            ctx.strokeStyle = rootObject.borderColor
            ctx.fillStyle   = rootObject.color

            var width  = canvas.width
            var height = canvas.height - triHeight - 1

            ctx.beginPath()

            ctx.moveTo(0,0)

            //bot.left
            ctx.lineTo(0, height)

            //bot.centerLf
            ctx.lineTo(width/bubbleStartAt, height)

            //bubble
            ctx.lineTo(width/2, height + triHeight)

            //bot.centerRt
            ctx.lineTo(width - width/bubbleStartAt, height)

            //botRt
            ctx.lineTo(width, height)

            //topRt
            ctx.lineTo(width,0)

            //0,0
            ctx.lineTo(0,0)

            ctx.closePath()
            ctx.fill()
            ctx.stroke()
            ctx.restore()
        }
    }

    QtObject {
        id : _border
        property color color : "transparent"
        property int   width : 0
    }
}
