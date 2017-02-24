uniform sampler2D source;
uniform lowp float qt_Opacity;
uniform lowp float startX;
uniform lowp float startY;
uniform lowp float endX;
uniform lowp float endY;
varying vec2 qt_TexCoord0;
void main()
{
    vec2 start = vec2(startX,startY);
    vec2 end   = vec2(endX, endY);

    vec2 uv   = qt_TexCoord0.xy;
    float myX = (end.x - start.x) * uv.x + start.x;
    float myY = (end.y - start.y) * uv.y + start.y;

    gl_FragColor = qt_Opacity * texture2D(source, vec2(myX,myY));
}
