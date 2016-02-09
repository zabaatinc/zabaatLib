import Zabaat.Material 1.0 as M
import QtQuick 2.4
//import QtGraphicalEffects 1.0
import "helpers"
//Default button, flat style
M.ZSkin {
    id : rootObject
    property alias graphical : graphical

    color         : "transparent"
    focus         : true
    onLogicChanged:if(logic)
                       logic.containsMouse = Qt.binding(function() { return knob.containsMouse })
    onStateChanged: {
        graphical.state = "reload"
        graphical.state = ""
    }
    onActiveFocusChanged: {
        if(activeFocus && graphical.state !== "press")  graphical.state = "focus"
        else if(graphical.state === "focus")            graphical.state = ""
    }

    Rectangle {
        id : bar
        width : parent.width
        height: Math.max(parent.height/8 , M.Units.dp(15))
        color : logic && logic.isOn ? graphical.fill_onColor : graphical.fill_offColor
        radius: height/2
        anchors.centerIn: parent

        Knob {
            id : knob
            onReleased: logic.toggle()
            height : bar.height * 1.6
            x      : logic && !logic.isOn ? 0 - width/2 : bar.width - width/2
            color     : logic && logic.isOn ? M.Colors.getContrastingColor(graphical.fill_onColor,1.3) : M.Colors.getContrastingColor(graphical.fill_offColor,1.3)
            inkColor  : logic && !logic.isOn ? M.Colors.getContrastingColor(graphical.fill_onColor,1.3) : M.Colors.getContrastingColor(graphical.fill_offColor,1.3)
            spillColor: inkColor
            anchors.verticalCenter: bar.verticalCenter
            transformOrigin: Item.Center
            Behavior on x { NumberAnimation { duration : logic ? logic.duration : 0} }
        }

    }
    Item {
        id : graphical
        property color fill_onColor    : M.Colors.success
        property color fill_offColor   : "darkGray"
        property color inkColor        : logic && logic.isOn ? fill_offColor : fill_onColor

        states :[
            State {
                name : ""
                PropertyChanges {
                    target: graphical;
//                    fill_onColor : M.Colors.accent
                }
            },
            State {
                name : "focus"

            },
            State {
                name : "press"

            } ,
            State { name : "reload" }
        ]
    }

    states : ({
        "default"  : { "rootObject": {  "border.width" : 0,
                                        "radius" : 0,
                                        "@width" : [parent,"width"],
                                        "@height": [parent,"height"],
                                        rotation : 0
                                     } ,
                       graphical :   {  "@fill_onColor"  : [M.Colors,"success"] ,
                                        "@fill_offColor" : "darkGray"
                                     }
        } ,
        "disabled" : {  graphical :  {  "@fill_onColor"  : [M.Colors,"success"] ,
                                        "@fill_offColor" : "darkGray"
                                     }
        }
    })



}
