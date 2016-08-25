import QtQuick 2.5
import Zabaat.Shaders 1.0
Item {
    id : rootObject
    property color emptyColor : color
    property color color      : "red"
    property real  value      : 0
    property alias border     : colorRect.border

    implicitWidth:100
    implicitHeight: 100
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()

    Rectangle {
        id : colorRect
        anchors.fill: parent
        color : 'purple'
        anchors.centerIn: parent
        visible : false
        border.width: 0
        property real bw : border.width
        onBwChanged: canvas.requestPaint()
    }

    ShaderEffect {  //turns into diamond
        id : se
        anchors.fill: colorRect
        property var src : colorRect
//        onBorderWidthChanged: console.log(border.width,"/", colorRect.width, "=", borderWidth)
        fragmentShader : "
                varying vec2 qt_TexCoord0;
                uniform sampler2D src;
                uniform lowp float qt_Opacity;
                void main() {
                    vec2 uv = abs(qt_TexCoord0.xy - 0.5) * 2;
                    uv.x = abs(uv.x - 1);
                    float diff = uv.x - uv.y;
                    gl_FragColor = (diff >= 0 ? vec4(1) : vec4(0)) * qt_Opacity;
                }"
    }

    ShaderEffectSource {
        id : ses
        sourceItem : se
        hideSource : true
        recursive  : true
    }
    ShaderEffect {
        property var src : ses
        anchors.fill: colorRect
        property vector4d clr1  : Qt.vector4d(color.r, color.g, color.b, color.a )
        property vector4d clr2  : Qt.vector4d(emptyColor.r, emptyColor.g, emptyColor.b, emptyColor.a)
        property real     value : rootObject.value
        fragmentShader : "
                varying vec2 qt_TexCoord0;
                uniform sampler2D src;
                uniform lowp float qt_Opacity;
                uniform vec4 clr1;
                uniform vec4 clr2;
                uniform float value;
                void main() {
                    lowp vec4 tex = texture2D(src, qt_TexCoord0);
                    vec4 c = tex;
                    if(tex.a > 0){
                        c = qt_TexCoord0.x > value ? clr2 : clr1;
                    }
                    gl_FragColor = c * qt_Opacity;
                }"

    }

    Canvas {    //border canvas
        id: canvas
        anchors.centerIn: parent
        width : parent.width   + border.width + 1
        height : parent.height + border.width + 1
        visible : border.width > 0
//        renderTarget: Canvas.FramebufferObject
        onWidthChanged: if(visible) requestPaint();
        onHeightChanged:if(visible) requestPaint();
        onPaint : {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            if(border.width <= 0 || rootObject.width <= 0 || rootObject.height <= 0)
                return;

            ctx.beginPath();


            ctx.strokeStyle = border.color
            ctx.lineWidth   = border.width ;

            var w = width
            var h = height

//            ctx.fillStyle   = color;
            ctx.moveTo(w/2, 0);

            ctx.lineTo(w,h/2);
            ctx.lineTo(w/2,h);
            ctx.lineTo(0,h/2);
            ctx.lineTo(w/2,0);

            ctx.stroke();
//            ctx.fill();


        }
    }



}
