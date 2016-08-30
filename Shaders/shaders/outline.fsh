//http://wp.applesandoranges.eu/?p=14
uniform sampler2D source;
varying vec2       qt_TexCoord0;
uniform lowp float qt_Opacity;
uniform float      dividerValue;
uniform vec2       borderRatio;
uniform vec4       color;

uniform bool topLine    ;
uniform bool botLine    ;
uniform bool leftLine   ;
uniform bool rightLine  ;

void main(){
    vec2 uv        = qt_TexCoord0.xy;
    vec4 tex       = texture2D(source, qt_TexCoord0);

    if(uv.x < dividerValue) {
        float bx = borderRatio.x;
        float by = borderRatio.y;

        if(leftLine && (uv.x >= 0.0f) && (uv.x <= bx)) {    //check if leftLine is turned on and check conditions for it!!
            tex = color;
        }
        else if(rightLine && (uv.x <= 1.0f) && (uv.x >= (1.0f - bx))){
            tex = color;
        }
        else if(topLine && (uv.y >= 0.0f) && (uv.y <= by)){
            tex = color;
        }
        else if(botLine && (uv.y <= 1.0f) && (uv.y >= (1.0f - by))) {
            tex = color;
        }
        else if(bx > 0.0f && by > 0.0f){
            float alpha = 4.0f * tex.a;
            alpha -= texture2D(source, qt_TexCoord0 + vec2(bx  , 0.0f)).a;
            alpha -= texture2D(source, qt_TexCoord0 + vec2(-bx , 0.0f)).a;
            alpha -= texture2D(source, qt_TexCoord0 + vec2(0.0f, by)).a;
            alpha -= texture2D(source, qt_TexCoord0 + vec2(0.0f, -by)).a;
            if(alpha != 0.0f) {
                tex = vec4(color.rgb, 1.0f);
            }
        }

    }

    gl_FragColor = tex * qt_Opacity;
}
