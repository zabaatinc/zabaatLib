import QtQuick 2.4
Effect {
    id : rootObject
    property real  thickness : 1
    property color color     : 'black'
    readonly property vector2d borderRatio : Qt.vector2d(thickness/width, thickness/height)


    property bool topLine    : false;
    property bool botLine    : false;
    property bool leftLine   : false;
    property bool rightLine  : false;


    fragmentShaderName       : "outline.fsh"
    hideSource               : true

//    anchors.fill: null
//    width : source? source.width  + thickness: 100
//    height: source? source.height + thickness: 100
//    anchors.centerIn: source
}



