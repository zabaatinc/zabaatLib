import QtQuick 2.5
import Zabaat.Shaders 1.0

Item {
    id : rootObject
    property color emptyColor : color
    property color color      : "red"
    property real  value      : 0
    property alias border     : colorRect.border
    property alias fillsVertically : fillEffect.fillsVertically;
    property bool  borderAroundFill : false;

    implicitWidth:100
    implicitHeight: 100
//    onWidthChanged: canvas.requestPaint()
//    onHeightChanged: canvas.requestPaint()

    Rectangle {
        id : colorRect
        anchors.fill: parent
        color : 'purple'
        anchors.centerIn: parent
        visible : false
        border.width: 1
        property real bw : border.width
//        onBwChanged: canvas.requestPaint()
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
                    vec2 uv = abs(qt_TexCoord0.xy - vec2(0.5,0.5)) * vec2(2,2);
                    uv.x = abs(uv.x - 1.0f);
                    float diff = uv.x - uv.y;
                    vec4 v = vec4(0.0f);
                    if(diff > 0.0f || diff == 0.0f) {
                        v = vec4(1.0f);
                    }
                    gl_FragColor = v * qt_Opacity;
                }"
    }
    ShaderEffectSource {
        id : fillEffectSource
        sourceItem : se
        hideSource : true
        recursive  : true
    }
    ShaderEffect {
        id : fillEffect
        property var src : fillEffectSource
        anchors.fill: colorRect
        property color clr1 : color
        property color clr2 : emptyColor
//        property vector4d clr1  : Qt.vector4d(color.r, color.g, color.b, color.a )
//        property vector4d clr2  : Qt.vector4d(emptyColor.r, emptyColor.g, emptyColor.b, emptyColor.a)
        property real     value : rootObject.value
        property bool fillsVertically : false;
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
                uniform bool  fillsVertically;
                void main() {
                    lowp vec4 tex = texture2D(src, qt_TexCoord0);
                    vec4 c = tex;
                    float zero = float(0);
                    if(tex.a > zero){
                        if(!fillsVertically) {
                            if(qt_TexCoord0.x > value){
                                c = clr2;
                            }
                            else {
                                c = clr1;
                            }
                        }
                        else {
                            if(qt_TexCoord0.y > (1.0f - value)){
                                c = clr1;
                            }
                            else {
                                c = clr2;
                            }
                        }
                    }
                    gl_FragColor = c * qt_Opacity;
                }"

    }
    ShaderEffectSource {
        id : outlineEffectSource
        sourceItem : borderAroundFill ? fillEffect : se
        hideSource : true
        recursive  : true
    }
    ShaderEffect {
        id : outlineEffect
        property var src : outlineEffectSource
        width : parent.width + colorRect.border.width
        height : parent.height + colorRect.border.width
//        anchors.fill: parent
        anchors.centerIn: parent
        property vector2d borderRatio : Qt.vector2d(colorRect.border.width/width,colorRect.border.width/height);
        property color borderColor : colorRect.border.color
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
                uniform vec2 borderRatio;
                uniform vec4 borderColor;
                void main() {
                    lowp vec4 tex = texture2D(src, qt_TexCoord0);
                    float alpha = 4.0f * tex.a;
                    float bx = borderRatio.x;
                    float by = borderRatio.y;
                    alpha -= texture2D(src, qt_TexCoord0 + vec2(bx  , 0.0f)).a;
                    alpha -= texture2D(src, qt_TexCoord0 + vec2(-bx , 0.0f)).a;
                    alpha -= texture2D(src, qt_TexCoord0 + vec2(0.0f, by)).a;
                    alpha -= texture2D(src, qt_TexCoord0 + vec2(0.0f, -by)).a;

                    if(alpha != 0.0f) {
                        tex = vec4(borderColor.rgb,alpha);
                    }
                    gl_FragColor = tex * qt_Opacity;
                }"

    }




//    Canvas {    //border canvas
//        id: canvas
//        anchors.centerIn: parent
//        width : parent.width   + border.width + 1
//        height : parent.height + border.width + 1
//        visible : border.width > 0
////        renderTarget: Canvas.FramebufferObject
//        onWidthChanged: if(visible) requestPaint();
//        onHeightChanged:if(visible) requestPaint();
//        onPaint : {
//            var ctx = getContext("2d");
//            ctx.clearRect(0, 0, canvas.width, canvas.height);

//            if(border.width <= 0 || rootObject.width <= 0 || rootObject.height <= 0)
//                return;

//            ctx.beginPath();


//            ctx.strokeStyle = border.color
//            ctx.lineWidth   = border.width ;

//            var w = width
//            var h = height

////            ctx.fillStyle   = color;
//            ctx.moveTo(w/2, 0);

//            ctx.lineTo(w,h/2);
//            ctx.lineTo(w/2,h);
//            ctx.lineTo(0,h/2);
//            ctx.lineTo(w/2,0);

//            ctx.stroke();
////            ctx.fill();


//        }
//    }



}
