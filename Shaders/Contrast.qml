import QtQuick 2.4
Item {
    property alias value        : effect.value
    property alias dividerValue : effect.dividerValue
    property alias chainPtr     : effect
    property alias source       : sourceEffect.sourceItem
//    width  : source === null || typeof source === 'undefined' ? 0 : source.paintedWidth ? source.paintedWidth  : source.width
//    height : source === null || typeof source === 'undefined' ? 0 : source.paintedWidth ? source.paintedHeight : source.height

    Effect {
        id: effect
        source                : ShaderEffectSource {
            id : sourceEffect
            hideSource : true
            smooth     : true
        }
        fragmentShaderName    : "contrast.fsh"
        anchors.fill          : parent
    }
}



