import QtQuick 2.4
Item {
    id : rootObject
    property var   value        : ({h : 0, s : 1, v : 1})
    property alias dividerValue : effect.dividerValue
    property alias chainPtr     : effect
    property alias source       : sourceEffect.sourceItem

    width  : source === null || typeof source === 'undefined' ? 0 : source.paintedWidth ? source.paintedWidth  : source.width
    height : source === null || typeof source === 'undefined' ? 0 : source.paintedWidth ? source.paintedHeight : source.height

    onValueChanged : set(value)
    function set(value){
        if(typeof value === null || typeof value === 'undefined')
            return

        if(typeof value.h !== 'undefined')      effect.h = value.h
        if(typeof value.s !== 'undefined')      effect.s = value.s
        if(typeof value.v !== 'undefined')      effect.v = value.v
//        console.log("CALLING SET", h, s, v)
    }

    ShaderEffectSource {
        id : sourceEffect
        hideSource : true
        smooth     : true
        anchors.fill: parent
    }


    Effect {
        id: effect
        property real h     : rootObject.value && rootObject.value.h ? value.h : 0
        property real s     : rootObject.value && rootObject.value.s ? value.s : 1
        property real v     : rootObject.value && rootObject.value.v ? value.v : 1
        fragmentShaderName  : "hsv.fsh"
        source              : sourceEffect
        anchors.fill        : parent
    }

}



