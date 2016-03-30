// Vertex shader
uniform highp mat4 qt_Matrix;
attribute highp vec4 qt_Vertex;
attribute highp vec2 qt_MultiTexCoord0;
varying highp vec2 qt_TexCoord0;
uniform highp float width;
uniform highp float height;

void main(void)
{
	//gl_Position = vec4( gl_Vertex.xy, 0.0, 1.0 );
    //gl_Position = sign( gl_Position );
    //uv = (vec2( gl_Position.x, - gl_Position.y ) + vec2(1.0) ) / vec2(2.0);

	gl_Position = vec4( qt_Vertex.xy, 0.0, 1.0 );
    //gl_Position = sign( gl_Position );
    qt_MultiTexCoord0 = (vec2( gl_Position.x, -gl_Position.y ) + vec2(1.0) ) / vec2(2.0);
	
	qt_TexCoord0 = qt_MultiTexCoord0;
}


//uniform highp mat4 qt_Matrix;
//attribute highp vec4 qt_Vertex;
//attribute highp vec2 qt_MultiTexCoord0;
//varying highp vec2 qt_TexCoord0;
//uniform highp float width;
//void main() {
//	highp vec4 pos = qt_Vertex;
//	highp float d = .5 * smoothstep(0., 1., qt_MultiTexCoord0.y);
//	pos.x = width * mix(d, 1.0 - d, qt_MultiTexCoord0.x);
//	gl_Position = qt_Matrix * pos;
//	qt_TexCoord0 = qt_MultiTexCoord0;
//}