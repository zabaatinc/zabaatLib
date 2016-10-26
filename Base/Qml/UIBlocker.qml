import QtQuick 2.4
Item {
    id : rootObject
    property alias font    : textThing.font
    property alias text    : textThing.text
    property alias color   : colorRect.color
    property alias textColor : textThing.color
    property bool solidBackGround : false
    property alias animSpeed : anim.duration
    property bool animated : true

    signal clicked()
    signal hovered()
    signal unhovered()

    Rectangle {
        id : colorRect
        anchors.fill: parent
        opacity : solidBackGround?  1 : 0.8
        color : 'black'
    }

    Text {
        id: textThing
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize   : Math.min(width,height) * 1/8
        textFormat : Text.RichText

        NumberAnimation {
            id : anim
            target: textThing
            property: "rotation"
            from : 0
            to : 360
            loops : Animation.Infinite
            running: rootObject.visible && rootObject.animated
            duration : 1000
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        preventStealing : true
        propagateComposedEvents: false

        onClicked : rootObject.clicked()
        onEntered : rootObject.hovered()
        onExited  : rootObject.unhovered()
    }

}
