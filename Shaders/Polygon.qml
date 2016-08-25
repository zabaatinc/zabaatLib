import QtQuick 2.5
Item {
    id : root
    property color color : 'red'
//    Effect {
//        anchors.fill: parent
//        property var vertices : [Qt.point(0,0),Qt.point(1,1)]
//        vertexShaderName      : "polygon.vsh"
//        fragmentShaderName    : "polygon.fsh"
//        property vector4d color : Qt.vector4d(root.color.r,root.color.g,root.color.b,root.color.a);

//        Text {
//            text : parent.width.toFixed(1) +"," + parent.height.toFixed(1)
//            anchors.centerIn: parent
//        }
//    }
    ShaderEffect {
        anchors.fill: parent
        property vector4d color : Qt.vector4d(root.color.r,root.color.g,root.color.b,root.color.a);
        mesh : Qt.size(2,2)
        vertexShader:  "#version 130
                        uniform highp mat4 qt_Matrix;
                        uniform highp float width;
                        uniform highp float height;
                        attribute highp vec4 qt_Vertex;
                        attribute highp vec2 qt_MultiTexCoord0;
                        varying highp vec2 qt_TexCoord0;
                        void main() {

                            const vec4 vertices[1] = vec4[1](vec4(0.5 , 2, 1, 1.0)
//                                                             ,vec4(0  , 1  , 1, 1.0),
//                                                             vec4(1  , 0 , 1, 1.0),
//                                                             vec4(0  , -1 , 1, 1.0)
                                                            );
                            if(gl_VertexID == 0)
                                gl_Position = vertices[0];
                            else
                                gl_Position = qt_Matrix * qt_Vertex;
                        }"
        fragmentShader: "uniform lowp float qt_Opacity;
                        varying vec2 qt_TexCoord0;
                        uniform vec4 color;

                        void main()
                        {
                            gl_FragColor = color * qt_Opacity;
                        }"


    }
}


