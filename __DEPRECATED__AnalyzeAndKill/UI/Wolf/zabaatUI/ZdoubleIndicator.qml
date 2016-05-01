import QtQuick 2.2
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0


Rectangle
{
    width: 200
    height: 40
    radius: 3

    property string leftTxt: "READY"
    property string rightTxt: "WAIT"
    property string maskColor: "#19181c"  //  nightMaskColor
    property string txtColor: "#f1f1f2"  //  activeTextColor
    property string fillColor: "#19181c"  // activeFillColor
    property string pressedBorder: "#40ffffff"
    property string activeBorder:  "#92b957"
    property string pressedFill: "#19181c"
    property string glowColor: "#000000"
    property string disabledBorder: "#cca7a9ab"
    property string readyColor: "#92b957"
    property string waitColor: "#ed1c24"

    property bool ready: true
    property bool wait: false

//    property string dayTxtColor: "#19181c"
//    property string dayFillColor: "#e6e7e8"
//    property string dayPressedBorder: "#8019181c"
//    property string dayGlowColor: "#8019181c"



    Item
    {
        anchors.fill: parent
        anchors.centerIn: parent

        RectangularGlow
        {
            id: effect
            anchors.fill: indicator
            glowRadius:3
            spread: .4
            color: glowColor
            cornerRadius: 4
            opacity: 1
        }

        Rectangle
        {
            id: indicator
            anchors.fill: parent
            color: fillColor
            border.width: 1
            border.color: disabledBorder
            radius: 3
            smooth: true
            state: "NORMAL"


//            MouseArea
//            {
//                id: ma
//                anchors.fill: parent
//                visible: (clickable) ? true : false
//                onPressed:
//                {
//                    if (indicator.state == "READY")
//                        indicator.state = "WAIT"
//                    else
//                        indicator.state = "READY"
//                }
//                onReleased:
//                {
//                    if (indicator.state == "WAIT")
//                        indicator.state = "READY"
//                    else
//                        indicator.state = "WAIT"
//                }
//            }



//            states:
//                [
//                State
//                {
//                    name: "NORMAL"
//                    PropertyChanges { target: readout; color: fillColor }
//                    PropertyChanges { target: readout; border.color: (clickable) ? activeBorder : disabledBorder }  //  nightPressedColor
//                    PropertyChanges { target: readoutText; color: txtColor }
//                    PropertyChanges { target: valText; color: txtColor }
//                },

//                State
//                {
//                    name: "PRESSED"
//                    PropertyChanges { target: readout; color: pressedFill }
//                    PropertyChanges { target: readout; border.color: (clickable) ? pressedBorder : disabledBorder }  //  nightPressedColor
//                    PropertyChanges { target: readoutText; color: pressedBorder }
//                    PropertyChanges { target: valText; color: pressedBorder }
//                    when: ma.pressed && clickable
//                }
//            ]
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
        id: leftText
        text: leftTxt
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        font.family: "Helvetica Neue"  //  systemFont
        font.pixelSize: 14  //  fontSizeMedium
        font.weight: Font.Light  //  fontWeightSkinny
        color: (ready) ? readyColor: disabledBorder
    }

    Text
    {
        id: rightText
        text: rightTxt
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.Alignright
        verticalAlignment: Text.AlignVCenter
        font.family: "Helvetica Neue"  //  systemFont
        font.pixelSize: 14  //  fontSizeMedium
        font.weight: Font.Light  //  fontWeightSkinny
        color: (wait) ? waitColor : disabledBorder
    }
}
