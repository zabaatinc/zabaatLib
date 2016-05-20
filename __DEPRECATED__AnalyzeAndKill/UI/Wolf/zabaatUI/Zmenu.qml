import QtQuick 2.2
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0


Item
{
    id: menu
    visible: true
    width: 1050
    height: 125


    property string glowColor: "#000000"
    property string dayGlowColor: "#8019181c"
    property string fillColor: "#19181c"  // activeFillColor

    Item
    {
        anchors.fill: parent

        Image
        {
            source: "images/menu.png"
            x: -10
            anchors.horizontalCenter: parent.horizontalCenter
        }


        Column
        {
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            spacing: 2

            Repeater
            {
                model: 3

                Rectangle
                {
                    id: clickers
                    width: 70
                    height: 1
                    color: "#a9a9aa"

                    MouseArea
                    {
                        enabled: true
                        width: 100
                        height: 4
                        anchors.horizontalCenter: parent.horizontalCenter
                        drag.target: menu
                        drag.axis: Drag.YAxis
                        drag.minimumY: -65
                        drag.maximumY: -10
                        onPressed: clickers.color = "#92b957"
                        onReleased: clickers.color = "#a9a9aa"
                    }
                }
            }
        }


    }


    Grid
    {
        id: grid1
        spacing: 100
        anchors.left:parent.left
        anchors.leftMargin:115
        anchors.top: parent.top
        anchors.topMargin: 5

        Column
        {
            Row
            {
                spacing: 20
                Image
                {
                    id: dash
                    source: "images/menuDashOff.png"

                    MouseArea
                    {
                        anchors.fill: parent
                        onPressed: dash.source = "images/menuDashOn.png"
                        onReleased: dash.source = "images/menuDashOff.png"
                    }
                }
                Image
                {
                    id: tune
                    source: "images/menuTuneOff.png"

                    MouseArea
                    {
                        anchors.fill: parent
                        onPressed: tune.source = "images/menuTuneOn.png"
                        onReleased: tune.source = "images/menuTuneOff.png"
                    }
                }
                Image
                {
                    id: diag
                    source: "images/menuDiagOff.png"

                    MouseArea
                    {
                        anchors.fill: parent
                        onPressed: diag.source = "images/menuDiagOn.png"
                        onReleased: diag.source = "images/menuDiagOff.png"
                    }
                }
                Image
                {
                    id: admin
                    source: "images/menuAdminOff.png"

                    MouseArea
                    {
                        anchors.fill: parent
                        onPressed: admin.source = "images/menuAdminOn.png"
                        onReleased: admin.source = "images/menuAdminOff.png"
                    }
                }
            }
        }
        Column
        {
            Row
            {
                spacing: 20
                Image
                {
                    id: alarm
                    source: "images/menuAlarmOff.png"

                    MouseArea
                    {
                        anchors.fill: parent
                        onPressed: alarm.source = "images/menuAlarmOn.png"
                        onReleased: alarm.source = "images/menuAlarmOff.png"
                    }
                }
                Image
                {
                    id: net
                    source: "images/menuNetOff.png"

                    MouseArea
                    {
                        anchors.fill: parent
                        onPressed: net.source = "images/menuNetOn.png"
                        onReleased: net.source = "images/menuNetOff.png"
                    }
                }
                Image
                {
                    id: maint
                    source: "images/menuMaintOff.png"

                    MouseArea
                    {
                        anchors.fill: parent
                        onPressed: maint.source = "images/menuMaintOn.png"
                        onReleased: maint.source = "images/menuMaintOff.png"
                    }
                }
                Image
                {
                    id: settings
                    source: "images/menuSettingsOff.png"

                    MouseArea
                    {
                        anchors.fill: parent
                        onPressed: settings.source = "images/menuSettingsOn.png"
                        onReleased: settings.source = "images/menuSettingsOff.png"
                    }
                }
            }
        }
    }
}
