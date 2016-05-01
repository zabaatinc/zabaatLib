import QtQuick 2.0
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0

Item
{
    height: 71
    width: 213

    property bool day: false
    property string txt: fill.width-14
    property string gradient: "#023008"
    property int dragMin: 2
    property int dragMax:container.width-12
    property string maskColor: "#19181c"  //  nightMaskColor
    property string disabledColor: "#b3404041"
    property string buttonBorder: "#ffffff"
    property string buttonColor: "#0000000"
    property string fillBorder: "#000000"
    property string containerColor: "#b33f3f40"
    property string image: "images/buttonNight.png"
    property string txtColor: "#f1f1f2"  //  activeTextColor
    property int containerWidth: 200
    property string glowColor: "#000000"

    Image
    {
        source: (day) ? "images/bubbleDay.png" : "images/bubbleNight.png"
        x: fill.width-31

        Text
        {
            id: bubbleText
            text: txt
            verticalAlignment: Text.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -2
            font.family: Style.fontFam
//            font.pixelSize: Style.fontMed
            font.weight: Font.Light  //  fontWeightSkinny
            color: txtColor
        }
    }

    RectangularGlow
    {
        id: effect
        anchors.fill: container
        glowRadius:3
        spread: .4
        color: Style.glowColor
        cornerRadius: 5
        opacity: 1
    }

    Rectangle
    {
        id: container
        height: 10
        color: Style.containerColor
        width: containerWidth
        border.color: fillBorder
        y: 50
        radius: 5
        border.width: 1

        Rectangle
        {
            id: fill
            height: 6
            radius: 3
            x: 2
            width: button.x + 12
            color: Style.systemColor
            anchors.verticalCenter: parent.verticalCenter

            gradient:
                Gradient
                {
                    GradientStop
                    {
                        id:stop1
                        position: 0
                        color:gradient
                    }
                    GradientStop
                    {
                        id:stop2
                        position: .5
                        color: "#92b957"
                    }
                    GradientStop
                    {
                        id:stop3
                        position: 1
                        color:gradient
                    }
                }
        }

        Rectangle
        {
            id: button
            width: 24
            height:24
            color: "#00000000"
            border.color: buttonBorder
            border.width: 1
            radius:12
            anchors.verticalCenter: parent.verticalCenter

            Rectangle
            {
                id: mask
                anchors.centerIn: parent
                color: maskColor
                width: 4
                height: 24
            }

            OpacityMask
            {
                maskSource: mask
            }

            Rectangle
            {
                height: 14
                width: 14
                radius: 7
                color: buttonColor
                border.color: buttonBorder
                border.width: 1
                x: 2
                anchors.centerIn: parent
            }


            MouseArea
            {
                id: ma
                height: 20
                width: 20
                enabled: true
                drag.target: button
                drag.minimumX: dragMin
                drag.maximumX: dragMax
                onPressed: button.scale = 1.25
                onReleased: button.scale = 1
            }
        }
    }
}
