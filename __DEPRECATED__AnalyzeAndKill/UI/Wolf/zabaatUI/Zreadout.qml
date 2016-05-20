import QtQuick 2.2
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0


Rectangle
{
    width: 200
    height: 40
    radius: 3
    
    property string readTxt: "READOUT"
    property string valTxt: "000"
    property string maskColor: "#19181c"  //  nightMaskColor
    property string txtColor: "#f1f1f2"  //  activeTextColor
    property string fillColor: "#19181c"  // activeFillColor
    property string pressedBorder: "#40ffffff"
    property string activeBorder:  "#92b957"
    property string pressedFill: "#19181c"
    property string glowColor: "#000000"

//    property string dayTxtColor: "#19181c"
//    property string dayFillColor: "#e6e7e8"
//    property string dayPressedBorder: "#8019181c"
//    property string dayGlowColor: "#8019181c"


    property string disabledBorderDay: "#99404041"
    property string disabledBorder: "#cca7a9ab"
    property bool clickable: true
    property bool day: false

    Item
    {
        anchors.fill: parent
        anchors.centerIn: parent

        RectangularGlow
        {
            id: effect
            anchors.fill: readout
            glowRadius:3
            spread: .4
            color: glowColor
            cornerRadius: 4
            opacity: 1
        }

        Rectangle
        {
            id: readout
            anchors.fill: parent
            color: fillColor
            border.width: 1
            border.color:  (clickable) ? activeBorder : disabledBorder
            radius: 3
            smooth: true
            state: "NORMAL"


            MouseArea
            {
                id: ma
                anchors.fill: parent
                visible: (clickable) ? true : false
                onPressed:
                {
                    if (readout.state == "NORMAL")
                        readout.state = "PRESSED"
                    else
                        readout.state = "NORMAL"
                }
                onReleased:
                {
                    if (readout.state == "PRESSED")
                        readout.state = "NORMAL"
                    else
                        readout.state = "PRESSED"
                }
            }



            states:
                [
                State
                {
                    name: "NORMAL"
                    PropertyChanges { target: readout; color: fillColor }
                    PropertyChanges { target: readout; border.color: (clickable) ? activeBorder : disabledBorder }  //  nightPressedColor
                    PropertyChanges { target: readoutText; color: txtColor }
                    PropertyChanges { target: valText; color: txtColor }
                },

                State
                {
                    name: "PRESSED"
                    PropertyChanges { target: readout; color: pressedFill }
                    PropertyChanges { target: readout; border.color: (clickable) ? pressedBorder : disabledBorder }  //  nightPressedColor
                    PropertyChanges { target: readoutText; color: pressedBorder }
                    PropertyChanges { target: valText; color: pressedBorder }
                    when: ma.pressed && clickable
                }
            ]
        }
    }

    Rectangle
    {
        id: mask
        anchors.centerIn: parent
        color: maskColor
        width: parent.width - 25
        height: parent.height + 10
    }

    OpacityMask
    {
        maskSource: mask
    }

    Text
    {
        id: readoutText
        text: readTxt
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        font.family: "Helvetica Neue"  //  systemFont
        font.pixelSize: 14  //  fontSizeMedium
        font.weight: Font.Light  //  fontWeightSkinny
        color: (clickable) ? txtColor : disabledBorder
    }

    Text
    {
        id: valText
        text: valTxt
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.Alignright
        verticalAlignment: Text.AlignVCenter
        font.family: "Helvetica Neue"  //  systemFont
        font.pixelSize: 14  //  fontSizeMedium
        font.weight: Font.Light  //  fontWeightSkinny
        color:  (clickable) ? txtColor : disabledBorder
    }
}
