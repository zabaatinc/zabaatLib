import QtQuick 2.4
Effect {
    id : rootObject
//    property var   value        : ({h : 0, s : 1, v : 1})
//    property alias dividerValue : effect.dividerValue
    property var   chainPtr     : effectObj ? effectObj : this
//    property alias source       : sourceEffect.sourceItem
    fragmentShaderName  : "hsv.fsh"

//    width  : source === null || typeof source === 'undefined' ? 0 : source.paintedWidth ? source.paintedWidth  : source.width
//    height : source === null || typeof source === 'undefined' ? 0 : source.paintedWidth ? source.paintedHeight : source.height


}



