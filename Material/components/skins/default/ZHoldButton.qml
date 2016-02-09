import Zabaat.Material 1.0
import QtQuick 2.4
//import "helpers"

ZSkin {
    id : rootObject
    focus : true
    property alias graphical : graphical
    property alias font      : text.font
    color : graphical.fill_Default
    onLogicChanged: if(logic) {
                        logic.containsMouse = Qt.binding(function() { return inkArea.containsMouse })
                    }
    onStateChanged : {
        graphical.state = "reload"
        graphical.state = ""
    }
    onActiveFocusChanged: {
//        console.log(activeFocus)
        if(activeFocus && graphical.state !== "press")  graphical.state = "focus"
        else if(graphical.state === "focus")            graphical.state = ""
    }

    MouseArea {
        id : inkArea
        anchors.fill: parent
        acceptedButtons : Qt.AllButtons
        onPressed: {
            if(logic)
                logic.pressed(logic,x,y);

            if(!timer.running)
                timer.start()
        }
        onReleased: timer.stop()
   }
    Item {
        anchors.fill: parent
        clip : false
        Text {
            id : text
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment  : Text.AlignVCenter
            font.family        : logic.font1
            font.pixelSize     : parent.height * 1/4
            text               : logic.text
            color              : Colors.text1
        }
    }


    Canvas {
        id : canvas
        anchors.centerIn: parent
        width : Math.max(parent.width , parent.height) * 2
        height: width

        property real percentage : happyAnimation.running? 1 : timer.holdDuration / timer.targetDuration
        property color color     : Colors.mix(graphical.arcStartColor, graphical.arcEndColor, percentage)

        onPercentageChanged: requestPaint()
        onPaint : {
            var ctx = getContext("2d")
            ctx.save();

            ctx.clearRect(0, 0, width, width )

            ctx.strokeStyle = color
            ctx.lineWidth   = 4

            ctx.beginPath();
            ctx.arc(width/2, width/2, width/2.5, 0, (2*Math.PI) * percentage);
            ctx.stroke();

            ctx.restore();
        }
    }
    SequentialAnimation {
        id : happyAnimation
        loops : 3
        property int duration : timer.targetDuration/3
        onStarted : rootObject.color = graphical.arcEndColor
        onStopped : rootObject.color = graphical.fill_Default


        NumberAnimation {
            target : canvas
            property: "scale"
            to : 1.05
            duration : happyAnimation.duration
        }
        NumberAnimation {
            target : canvas
            property: "scale"
            to : 1.0
            duration : happyAnimation.duration
        }
    }
    Timer {
        id : timer
        interval : 10
        repeat : true
        property int targetDuration : logic ? logic.triggerDuration : 1000
        property int holdDuration   : 0
        onHoldDurationChanged: if(logic)
                                   logic.holdDuration = holdDuration
        onTriggered: {
            holdDuration += interval;
            if(logic && holdDuration >= targetDuration) {
                logic.clicked(logic, rootObject.x , rootObject.y)
                happyAnimation.start()
                stop();
            }
        }
        onRunningChanged: {
            if(!running)
                holdDuration = 0;
        }
    }
    Item  {
        id : graphical
        property color fill_Default: Colors.standard
        property color fill_Press  : Colors.accent
        property color fill_Focus  : Colors.info
        property color text_Default: Colors.text1
        property color text_Press  : Colors.text2
        property color text_Focus  : Colors.text2

        property color arcStartColor : Colors.danger
        property color arcEndColor  : Colors.success

        property color inkColor    : Colors.getContrastingColor(rootObject.color)
        property color borderColor : Colors.text1

        states: [
            State {
                name : ""
                PropertyChanges { target: rootObject; color: graphical.fill_Default }
                PropertyChanges { target: text      ; color: graphical.text_Default }
            },
            State {
                name : "focus"
                PropertyChanges { target: rootObject; color: graphical.fill_Focus   }
                PropertyChanges { target: text      ; color: graphical.text_Focus   }
            },
            State {
                name : "press"
                PropertyChanges { target: rootObject; color: graphical.fill_Press  }
                PropertyChanges { target: text      ; color: graphical.text_Press  }
            } ,
            State { name : "reload" }
        ]

    }


    states : ({
        "default" : { "rootObject": { "border.width" : 1,
                                    "@radius"        : [rootObject,"height", 0.5],
                                    "@height"        : [parent,"height"],
                                    "@width"         : [rootObject,"height"],
                                    rotation         : 0
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
                           "@arcStartColor" : [Colors,"danger"],
                           "@arcEndColor"   : [Colors,"success"],
                    },
        },

       "disabled" : { graphical : {
                           fill_Default: "gray",
                           text_Default: "darkGray",
                           fill_Press  : "gray",
                           text_Press  : "darkGray",
                           fill_Focus  : "gray",
                           text_Focus  : "darkGray",
                           inkColor    : "gray",
                           borderColor : "darkGray"
                       }
       },
       "danger"  : { graphical : {
                           "@fill_Default": [Colors,"danger"],
                           "@text_Default": [Colors,"text2"],
                           "@fill_Press"  : [Colors.darker,"danger"],
                           "@text_Press"  : [Colors,"text2"],
                           "@fill_Focus"  : [Colors,"danger"],
                           "@text_Focus"  : [Colors,"text1"],
                           "@inkColor"    : [Colors.contrasting,"danger"],
                           "@borderColor" : [Colors,"text1"],
                           "@arcStartColor" : [Colors,"info"],
                           "@arcEndColor"   : [Colors,"danger"],
                      }
       },
       "success"  : { graphical : {
                           "@fill_Default": [Colors,"success"],
                           "@text_Default": [Colors,"text2"],
                           "@fill_Press"  : [Colors.darker,"success"],
                           "@text_Press"  : [Colors,"text2"],
                           "@fill_Focus"  : [Colors,"success"],
                           "@text_Focus"  : [Colors,"text1"],
                           "@inkColor"    : [Colors.contrasting,"success"],
                           "@borderColor" : [Colors,"text1"],
                           "@arcStartColor" : [Colors,"info"],
                           "@arcEndColor"   : [Colors,"success"],
                      }
        }
    })


}
