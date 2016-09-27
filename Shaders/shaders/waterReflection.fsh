uniform highp float amplitude;
uniform highp float time;
uniform sampler2D source;
varying highp vec2 qt_TexCoord0;
uniform lowp float qt_Opacity;
uniform bool flipX;
uniform bool flipY;

//http://gamedev.stackexchange.com/questions/90592/how-to-implement-this-kind-of-ripples-with-a-glsl-fragment-shader
void main() {
    vec2 uv = qt_TexCoord0.xy;
    if(flipY)
        uv.y = 1.0 - uv.y;
    if(flipX)
        uv.x = 1.0 - uv.x;

    float xoff = (0.005 * cos(time  * 3.0 + 200.0 * uv.y ) ) * amplitude;
    float yoff = ((0.3 - uv.y)/0.3) * 0.05*(1.0+cos(time  *3.0+50.0*uv.y ) ) * amplitude;
    gl_FragColor = texture2D(source, vec2(uv.x+xoff , uv.y+ yoff ));
}
