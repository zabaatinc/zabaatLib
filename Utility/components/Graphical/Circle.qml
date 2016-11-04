import QtQuick 2.5
Item {
    id : rootObject
    property real diameter : 100
    width  : diameter
    height : diameter

    property alias border: borderRect.border
    property color color : 'green'
    property color emptyColor   : Qt.rgba(0,0,0,0);
    readonly property alias mixedColor : fill.color
    property real value         : 1    //value must be between 0 and 1
    onValueChanged: {
        if(value > 1)
            value = 1
        else if(value < 0)
            value = 0;
    }

    Item {
        width : parent.width
        height : parent.height
        clip : true
//            border.width: 1
        y : parent.height * (1-value)

        Rectangle {
            id : fill
            width : parent.width
            height : parent.height
            radius : parent.parent.height
            y : -parent.y
            color : emptyColor.a === 0 ? rootObject.color : mix(rootObject.emptyColor,rootObject.color,value);

//            function mix(c1,c2,val) {
//                if(val < 0)   val = 0;
//                if(val > 1)   val = 1;
//                var dVal = 1 - val;
////                console.log("VAL",val, "DVAL", dVal)
//                var r = (c2.r - c1.r) * val  + c1.r;
//                var g = (c2.g - c1.g) * val  + c1.g;
//                var b = (c2.b - c1.b) * val  + c1.b;
//                return  Qt.rgba(r,g,b,1)
//            }

            function mix(color1,color2,val) {
                if(val < 0)   val = 0;
                if(val > 1)   val = 1;
                var dVal = 1 - val;
                var r = (color2.r * val) + (color1.r  * dVal)
                var g = (color2.g * val) + (color1.g  * dVal)
                var b = (color2.b * val) + (color1.b  * dVal)
                return  Qt.rgba(r,g,b)
            }

        }






    }

    Rectangle {
        id : borderRect
        anchors.fill: parent;
        radius: parent.height;
        color : 'transparent'
        border.width: 1;
    }




}
