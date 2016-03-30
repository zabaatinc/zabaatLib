import QtQuick 2.5
Effect {
    id : rootObject
    fragmentShaderName  : "radialBlur.fsh"
    property real sampleStrength : 2.2
    property real sampleDist : 1
}

