import QtQuick 2.5
Canvas {
    id : rootObject
    width : 64
    height : 64
    property real value      : 0
    property real startAngle : 0
    property real arcLen     : Math.PI * 2
    property int thickness   : 4
    property color color          : "green"
    property color colorEmpty     : "gray"

    property point centerOffset : Qt.point(0.5,0.5)
    property real  radius       : Math.min(width -thickness, height -thickness)/2

    onArcLenChanged     : requestPaint();
    onStartAngleChanged : requestPaint();
    onThicknessChanged  : requestPaint();
    onColorChanged      : requestPaint();
    onColorEmptyChanged : requestPaint();
    onValueChanged      : requestPaint();

    onPaint: {
        var ctx = getContext('2d')
        ctx.clearRect(0,0,width,height);

        var center     = Qt.point(width * centerOffset.x, height * centerOffset.y);
        var radius     = rootObject.radius

        ctx.beginPath();
        ctx.arc(center.x, center.y, radius, startAngle, startAngle + arcLen);

        ctx.lineWidth = thickness;
        ctx.strokeStyle = colorEmpty;
        ctx.stroke();

//            ctx.moveTo(0,0);
        ctx.beginPath();
        ctx.arc(center.x, center.y, radius, startAngle, startAngle + (arcLen * value));
        ctx.lineWidth   = thickness;
        ctx.strokeStyle = color;
        ctx.stroke();
    }
}
