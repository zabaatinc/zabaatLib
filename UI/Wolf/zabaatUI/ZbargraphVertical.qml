import QtQuick 2.2
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0


Rectangle
{
    width: 85
    height: 300
    color: "#00000000"
    rotation: 180

//    property string valTxt: "75%"
//    property string readTxt: "FUEL LEVEL"
    property string maskColor: "#19181c"  //  nightMaskColor
    property string txtColor: "#f1f1f2"  //  activeTextColor
    property string fillColor: "#80404041"  // activeFillColor
    property string pressedBorder: "#40ffffff"
    property string activeBorder:  "#92b957"
    property string pressedFill: "#19181c"
    property string glowColor: "#000000"
    property string disabledBorder: "#cca7a9ab"

    property int units: 20

    property alias val : valText.text
    property alias text: readoutText.text


    property bool ready: true
    property bool wait: false

//    property string dayTxtColor: "#19181c"
//    property string dayFillColor: "#e6e7e8"
//    property string dayPressedBorder: "#8019181c"
//    property string dayGlowColor: "#8019181c"


    Text
    {
        id: readoutText
        x: 0
        y: 0
        color: txtColor
        rotation: 180
        text: "FUEL LEVEL"
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.Alignright
        verticalAlignment: Text.AlignVCenter
        font.family: "Helvetica Neue"  //  systemFont
        font.pixelSize: 12  //  fontSizeMedium
        font.weight: Font.Light  //  fontWeightSkinny
    }
    Text
    {
        id: valText
        x: 0
        y: 14
        rotation: 180
        color: txtColor
        text: "75%"
        anchors.horizontalCenterOffset: 0
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.Alignright
        verticalAlignment: Text.AlignVCenter
        font.family: "Helvetica Neue"  //  systemFont
        font.pixelSize: 34  //  fontSizeMedium
        font.weight: Font.Light  //  fontWeightSkinny
    }

    Item
    {
        id: stack
        y: 10

        Column
        {
            x: 0
            spacing: 2
            y: 44

            Repeater
            {
                id: repeater
                model: units

                Rectangle
                {
                    width: 85
                    height: 10
                    color: "#00000000"

                    RectangularGlow
                    {
                        id: effect
                        anchors.fill: indicator
                        glowRadius:2
                        spread: .2
                        color: glowColor
                        cornerRadius: 4
                        opacity: 1
                    }

                    Rectangle
                    {
                        id: indicator
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 65
                        height:6
                        color: fillColor
//                        border.width: 1
//                        border.color: disabledBorder
                        radius: 3
                        smooth: true
                        state: "NORMAL"
                    }
                }
            }
        }
    }
}
