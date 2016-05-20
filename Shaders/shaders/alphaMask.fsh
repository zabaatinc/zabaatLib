//http://wp.applesandoranges.eu/?p=14

uniform sampler2D source;
uniform vec4 sourceDim;
uniform sampler2D mask;
uniform vec4 maskDim;

varying vec2       qt_TexCoord0;
uniform lowp float qt_Opacity;
uniform float      dividerValue;
uniform float      value;


void main()
{
    vec2 uv = qt_TexCoord0.xy;

    //xyzw in a vec4
//    float xRatio = sourceDim.z / maskDim.z;
//    float yRatio = sourceDim.y / sourceDim.y;

    vec2 scaleRatio ;
    scaleRatio.x = sourceDim.z / maskDim.z;
    scaleRatio.y = sourceDim.w / maskDim.w;

    vec2 scroll = vec2(sourceDim.x - maskDim.x, sourceDim.y - maskDim.y) * scaleRatio;



    gl_FragColor = qt_Opacity;
}
