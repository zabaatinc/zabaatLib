import QtQuick 2.0
Item {
    id : rootObject
    property var source   : null
    property real value   : 0
    property real dividerValue     : 1
    readonly property var chainPtr : blackShader.chainPtr
    property alias hideSource      : blackShader.hideSource
    property alias hardness        : blackShader.hardness
    property alias depth           : blackShader.depth
    property color shadowColor     : "black"
    onShadowColorChanged: {
        blackShader.shadowR = shadowColor.r //+ 0.0001;
        blackShader.shadowG = shadowColor.g //+ 0.0001;
        blackShader.shadowB = shadowColor.b //+ 0.0001;
    }


    property point offset : Qt.point(3,3)
    anchors.fill: source



    Effect {
        id: blackShader
        fragmentShaderName: "black.fsh"
        anchors.fill: null
        width : rootObject.width
        height : rootObject.height
        source : rootObject.source
        dividerValue: rootObject.dividerValue
        hideSource: false
        property real hardness : 0.5
        property real depth : 1
        property real shadowR : 0
        property real shadowG : 0
        property real shadowB : 0
        x:  offset.x
        y:  offset.y
    }



}
