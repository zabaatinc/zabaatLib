uniform highp mat4 qt_Matrix;
uniform highp float bend;
uniform highp float minimize;
uniform highp float side;
uniform highp float width;
uniform highp float height;
attribute highp vec4 qt_Vertex;
attribute highp vec2 qt_MultiTexCoord0;
varying highp vec2 qt_TexCoord0;
void main() {

    const vec4 vertices[3] = vec4[3](vec4( 0.25, -0.25, 0.5, 1.0),
                                        vec4(-0.25, -0.25, 0.5, 1.0),
                                        vec4( 0.25, 0.25, 0.5, 1.0));
    gl_Position = vertices[gl_VertexID];

}
