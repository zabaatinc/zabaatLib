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

    focus : true
    activeFocusOnTab: true
//    onActiveFocusChanged: console.log(rootObject, "focus=", activeFocus)

    color           : graphical["fill_" + graphicalState]
    border.color    : graphical.borderColor
    anchors.centerIn: parent
    onLogicChanged  : if(logic) {
                          logic.containsMouse = Qt.binding(function() { return inkArea.containsMouse })

                      }

    property string graphicalState : activeFocus ?  "Focus"  : "Default"

    Keys.onPressed:  {
        if(event.key == Qt.Key_Enter || event.key == Qt.Key_Return || event.key == Qt.Key_Space){
            inkArea.simulatePress();
            event.accepted = true;
        }
    }
    Keys.onReleased: {
        if(event.key == Qt.Key_Enter || event.key == Qt.Key_Return || event.key == Qt.Key_Space){
            inkArea.simulateRelease(true);
            event.accepted = true;
        }
    }


    Item {
        anchors.fill: parent
        Image {
            id: img
            anchors.fill: parent
            fillMode    : Image.PreserveAspectFit
            visible     : rootObject.radius === 0 ?  true : false
            source      : logic ? logic.source : ""
        }
        Rectangle {
            id : mask
            visible : rootObject.radius !== 0 ?  true : false
            anchors.fill: parent
            radius : rootObject.radius
        }
        OpacityMask {
            visible : rootObject.radius !== 0 ?  true : false
            anchors.fill: parent
            source : img
            maskSource: mask
        }
    }


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
        opacity : graphical.inkOpacity * 0.5
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
                    textContainer : { rotation : 0 }
//                    graphical     : { inkOpacity : 0.5 }
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
