import QtQuick 2.0
Item {
    property alias source       : edgeDetectSoruce.sourceItem
    property alias chainPtr     : edgeDetect
    property real  value        : 0.4
    property alias dividerValue : edgeDetect.dividerValue

    width  : source === null || typeof source === 'undefined' ? 0 : source.paintedWidth ? source.paintedWidth  : source.width
    height : source === null || typeof source === 'undefined' ? 0 : source.paintedWidth ? source.paintedHeight : source.height

    ShaderEffectSource {
        id : edgeDetectSoruce
        hideSource : true
        smooth : true
        anchors.fill: parent
    }
    Effect {
        id : edgeDetect
        anchors.fill: parent
        source : edgeDetectSoruce
        fragmentShaderName : "edgedetect.fsh"
        property real min : 0
        property real max : ( 1 - value)
    }
}



