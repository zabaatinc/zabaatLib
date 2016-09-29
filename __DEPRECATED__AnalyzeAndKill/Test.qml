import QtQuick 2.5
import Zabaat.Utility 1.0
import Zabaat.Material 1.0
Item {
    id : rootObject

    Component.onCompleted:  {
        var m = Moment.create("12/12/2006");
        var m2 = Moment.create("12/12/2008");

        var dur = Moment.duration(Moment.diff(m,"year",true,m2) , "year");
        console.log(dur, dur.humanize());
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 32
        width : parent.width
        height : parent.height * 0.1

        ZSlider {
            id : slider
            value : 0
            min : 0
            max : 1
            width : parent.width * 0.2
            height : parent.height
        }

        ZSlider {
            id : sliderArcLen
            value : max
            min : 0
            max : 2 * Math.PI
            width : parent.width * 0.2
            height : parent.height
        }

        ZSlider {
            id : sliderStart
            value : min
            min : 0
            max : 2 * Math.PI
            width : parent.width * 0.2
            height : parent.height
        }

        ZSlider {
            id : sliderThickness
            value : min
            min : 1
            max : 20
            width : parent.width * 0.2
            height : parent.height
            isInt: true
        }


    }


    property color fillColor : 'red'


    Canvas {
        anchors.centerIn: parent
        property var d : Math.min(parent.width,parent.height)/2
        width  : d
        height : d
        property real value      : slider.value
        property real startAngle : sliderStart.value
        property real arcLen     : sliderArcLen.value
        property int thickness   : sliderThickness.value
        property color color          : "green"
        property color colorEmpty     : "gray"

        onArcLenChanged     : requestPaint();
        onStartAngleChanged : requestPaint();
        onThicknessChanged  : requestPaint();
        onColorChanged      : requestPaint();
        onColorEmptyChanged : requestPaint();
        onValueChanged      : requestPaint();

        onPaint: {
            var ctx = getContext('2d')
            ctx.clearRect(0,0,width,height);

            var center     = Qt.point(width/2,height/2);
            var radius     = Math.min(width -thickness, height -thickness)/2

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




}
