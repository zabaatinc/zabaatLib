uniform lowp sampler2D fill;
uniform lowp sampler2D source; // this item
uniform lowp float qt_Opacity; // inherited opacity of this item
varying vec2 qt_TexCoord0;
uniform vec4 dim;
void main() {
    vec4 p = texture2D(source, qt_TexCoord0);
    vec4 r = texture2D(fill, qt_TexCoord0);
    vec2 uv = qt_TexCoord0.xy;
    bool isTransparent = p.rgba == vec4(0.0);
    if(!isTransparent && uv.x > dim.x && uv.x <  dim.z && uv.y > dim.y && uv.y < dim.z) {
        p = vec4(1,1,1,1) - r;
    }
    gl_FragColor = r * qt_Opacity;
}
