import QtQuick 2.0
Item {
    id : rootObject
    property var source   : null
    property real value   : 0
    readonly property var chainPtr : horizontalShader.chainPtr
    property real dividerValue : 1
    anchors.fill: source


    Effect {
        id: verticalShader
        property real value: 4.0 * rootObject.value / height
        fragmentShaderName: "gaussianblur_v.fsh"
        anchors.fill: parent
        source : rootObject.source
        dividerValue: rootObject.dividerValue
    }

    Effect {
        id: horizontalShader
        anchors.fill: parent
        property real value: 4.0 * rootObject.value / width
        fragmentShaderName: "gaussianblur_h.fsh"
        dividerValue: rootObject.dividerValue
        source: verticalShader.chainPtr
    }
}

