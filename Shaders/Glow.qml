import QtQuick 2.5
Item {
    id : rootObject
    anchors.centerIn: source
    width : source ? source.width + value : 0
    height : source ? source.height + value : 0

    property var source   : null
    property real value   : 2
    readonly property var chainPtr : blur.chainPtr
    property alias  dividerValue : blur.dividerValue
    property bool hideSource : false

    Blur {
        id : blur
        anchors.fill: parent
        source : rootObject.source
        hideSource : rootObject.hideSource
        value : Math.sin(logic.time) * rootObject.value
    }

    Item {
        id : logic
        property real time  : 0
        NumberAnimation on time { loops : Animation.Infinite; from : 0 ; to :Math.PI * 2; duration : 600 }
    }



}
