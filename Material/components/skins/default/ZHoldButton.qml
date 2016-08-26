import Zabaat.Material 1.0
import QtQuick 2.4
//import "helpers"

ZSkin {
    id : rootObject
    focus : true
    property alias font      : text.font
    color : graphical["fill_" + graphicalState]

    property string graphicalState : "Default" //Press, Focus
    onLogicChanged: if(logic) {
                        logic.containsMouse = Qt.binding(function() { return inkArea.containsMouse })
                    }

    onActiveFocusChanged: {
//        console.log(activeFocus)
        if(activeFocus && graphicalState !== "Press")  graphicalState = "Focus"
        else if(graphicalState === "Focus")            graphicalState = "Default"
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
            anchors.fill: parent
            horizontalAlignment: graphical.text_hAlignment
            verticalAlignment  : graphical.text_vAlignment
            font.family        : logic.font1
//            font.pixelSize     : parent.height * 1/4
            text               : logic.text
            color              : graphical["text_" + graphicalState]
        }
    }


    Canvas {
        id : canvas
        anchors.centerIn: parent
        width : Math.max(parent.width , parent.height) * 2
        height: width

        property real percentage : happyAnimation.running? 1 : timer.holdDuration / timer.targetDuration
        property color color     : Colors.mix(graphical.fill_Press, graphical.fill_Focus, percentage)

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
        onStarted : graphicalState = "Focus"
        onStopped : graphicalState = "Default"


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



    states : ({
        "default" : { "rootObject": { "border.width" : 1,
                                    "@radius"        : [rootObject,"height", 0.5],
                                    "@height"        : [parent,"height"],
                                    "@width"         : [rootObject,"height"],
                                    rotation         : 0
                                   } ,
                      graphical : { text_hAlignment : Text.AlignHCenter }
        }
    })


}
