uniform float dividerValue;
uniform lowp float qt_Opacity;
varying vec2 qt_TexCoord0;
uniform vec4 color;

void main()
{
    gl_FragColor = vec4(0,0,0,1) * qt_Opacity;
}
