import QtQuick 2.0
Item {
    id : rootObject
    property alias source       : sourceEffect.sourceItem
    property alias chainPtr     : horizontalShader
    property alias dividerValue : verticalShader.dividerValue
    property real  value        : 0
    property alias __source     : horizontalShaderSource

    width  : source === null || typeof source === 'undefined' ? 0 : source.paintedWidth ? source.paintedWidth  : source.width
    height : source === null || typeof source === 'undefined' ? 0 : source.paintedWidth ? source.paintedHeight : source.height

    Effect {
        id: verticalShader
        anchors.fill:  parent
        value: 4.0 * rootObject.value / height
        fragmentShaderName: "gaussianblur_v.fsh"
        source : ShaderEffectSource {
            id : sourceEffect
            hideSource: true
            smooth : true
            recursive : true
        }
    }

    Effect {
        id: horizontalShader
        anchors.fill: parent
        value: 4.0 * rootObject.value / width
        fragmentShaderName: "gaussianblur_h.fsh"
        dividerValue: verticalShader.dividerValue
        source: ShaderEffectSource {
            id: horizontalShaderSource
            sourceItem: verticalShader
            smooth: true
            hideSource: true
            anchors.fill: parent
        }
    }
}

