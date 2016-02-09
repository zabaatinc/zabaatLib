// version 1.0
import QtQuick 2.3
import QtGraphicalEffects 1.0
import Zabaat.Misc.Global 1.0

Rectangle
{ //this root rectangle is the background of every bar and for the most part should be left alone, modify it's child rectangle

    property alias barColor: percentRect.color
    property alias showText: percentText.visible
    property bool showActualValues : false
    property double readoutGain: 1 //does a multiplier on the text of the gauge
    property int readoutDecimals:0

    //these 2 could be just one if you were careful outside of the bar and never set this variable
//    property alias _getBarWidth: percentRect.width // used to see the current width
//    property int setBarWidth: percentRect.width //only used for directly forcing the internal bar to some width

//    property var barRightAnchor:percentRect.right

//    property string derpName: "temp"
    property color maxColor   : "green"
    property color minColor   : ZGlobal.style.danger
    property int   value       : 0  //current hp
    property int   total       : 100  //total hp (defaulted to 100 for easier percent calcs?)
    property int animationTime: 0


    property alias restingColorAnimation : defaultAnimation.running
    property bool enableFancyContainer : false
    property bool enableDamageIndicator:false
    property bool enableHealIndicator:true

    //privates
    property color _borderColor: "black"


    id : rootObject
    anchors.fill:parent
    color : "grey"
    border.width: 2
    border.color: _borderColor
    radius:0
    states:
    [ //so many lines? be like clam, it will be okay Oo  :D
        State{
            name:"normal"
            PropertyChanges {
                target: rootObject
            }
        },

        State{
            name:"valueLow"
            PropertyChanges {
                restoreEntryValues: true
                target: rootObject
                border.color: ZGlobal.style.danger
            }
        },
        State{ //TODO - implement changes
            name:"moving"
            PropertyChanges{
                restoreEntryValues: true
                target:prettyEdge
                visible:true
            }
        }

    ]
    transitions:
    [
        Transition {
            from: "*"
            to: "valueLow"
            SequentialAnimation{
                loops: Animation.Infinite
                NumberAnimation {
                    target: rootObject
                    property: "border.width"
                    to:3
                    duration: 200
                    easing.type: Easing.InOutQuad
                }

                NumberAnimation {
                    target: rootObject
                    property: "border.width"
                    to: 1
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        }
    ]

    onValueChanged: {
        if (enableFancyContainer) { //TODO - make more dynamic by allowing steps colors to be passed in?
            if (total / value > 2) {
                rootObject.state = "valueLow"
            }
            else{ //alows for heals / value increase
                rootObject.state = "normal"
            }
        }
    }


    function takeDamage(amount){ //OMG WE'VE BEEN HIT!!!
        percentRect.oldWidth = percentRect.width //save old width for reference for what we are doing with our shift bar
        value -= amount; //setting value and storing
//        if (total > 0) percentRect.width = rootObject.width * (value/total) //if you were ever alive set the width of the progress bar to correct
//        else progressRect.width = 0  //you are dead so set it to 0
        if (enableDamageIndicator) damageShift.width = percentRect.oldWidth-percentRect.width
    }


    Rectangle{ //this is the bar that actually does the moving
        property int oldWidth: 0

        id:percentRect
        height : parent.height
        width: total > 0 ? rootObject.width * (rootObject.value/rootObject.total) : 0
        color:"purple" //private placeholder, set the barColor property in parent from outside instead
        radius:rootObject.radius
//        onWidthChanged:console.log("width in the percentRect changed",width,value)

        Behavior on width{
            NumberAnimation {
                duration: animationTime
            }
        }


        //resting animation of the bar if enabled
        SequentialAnimation on color
        {
            id : defaultAnimation
            loops : Animation.Infinite

            ColorAnimation
            {
                from : percentRect.color
                to   :  Qt.lighter(percentRect.color)
                duration : 1000
            }

            ColorAnimation
            {
                from : Qt.lighter(percentRect.color)
                to   : percentRect.color
                duration : 1000
            }
        }



        Rectangle{  //damage indicator bar
            //TODO - could make it reverse so that on load / heal it shows that number too?
            id:damageShift
            property string type : "damage" // "heal"
            visible: enableDamageIndicator
            anchors.left: parent.right
            height:parent.height
            width: 0
            radius:rootObject.radius
            onWidthChanged: {
                takeDamage.start()
            }
            color:type=="damage"? ZGlobal.style.danger:"dark green"  // TODO - should be green for heals and red for dmg


            Rectangle{ //this is the pretty rectangle that will glow at the edge of the bar when it moves
                id: prettyEdge
                height:rootObject.height
                width:rootObject.width/100
                anchors.left:parent.right
                radius: 4
                color: "white"
                visible: takeDamage.running

                RectangularGlow{
                    id: effect
                    anchors.fill: parent
                    glowRadius: 10
                    spread: 0.3
                    color: "white"
                    cornerRadius: parent.radius + glowRadius
                }
            }



            SequentialAnimation{
                id:takeDamage
                NumberAnimation{
                    target: damageShift
                    property: "width"
                    to: 0
                    duration: 750
                    onRunningChanged: {
                        if(running) prettyEdge.visible = true
                        else prettyEdge.visible = false
                    }
                }
            }
        }
    }

//    Component{
//        id: prettyEdge
//        Rectangle{ //this is the pretty rectangle that will glow at the edge of the bar when it moves
//            height:parent.height
//            width:parent.width/100
//            radius:4
//            color:"white"
//            visible:true

//            RectangularGlow{
//                id:effect
//                anchors.fill:parent
//                glowRadius: 10
//                spread:0.3
//                color:"white"
//                cornerRadius: parent.radius + glowRadius
//            }
//        }
//    }



    Text
    {
        id : percentText

        font : ZGlobal.style.text.normal
        anchors.centerIn: parent
        anchors.fill: parent
        horizontalAlignment : Text.AlignHCenter
        verticalAlignment : Text.AlignVCenter
        text : getPercentValue()
        visible:false

        function getPercentValue()
        {
            if(total > 0)
            {
                if(!showActualValues)
                    return (value/total * 100).toFixed(readoutDecimals) + "%"
                else
                    return (value*readoutGain).toFixed(readoutDecimals) + "/" +  (total*readoutGain).toFixed(readoutDecimals)
            }
            return 0
        }
    }


}
