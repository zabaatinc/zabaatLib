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
            #ifdef GL_ES
                precision mediump float;
            #else
            #   define lowp
            #   define mediump
            #   define highp
            #endif // GL_ES
                varying vec2 qt_TexCoord0;
                uniform sampler2D src;
                uniform lowp float qt_Opacity;
                void main() {
                    float zero = float(0);
                    float one = float(1);
                    vec2 uv = abs(qt_TexCoord0.xy - vec2(0.5,0.5)) * vec2(2,2);
                    uv.x = abs(uv.x - one);
                    float diff = uv.x - uv.y;
                    vec4 v = vec4(0);
                    if(diff > zero || diff == zero) {
                        v = vec4(1);
                    }
                    gl_FragColor = v * qt_Opacity;
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
            #ifdef GL_ES
                precision mediump float;
            #else
            #   define lowp
            #   define mediump
            #   define highp
            #endif // GL_ES
                varying vec2 qt_TexCoord0;
                uniform sampler2D src;
                uniform lowp float qt_Opacity;
                uniform vec4 clr1;
                uniform vec4 clr2;
                uniform float value;
                void main() {
                    lowp vec4 tex = texture2D(src, qt_TexCoord0);
                    vec4 c = tex;
                    float zero = float(0);
                    if(tex.a > zero){
                        if(qt_TexCoord0.x > value){
                            c = clr2;
                        }
                        else {
                            c = clr1;
                        }
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
