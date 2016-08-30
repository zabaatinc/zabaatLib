//http://wp.applesandoranges.eu/?p=14
uniform sampler2D source;
uniform sampler2D mask;

varying vec2       qt_TexCoord0;
uniform lowp float qt_Opacity;
uniform float      dividerValue;
uniform float      maskStrength;
uniform bool       alphaChannelMask;

void main(){
    vec2 uv        = qt_TexCoord0.xy;
    vec4 pixel     = texture2D(source,qt_TexCoord0);


    if(uv.x <= dividerValue) {
        vec4 maskPixel = texture2D(mask,qt_TexCoord0);
        float maskVal  = 1.0f;

        //maskVal represents how much to mask , 0.0f being not mask at all and 1.0f being mask it all.
        if(alphaChannelMask){
            maskVal = (1.0f -  maskPixel.a);
        }
        else {
            maskVal = (3.0f - maskPixel.r - maskPixel.g - maskPixel.b)/3.0f;
        }

        maskVal  = maskVal * maskStrength;
        pixel    = pixel * (1.0f - maskVal);
    }
//    pixel.a = 0.0f;

    gl_FragColor = pixel * qt_Opacity;
}
