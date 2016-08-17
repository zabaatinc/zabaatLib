import QtQuick 2.5
import Zabaat.Material 1.0
import QtGraphicalEffects 1.0
//The goal of this component is to make using ZInk as easy as possible.

Item {
    id : rootObject
    anchors.fill: parent

    //Most useful things ///////////////////////////////////////////////
    signal pressed(int x, int y, int buttons);
    signal clicked(int x, int y, int buttons);
    signal doubleClicked(int x, int y, int buttons);
    readonly property var containsMouse : !item ? false : item.containsMouse
    readonly property var isPressed     : !item ? false : item.isPressed
    ////////////////////////////////////////////////////////////////////

    //Properties   //////////////////////////////////////////////////////////////////////
    property var   acceptedButtons    : Qt.AllButtons
    property color color : {
        if(target){
            if(target.inkColor)
                return target.inkColor
            else if(target.graphical && target.graphical.inkColor)
                return target.graphical.inkColor
            else if(target.color) {
                return Colors.getContrastingColor(target.color)
            }
        }
        return Colors.accent
    }

    property bool  inkDiesOutSide     : false               //Determines if ink auto dies
    property int   inkSurvivalInterval: 500                 //after this value in milliseconds

    property bool  allowDoubleClicks  : true                    //If we don't allow double clicks
    property int doubleClickInterval  : 200  //we don't have to wait this amount
    ///////////////////////////////////////////////////////////////////////////////////////


    //Shouldn't have to touch these normally    /////////////////////////////////////////
    property int radius  : target && target.radius ? target.radius : 0
    property var target  : parent ? parent : null
    onTargetChanged: {
       if(target !== null && target !== parent){
           parent = target // change parent. GTetin here
           anchors.fill = parent
       }
    }
    //////////////////////////////////////////////////////////////////////////////////////
    readonly property var simulatePress   : item && item.functionPress   ? item.functionPress   : loader.functionPress
    readonly property var simulateRelease : item && item.functionRelease ? item.functionRelease : loader.functionRelease


    //Opacity mask is only used if target has a radius && opacity has a value > 0
    Loader  {
        id : loader
        anchors.fill   : parent
        sourceComponent: parent.opacity > 0 ? inkCmp : noninkCmp

        function functionPress(){
            rootObject.pressed(width/2,height/2,Qt.LeftButton)
        }

        function functionRelease(){
            rootObject.clicked(width/2,height/2,Qt.LeftButton)
        }
    }

    property var item : loader && loader.item && loader.item.ma ? loader.item.ma : null

    Component {
        id : inkCmp
        Item {
            id : visibleInkSect
            anchors.fill: parent
            property var radius: rootObject && rootObject.radius ? rootObject.radius : 0
            property alias ma : ma

            Rectangle {
                id          : mask;
                anchors.fill: parent;
                radius      : rootObject.radius;
                visible     : false;
            }
            ZInk {
                id      : ink;
                color   : rootObject.color
                msArea  : ma;
                visible : rootObject.radius > 0 ? false : true;
            }
            MouseArea {
                id : ma
                anchors.fill: parent
                hoverEnabled: true
                property bool isPressed : false;
                property bool mouseIsIn : false;
                property point coords : Qt.point(mouseX, mouseY)

                function functionPress() {
//                    console.log("@ 1 @")
                    ink.tap();
                    rootObject.pressed(coords.x,coords.y,pressedButtons);
                    isPressed = true;
                }
                function functionRelease(hasMouse){
                    ink.lockMouse()

                    if(hasMouse === null || typeof hasMouse === 'undefined')
                        hasMouse = containsMouse

                    if(hasMouse){
                        if(clickWaitTimer.running){
                            clickWaitTimer.stop()
                            ink.end("grow", rootObject.doubleClicked, coords.x, coords.y, pressedButtons);
                        }
                        else {
                            if(allowDoubleClicks){
                                clickWaitTimer.btn = pressedButtons
                                clickWaitTimer.start()
                            }
                            else {
        //                        console.log("CHANGING")
                                ink.end("grow",rootObject.clicked, coords.x,coords.y, pressedButtons);
                            }
                        }
                    }
                    else {
                        ink.end("shrink")
                    }
                    isPressed = false;
                }


                onPressed : functionPress();
                onReleased: functionRelease();
                onEntered : mouseIsIn = true;
                onExited  : mouseIsIn = false;
                onCanceled: ink.end("shrink")
                onMouseIsInChanged: if(inkDiesOutSide) {
                                        if(!mouseIsIn)  killTimer.start()
                                        else            killTimer.stop()
                                    }
            }

            OpacityMask {
                anchors.fill: mask
                source      : ink
                maskSource  : mask
        //        opacity     : 0.5
                visible     : parent.radius > 0 ? true : false;
            }
            Timer {
                id : clickWaitTimer;  interval : rootObject.doubleClickInterval;  repeat: false;
                property int btn : -1
                property point coords : Qt.point(0,0)
                onTriggered  : {
                    ink.end("grow",rootObject.clicked, coords.x, coords.y, btn);
                }
            }
            Timer { id : killTimer;  interval : rootObject.inkSurvivalInterval; repeat : false; onTriggered: ink.end("shrink"); }

            Rectangle {     //just so we can have clear outlines
                anchors.fill: parent
                radius      : mask.radius
                color       : "transparent"
                visible     : false//radius > 0 && border.width > 0
                border.width: {
                    if(target){
                        if(target.border && target.border.width)   return target.border.width
                        else if(target.borderWidth)                return target.borderWidth
                    }
                    return 0;
                }
                border.color: {
                    if(target){
                        if(target.border && target.border.color)  return target.border.color
                        else if(target.borderColor)               return target.borderColor
                        else if(target.outlineColor)              return target.outlineColor
                    }
                    return "black"
                }
        //        Text {
        //            anchors.fill: parent
        //            text : parent.border.width
        //        }
            }


        }

    }

    Component {
        id: noninkCmp
        Item {
            id : invisibleInk
            anchors.fill: parent
            property alias ma : ma2
            MouseArea {
                id: ma2
                anchors.fill: parent
                hoverEnabled: true;
                acceptedButtons: rootObject.acceptedButtons
                onPressed : rootObject.pressed(mouseX,mouseY,pressedButtons)
                onClicked : rootObject.clicked(mouseX,mouseY,pressedButtons)
                onDoubleClicked: rootObject.doubleClicked(mouseX,mouseY,pressedButtons)
            }

        }
    }



}
