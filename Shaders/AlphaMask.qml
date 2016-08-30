import QtQuick 2.4
Effect {
    id : rootObject
    fragmentShaderName  : "alphaMask.fsh"
    property var mask
    property real maskStrength : 1
    property bool alphaChannelMask : false
    hideSource: true
}



