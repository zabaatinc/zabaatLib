import QtQuick 2.5
import Zabaat.Material 1.0

//TODO DEAL with this BS later.
Item {
    id : rootObject
    property string mask        : "hexMask.png"
    property alias  border      : borderRect.border

    signal pressed(var self)
    signal clicked(var self, int x, int y, int button)
    signal singleClicked(var self, int x,  int y, int button)
    signal doubleClicked(var self, int x , int y, int button)

    property alias acceptedButtons  : btn.acceptedButtons
    property alias containsMouse    : btn.containsMouse
    property alias text             : btn.text
    property alias text2            : btn.text2
    property alias allowDoubleClicks: btn.allowDoubleClicks
    property alias state            : btn.state

    function paintedWidth()    { return btn.paintedWidth() }
    function paintedHeight()   { return btn.paintedHeight() }
    function getTextStartPos() { return btn.getTextStartPos() }
    function getUnformattedText(rtfText){   return btn.getUnformattedText(rtfText) }

    Rectangle {
        id : borderRect
        anchors.fill: parent
        visible : false;
    }
//    Image {
//        id : borderMask
//        width : borderRect.width
//        height : borderRect.height
//        source : mask
//        visible: false
//    }

//    OpacityMask {
//        anchors.fill : borderRect
//        source       : btn
//        visible : border.width > 0
//        maskSource : borderMask
//    }

    ZButton {
        id : btn
        anchors.fill: parent
        anchors.margins: borderRect.border.width
        visible: false
    }

    Item {
        id: btnEffect
        anchors.fill: btn
        ShaderEffectSource {
            id : shaderEffectSource
            sourceItem  : btn
            anchors.fill: parent
            hideSource: true
            smooth: true
            recursive: true
        }
        ShaderEffect {
            property var source : shaderEffectSource
            property var mask   : Image {
                width : btn.width
                height : btn.height
                fillMode: Image.PreserveAspectFit
                source : rootObject.mask
            }
            anchors.fill: parent
            fragmentShader: "
                #ifdef GL_ES
                    precision mediump float;
                #else
                #   define lowp
                #   define mediump
                #   define highp
                #endif // GL_ES
                varying vec2       qt_TexCoord0;
                uniform lowp float qt_Opacity;
                uniform sampler2D source;
                uniform sampler2D mask;
                void main(){
                    vec2 uv        = qt_TexCoord0.xy;
                    vec4 maskPixel = texture2D(mask,qt_TexCoord0);
                    float maskVal  = 1.0 - (3.0 - maskPixel.r - maskPixel.g - maskPixel.b)/3.0;
                    vec4  pixel    = texture2D(source,qt_TexCoord0);
                    pixel.a *= maskVal;
                    gl_FragColor   = pixel * qt_Opacity;
                }"

        }
    }





}



////http://wp.applesandoranges.eu/?p=14
//#ifdef GL_ES
//    precision mediump float;
//#else
//#   define lowp
//#   define mediump
//#   define highp
//#endif // GL_ES
//uniform sampler2D source;
//uniform sampler2D mask;

//varying vec2       qt_TexCoord0;
//uniform lowp float qt_Opacity;
//uniform float      dividerValue;
//uniform float      maskStrength;
//uniform bool       alphaChannelMask;

//void main(){
//    vec2 uv        = qt_TexCoord0.xy;
//    vec4 pixel     = texture2D(source,qt_TexCoord0);
//    if(uv.x <= dividerValue) {
//        vec4 maskPixel = texture2D(mask,qt_TexCoord0);
//        float maskVal  = 1.0;
//        //maskVal represents how much to mask , 0.0f being not mask at all and 1.0f being mask it all.
//        if(alphaChannelMask){
//            maskVal = (1.0 -  maskPixel.a);
//        }
//        else {
//            maskVal = (3.0 - maskPixel.r - maskPixel.g - maskPixel.b)/3.0;
//        }
//        maskVal  = maskVal * maskStrength;
//        pixel    = pixel * (1.0 - maskVal);
//    }
////    pixel.a = 0.0f;
//    gl_FragColor = pixel * qt_Opacity;
//}
