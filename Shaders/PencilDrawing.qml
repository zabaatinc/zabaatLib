//The idea is taken from the numerous ps tutorials out there that turn photos into lineart.
//Divied into 3 steps:
// create a blur, depending on radius (blurmask)
// pass the blur along to invertedDOdgeEffect . Invert the blur and use it as a "Blend layer" on the original source!
// then desaturate the image :)
import QtQuick 2.5
Item {
    id : rootObject
    anchors.fill: source

    property var source : null
    property real blur     : 0
    property real contrast : 1
    property var chainPtr : contrast.chainPtr
    property real dividerValue : 1
    property alias hideSource: blur.hideSource

    Blur {
        id : blur
        value : rootObject.blur
        anchors.fill: parent
        source : rootObject.source
        dividerValue : rootObject.dividerValue
    }

    Effect {
        id : invertDodgeBlend
        fragmentShaderName: "inverteddodgeblend.fsh"
        source : blur.chainPtr
        property variant value : rootObject.source
        anchors.fill: parent
        dividerValue : rootObject.dividerValue
    }

    Contrast {
        id : contrast
        value : rootObject.contrast
        anchors.fill: parent
        source : invertDodgeBlend.chainPtr
        dividerValue : rootObject.dividerValue
    }

}
