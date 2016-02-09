//The idea is taken from the numerous ps tutorials out there that turn photos into lineart.
//Divied into 3 steps:
// create a blur, depending on radius (blurmask)
// pass the blur along to invertedDOdgeEffect . Invert the blur and use it as a "Blend layer" on the original source!
// then desaturate the image :)
import QtQuick 2.0
Item {
    id : rootObject
    property var dividerValue : null
    property var blurRadius   : null
    property var contrast     : null

    property alias source    : verticalBlur.source
    property var theOriginal : null


    ShaderEffect {
        id : verticalBlur
        anchors.fill: parent
        property variant source
        property real    value     : typeof blurRadius !== 'undefined' ? blurRadius/height * 4 : 0.5
        property real dividerValue : typeof dividerValue !== 'undefined' ? dividerValue : 1
        fragmentShader : "
                         #ifdef GL_ES
                             precision mediump float;
                         #else
                         #   define lowp
                         #   define mediump
                         #   define highp
                         #endif // GL_ES
                         uniform float value;
                         uniform sampler2D source;
                         uniform lowp float qt_Opacity;
                         varying vec2 qt_TexCoord0;
                         uniform float dividerValue;
                         void main()
                         {
                             vec2 uv = qt_TexCoord0.xy;
                             vec4 c = vec4(0.0);
                             if(uv.x < dividerValue) {
                                 c += texture2D(source, uv - vec2(0.0, 4.0*value)) * 0.05;
                                 c += texture2D(source, uv - vec2(0.0, 3.0*value)) * 0.09;
                                 c += texture2D(source, uv - vec2(0.0, 2.0*value)) * 0.12;
                                 c += texture2D(source, uv - vec2(0.0, 1.0*value)) * 0.15;
                                 c += texture2D(source, uv) * 0.18;
                                 c += texture2D(source, uv + vec2(0.0, 1.0*value)) * 0.15;
                                 c += texture2D(source, uv + vec2(0.0, 2.0*value)) * 0.12;
                                 c += texture2D(source, uv + vec2(0.0, 3.0*value)) * 0.09;
                                 c += texture2D(source, uv + vec2(0.0, 4.0*value)) * 0.05;
                             }
                             else {
                                 c = texture2D(source, qt_TexCoord0);
                             }
                             // First pass we don't apply opacity
                             gl_FragColor = c;
                         }"
    }

    ShaderEffectSource {
        id : blurHSource
        hideSource: true
        smooth : true
        recursive: true
        sourceItem : verticalBlur
    }
    ShaderEffect {
        id : horizontalBlur
        anchors.fill: parent
        property variant source    : blurHSource
        property real    value     : typeof blurRadius !== 'undefined' ? blurRadius/width * 4 : 0.5
        property real dividerValue : typeof dividerValue !== 'undefined' ? dividerValue : 1
        fragmentShader : "
                         #ifdef GL_ES
                             precision mediump float;
                         #else
                         #   define lowp
                         #   define mediump
                         #   define highp
                         #endif // GL_ES
                         uniform float value;
                         uniform sampler2D source;
                         uniform lowp float qt_Opacity;
                         varying vec2 qt_TexCoord0;
                         uniform float dividerValue;
                         void main()
                         {
                             vec2 uv = qt_TexCoord0.xy;
                             vec4 c = vec4(0.0);
                             if(uv.x < dividerValue) {
                                 c += texture2D(source, uv - vec2(4.0*value, 0.0)) * 0.05;
                                 c += texture2D(source, uv - vec2(3.0*value, 0.0)) * 0.09;
                                 c += texture2D(source, uv - vec2(2.0*value, 0.0)) * 0.12;
                                 c += texture2D(source, uv - vec2(1.0*value, 0.0)) * 0.15;
                                 c += texture2D(source, uv) * 0.18;
                                 c += texture2D(source, uv + vec2(1.0*value, 0.0)) * 0.15;
                                 c += texture2D(source, uv + vec2(2.0*value, 0.0)) * 0.12;
                                 c += texture2D(source, uv + vec2(3.0*value, 0.0)) * 0.09;
                                 c += texture2D(source, uv + vec2(4.0*value, 0.0)) * 0.05;
                             }
                             else {
                                     c = texture2D(source, qt_TexCoord0);
                             }
                             gl_FragColor = qt_Opacity * c;
                         }"
    }

    ShaderEffectSource {
        id : blendSource
        hideSource : true
        smooth : true
        recursive : true
        sourceItem : horizontalBlur
    }
    ShaderEffect {
        id : blender
        anchors.fill: parent
        property variant source : blendSource
        property variant value  : theOriginal ? blendSource : theOriginal     //THE VERY ORIGINAL. HAPPY TIMES
        property real dividerValue : typeof dividerValue !== 'undefined' ? dividerValue : 1
        fragmentShader : "
                         #ifdef GL_ES
                             precision mediump float;
                         #else
                         #   define lowp
                         #   define mediump
                         #   define highp
                         #endif // GL_ES
                         uniform lowp sampler2D source;
                         uniform lowp sampler2D value;
                         uniform lowp float qt_Opacity;
                         varying highp vec2 qt_TexCoord0;
                         uniform float dividerValue;

                         vec3 invert(vec3 p){ return vec3(1,1,1) - p; }
                         float blendColorDodge(float base, float blend) { return (blend==1.0)?blend:min(base/(1.0-blend),1.0); }
                         vec3 blendColorDodge(vec3 base, vec3 blend) {
                                 return vec3(blendColorDodge(base.r,blend.r),blendColorDodge(base.g,blend.g),blendColorDodge(base.b,blend.b));
                         }

                         vec3 rgb2hsv(vec3 c)
                         {
                             vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                             vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
                             vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

                             float d = q.x - min(q.w, q.y);
                             float e = 1.0e-10;
                             return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
                         }

                         vec3 hsv2rgb(vec3 c)
                         {
                             vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                             vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
                             return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
                         }

                         vec3 desat(vec3 p){
                             vec3 fragHSV = rgb2hsv(p) ;
                             fragHSV.xyz *= vec3(0,0,1);                 //desaturate
                             return hsv2rgb(fragHSV);
                         }

                         void main()
                         {
                             vec2 uv   = qt_TexCoord0.xy;
                             vec4 copy = texture2D(source, qt_TexCoord0.st).rgba;        //get rgba
                             vec4 orig = texture2D(value , qt_TexCoord0.st).rgba;        //get rgba

                             if(uv.x < dividerValue) {
                                 orig.xyz = desat(blendColorDodge(orig.xyz, invert(copy.xyz)));
                             }
                             else
                                 orig.xyz = copy.xyz;

                             gl_FragColor = orig * qt_Opacity;
                         }"

    }

    ShaderEffectSource {
        id : contrastSource
        hideSource : true
        smooth : true
        recursive : true
        sourceItem : blender
    }
    ShaderEffect {
        id : contrastEffect
        anchors.fill: parent
        property variant source : contrastSource
        property real    value : typeof contrast !== 'undefined' ? contrast : 0
        property real dividerValue : typeof dividerValue !== 'undefined' ? dividerValue : 1
        fragmentShader : "
                         #ifdef GL_ES
                             precision mediump float;
                         #else
                         #   define lowp
                         #   define mediump
                         #   define highp
                         #endif // GL_ES

                        uniform float dividerValue;
                        uniform float value;

                        uniform sampler2D source;
                        uniform lowp float qt_Opacity;
                        varying vec2 qt_TexCoord0;

                        void main()
                        {
                            vec2 uv = qt_TexCoord0.xy;
                            vec4 color = texture2D(source, qt_TexCoord0.st);
                            if (uv.x < dividerValue) {
                                color = color * (1.0 + value/1.0);
                            }
                            gl_FragColor = color;
                        }"
    }






}
