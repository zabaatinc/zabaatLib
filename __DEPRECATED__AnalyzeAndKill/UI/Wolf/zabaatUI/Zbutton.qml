import QtQuick 2.2
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0



Item
{
    width: 200
    height: 100

    property alias text : buttonText.text
//    property string txt: "BUTTON"
    property string fillColor: "#19181c"  // activeFillColor
    property string txtColor: "#f1f1f2"  //  activeTextColor
    property string pressedBorder: "#40ffffff"
    property string activeBorder:  "#92b957"
    property string pressedFill: "#000000"
    property string glowColor: "#000000"

    property string dayTxtColor: "#19181c"
    property string dayFillColor: "#e6e7e8"
    property string dayPressedBorder: "#8019181c"
    property string dayGlowColor: "#8019181c"
    signal click();

    Rectangle
    {
        width: 200
        height: 40
        radius: 3

        RectangularGlow
        {
            id: effect
            anchors.fill: button
            glowRadius:5
            spread: .4
            color: glowColor
            cornerRadius: 4
            opacity: 1
        }


        Rectangle
        {
            id: button
            anchors.fill: parent
            color: fillColor
            border.width: 1
            border.color: activeBorder  //  systemColor
            radius: 3
            smooth: true
            state: "NORMAL"

            MouseArea
            {
                id: ma
                anchors.fill: parent
                onPressed:
                {

                    if (button.state == "NORMAL")
                        button.state = "PRESSED"
                    else
                        button.state = "NORMAL"

                }
                onReleased:
                {
                    if (button.state == "PRESSED")
                        button.state = "NORMAL"
                    else
                        button.state = "PRESSED"
                    click();
                }
            }

            Text
            {
                id: buttonText
                text: ""
                anchors.centerIn: parent
                font.family: "Helvetica Neue"  //  systemFont
                font.pixelSize: 14  //  fontSizeMedium
                font.weight: Font.Light  //  fontWeightSkinny
                color: txtColor
            }

            states:
                [
                    State
                    {
                        name: "NORMAL"
                        PropertyChanges { target: button; color: fillColor }
                        PropertyChanges { target: button; border.color: activeBorder }
                        PropertyChanges { target: buttonText; color: txtColor }
                    },

                    State
                    {
                        name: "PRESSED"
                        PropertyChanges { target: button; color: pressedFill }
                        PropertyChanges { target: button; border.color: pressedBorder }  //  nightPressedColor
                        PropertyChanges { target: buttonText; color: pressedBorder }
                    }
                ]
        }
    }

}







