import QtQuick 2.0
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0


Item {
    width: 50
    height: 304

    property bool day: false

    property string containerColor: "#b33f3f40"
    property string centerlineColor: "#000000"
    property string tickColor: "#0000000"
    property string imgSource: (day) ? "images/bubbleDaySide.png" : "images/bubbleNightSide.png"
    property string txt1: fill.height
    property string txt2: fill.height/2
    property string txtColor: "#f1f1f2"  //  activeTextColor
    property string fillBorder: "#000000"
    property int fillHeight: 246
    property string glowColor: "#000000"

    RectangularGlow
    {
        id: effect
        anchors.fill: container
        glowRadius: 2
        spread: .4
        color: glowColor
        cornerRadius: 4
        opacity: 1
    }

    Rectangle
    {
        id: container
        height: 300
        width: 25
        anchors.centerIn: parent
        color: containerColor
        radius: 3
        border.width: 1
        border.color: fillBorder

        Rectangle
        {
            id: centerline
            height: 275
            width: 2
            anchors.centerIn: parent
            color: centerlineColor
        }

        Item
        {
            id: ticks
            anchors.centerIn: parent

            Column
            {
                x: -22
                y: -105
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 28.5

                Repeater
                {
                    model: 10

                    Rectangle
                    {
                        width: 15
                        height: 2
                        color: tickColor
                    }
                }
            }
        }

        Rectangle
        {
            id: fill
            y: 242
            width: 4
            rotation: 180
            height: fillHeight
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#92b957"
            anchors.bottomMargin: 12
            anchors.bottom: parent.bottom
            radius: 2



            Image
            {
                id:topBubble
                source: imgSource
                rotation: 0
                anchors.right: parent.left
                anchors.rightMargin:8
                anchors.verticalCenter: parent.bottom
                visible: false

                Text
                {
                    id: bubbleTextTop
                    color: txtColor
                    text: fill.height
                    anchors.verticalCenterOffset: 0
                    rotation:180
                    verticalAlignment: Text.AlignVCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenterOffset: -3
                    font.family: "Helvetica Neue"  //  systemFont
                    font.pixelSize: 14  //  fontSizeMedium
                    font.weight: Font.Light  //  fontWeightSkinny
                }
            }

            Glow
            {
                anchors.fill: topBubble
                source: topBubble
                radius:8
                samples:8
                color: glowColor
                opacity: 1
            }

            Image
            {
                id: middleBubble
                source: imgSource
                rotation: 180
                anchors.left: parent.right
                anchors.leftMargin:8
                anchors.verticalCenter: parent.verticalCenter
                visible: false

                Text
                {
                    id: bubbleTextMiddle
                    color: txtColor
                    text: txt2
                    anchors.verticalCenterOffset: 0
                    rotation:0
                    verticalAlignment: Text.AlignVCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenterOffset: -3
                    font.family: "Helvetica Neue"  //  systemFont
                    font.pixelSize: 14  //  fontSizeMedium
                    font.weight: Font.Light  //  fontWeightSkinny
                }
            }

            Glow
            {
                anchors.fill: middleBubble
                source: middleBubble
                radius: 4
                rotation: 180
                samples: 8
                color: glowColor
                opacity: 1
            }
        }
    }
}
