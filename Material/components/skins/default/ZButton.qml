import Zabaat.Material 1.0
import QtQuick 2.4
import QtGraphicalEffects 1.0
//Default button, flat style
ZSkin {
    id : rootObject

    //aliases so stateHandler can see it
//    property alias graphical     : graphical
    property alias textContainer : textContainer
    property alias font          : text.font

    color           : graphical["fill_" + graphicalState]
    border.color    : graphical.borderColor
    anchors.centerIn: parent
    onLogicChanged  : if(logic)
                          logic.containsMouse = Qt.binding(function() { return inkArea.containsMouse })

    property string graphicalState : "Default"; //Press, Focus


    ZInkArea {
        id : inkArea
        anchors.fill: parent
        color   : graphical.inkColor
        enabled : logic ? true : false;
        allowDoubleClicks: logic ? logic.allowDoubleClicks : false
        acceptedButtons: Qt.AllButtons
        onPressed:  if(logic)       logic.pressed(logic, x,y,buttons)
        onClicked:  if(logic)       logic.clicked(logic, x,y,buttons)
        onDoubleClicked : if(logic) logic.doubleClicked(logic, x,y,buttons)
        opacity : graphical.inkOpacity
        onContainsMouseChanged : {
//            if(graphical.state !== 'press')
//                graphical.state = containsMouse ? "focus" : ""
        }
    }
    Item {
        id :  textContainer
        anchors.fill: parent
        clip : true
        Text {
            id : text
            anchors.fill       : parent
            anchors.margins    : parent.height * 1/10
            horizontalAlignment: graphical.text_hAlignment
            verticalAlignment  : graphical.text_vAlignment
            font.family        : logic.font1
            font.pixelSize     : parent.height * 1/4
            text               : logic.text
            color              : graphical["text_" + graphicalState]
            textFormat         : Text.RichText
            scale              : paintedWidth > width ? width / paintedWidth : 1
        }
    }


    states : ({
        "default" : { "rootObject": { "border.width" : 0,
                                    "radius"       : 0,
                                    "@width"       : [parent,"width"],
                                    "@height"      : [parent,"height"],
                                    rotation       : 0
                                   } ,
                      "graphical" : {
                           "@fill_Default": [Colors,"standard"],
                           "@text_Default": [Colors,"text1"],
                           "@fill_Press"  : [Colors,"standard"],
                           "@text_Press"  : [Colors,"info"],
                           "@fill_Focus"  : [Colors,"info"],
                           "@text_Focus"  : [Colors,"text2"],
                           "@inkColor"    : [Colors,"accent"],
                           "@borderColor" : [Colors,"text1"],
                           inkOpacity : 1,
                           text_hAlignment : Text.AlignHCenter,
                           text_vAlignment : Text.AlignVCenter
                    },
                    textContainer : { rotation : 0 },
        },
       "diamond" : { rootObject: { "border.width": 1,
                                   "radius": 5,
                                    rotation : 45
                                 },
                     textContainer : { rotation : -45 }
       },
       "circle" : { rootObject: { "border.width": 1,
                                   "@radius": [rootObject,"height", 0.5],
                                   "@width" : [rootObject,"height"],
                                   clip: true
                  }
        },
        "raised" : { rootObject: {  "border.width": 1,
                                    radius: 5,
                   }
        }
    })


}
