import QtQuick 2.5
Item {
    id : rootObject
    property var source   : null
    property real value   : 0
//    readonly property var chainPtr : fragmentPass.chainPtr
    property real dividerValue : 1
    property alias hideSource  : vertexPass.hideSource

    anchors.fill: source


    Effect {
        id: vertexPass
        vertexShaderName: "radialBlur.vsh"
        anchors.fill: parent
        source : rootObject.source
        dividerValue: rootObject.dividerValue
        hideSource : false
        mesh : Qt.size(1,1)
    }



    Rectangle {
        anchors.fill: parent
        color : 'transparent'
        border.width: 5
    }

//    Effect {
//        id: fragmentPass
////        width : parent.width * 4
////        height : parent.height * 4
//        anchors.fill: parent
////        property real value: 4.0 * rootObject.value / width
//        fragmentShaderName: "radialBlur.fsh"
//        dividerValue: rootObject.dividerValue
//        source: vertexPass.chainPtr
//    }



}

