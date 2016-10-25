import Zabaat.Material 1.0 as M
import QtQuick 2.4
//import QtGraphicalEffects 1.0
import "helpers"
//Default button, flat style
M.ZSkin {
    id : rootObject
//    property alias graphical : graphical
    property alias knob : knob

    color         : graphical.fill_Empty
    focus         : true
    onLogicChanged:if(logic)
                       logic.containsMouse = Qt.binding(function() { return knob.containsMouse })

    onActiveFocusChanged: {
        if(activeFocus && graphicalState !== "Press")  graphicalState = "Focus"
        else if(graphicalState === "Focus")            graphicalState = "Default"
    }

    property string graphicalState : "Default" //Press, Fill

    Rectangle {
        id : bar
        width : parent.width
        height: parent.height * 0.8
        color : logic && logic.isOn ? graphical.fill_Default : graphical.disabled2
        radius: height/2
        anchors.centerIn: parent

        property alias knob : knob

        Knob {
            id : knob
            onReleased: logic.toggle()
            height : bar.height * 1.6
            x      : logic && !logic.isOn ? 0 - width/2 : bar.width - width/2
            color     : logic && logic.isOn ? M.Colors.getContrastingColor(graphical.fill_Default,1.3) : M.Colors.getContrastingColor(graphical.disabled2,1.3)
            inkColor  : logic && !logic.isOn ? M.Colors.getContrastingColor(graphical.fill_Default,1.3) : M.Colors.getContrastingColor(graphical.disabled2,1.3)
            spillColor: inkColor
            anchors.verticalCenter: bar.verticalCenter
            transformOrigin: Item.Center
            Behavior on x { NumberAnimation { duration : logic ? logic.duration : 0} }
        }

    }

    states : ({
        "default"  : { "rootObject": {  "border.width" : 0,
                                        "radius" : 0,
                                        "@width" : [parent,"width"],
                                        "@height": [parent,"height"],
                                        rotation : 0
                                     },
                      "graphical" : {
                          "@fill_Default" : [M.Colors, "success"]
                      }
         }
    })



}
