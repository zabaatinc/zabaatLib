import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0


Item
{
    width: 100
    height: 40

    property string txt: "BUTTON"
    property string containerColor: "#b33f3f40"
    property string fillColor: "#19181c"  // activeFillColor
    property string txtColor: "#f1f1f2"  //  activeTextColor
    property string pressedBorder: "#40ffffff"
    property string activeBorder:  "#92b957"
    property string pressedFill: "#000000"
    property string glowColor: "#000000"
    property string buttonColor: "#404041"
    property string disabledBorderDay: "#99404041"
    property string disabledBorder: "#cca7a9ab"

    property bool day: false

    RectangularGlow
    {
        id: effect
        anchors.fill: container
        glowRadius:3
        spread: .4
        color: glowColor
        cornerRadius: 4
        opacity: 1
    }

    Rectangle
    {
        id: container
        width: 100
        height: 40
        color: containerColor
        border.width: 1
        radius: 3
        border.color: disabledBorder



    //    property string dayTxtColor: "#19181c"
    //    property string dayFillColor: "#e6e7e8"
    //    property string dayPressedBorder: "#8019181c"
    //    property string dayGlowColor: "#8019181c"

        Image
        {
            id: leftImage
            source: (day) ? "qrc:images/icoOnDisabledDay.png" : "qrc:images/icoOnDisabled.png"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
        }

        Image
        {
            id: rightImage
            source: (day) ? "qrc:images/icoOffDisabledDay.png" : "qrc:images/icoOffDisabled.png"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 10
        }

        RectangularGlow
        {
            id: effect1
            anchors.fill: button
            glowRadius:3
            spread: .4
            color: glowColor
            cornerRadius: 4
            opacity: 1
        }


        Rectangle
        {
            id: button
            width: 42
            height: 32
            x: 4
            color:buttonColor
            anchors.verticalCenter: parent.verticalCenter
            border.width: 1
            border.color: disabledBorder
            radius: 2
            smooth: true
            state: "DAY"

            property bool day: false


            Image
            {
                id: image
                source: (day) ? "qrc:images/icoOnActiveDay.png" : "qrc:images/icoOnActive.png"
                anchors.centerIn: parent
            }

            MouseArea
            {
                id: ma
                anchors.fill: parent
                onClicked:
                {
                    if (button.state == "DAY")
                        button.state = "NIGHT"
                    else
                        button.state = "DAY"
                }
    //            onReleased:
    //            {
    //                if (button.state == "NIGHT")
    //                    button.state = "DAY"
    //                else
    //                    button.state = "NIGHT"
    //            }
            }

            states:
                [
                    State
                    {
                        name: "DAY"
                        PropertyChanges { target: button; x: 4 }
                    },

                    State
                    {
                        name: "NIGHT"
                        PropertyChanges { target: button; x: 54 }
                        PropertyChanges { target:button; day: false }
                        PropertyChanges { target: image; source: (day) ? "qrc:images/icoOffActiveDay.png" : "qrc:images/icoOffActive.png" }
                    }
                ]
            transitions:
                Transition
                {
                    ParallelAnimation
                    {
                        NumberAnimation { properties: "x"; easing.type: Easing.InOutQuad; duration: 200; }
                        NumberAnimation { properties: "source";  easing.type: Easing.InOutQuad; duration: 50; }
                    }
                }
        }
    }
}
