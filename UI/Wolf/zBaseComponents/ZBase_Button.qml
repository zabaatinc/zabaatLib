import QtQuick 2.4
import QtGraphicalEffects 1.0
import Zabaat.Misc.Global 1.0

Rectangle
{
    id : rootObject
    width  : 200
    height : 40
    radius : 0
    clip   : iconEffects.enableClip


    color: 'transparent'

    property var self : this

    //*****************z component reserved
    signal isDying(var obj)
    Component.onDestruction: isDying(this)
    property var uniqueProperties : ["text","fontSize","fillColor","textColor","pressedBorder","activeBorder","pressedFill","hoverFill","glowColor","imgSrc"]
	property var uniqueSignals	  : ({btnClicked:[]})
    //*********************

    property alias text :textDisp.text
    property alias  imgSrc : img.source

    //deprecated properties
    property alias  btnText      : textDisp.text

    property color  defaultColor : focus ? ZGlobal.style.info : ZGlobal.style.accent
    property alias  hoverColor   : rootObject.hoverFill
    property alias  clickedColor : rootObject.pressedFill
    property alias  state           : button.state

    property bool   isEnabled            : true
    property bool   disableWHChecks      : false
    property bool   showIcon             : false //vector icon       //DEPRECATED NOW HOOOOOOOORAYYY!!!
    property bool   enableEnterKeyAccept : true
    property alias  fontAwesomeIcon      : vectorIcon.text
    property alias  icon                 : vectorIcon.text
    property alias  iconColor            : vectorIcon.color
    property alias  iconAlignment        : vectorIcon.horizontalAlignment
    property alias  iconEffects          : iconEffects

    property bool button2Effects         : true //attempt to make a 2nd generation of button effects compatible with the current button

    property alias fontFamily : textDisp.font.family
//    property alias fontSize   : textDisp.font.pointSize //use to bypass system font
    property real fontSize : ZGlobal.style.text.normal.pointSize

    property alias iconSize   : vectorIcon.font.pointSize
    property alias textPtr    : textDisp
    property alias iconPtr    : vectorIcon

    property color fillColor: defaultColor // activeFillColor
    property color textColor: ZGlobal.style.text.color2 //"#ffffff"  //  activeTextColor
    property color pressedBorder: Qt.darker(defaultColor)
    property color activeBorder:  ZGlobal.functions.colors.getDifferent(defaultColor)
    property color pressedFill:  Qt.darker(fillColor, 1.7)   //ZGlobal.style.objectFillColor  //        //"#8BCF7E"
    property color disabledFill:  Qt.darker(ZGlobal.style._default, 1.5)
    property color hoverFill: ZGlobal.style.info
    property color glowColor: ZGlobal.style.info

    property alias horizontalAlignment: textDisp.horizontalAlignment
    property alias verticalAlignment : textDisp.verticalAlignment
//    property alias glowRadius : glowEffect.glowRadius

    border.width: 0
    border.color: "transparent"

    property var navTab     : null
    property var navBackTab : null

    KeyNavigation.tab    : navTab
    KeyNavigation.backtab: navBackTab

    signal btnClicked(var self)
    signal hovered(var self)
    signal unhovered(var self)

    Keys.onEnterPressed : if(isEnabled && enableEnterKeyAccept) btnClicked(rootObject)
    Keys.onReturnPressed: if(isEnabled && enableEnterKeyAccept) btnClicked(rootObject)

//    onFontSizeChanged: textDisp.font.pointSize = fontSize

    property alias glowEffectPtr : glowEffect

//    Behavior on scale{
//        SequentialAnimation{
//            NumberAnimation{duration:250}
//            ScriptAction{script:{textDisp.font.pixelSize = 22}}
//        }
//    }

    QtObject{
        id:iconEffects
        property int moveDistance:0 //exludes button width so it will auto move the width of the button plus this
        property int moveDuration:1000
        property int rotation:0
        property int rotationDuration:1000
        property bool enableClip: moveDistance===0 ? false:true
    }
    RectangularGlow  {
        id: glowEffect
        visible : false //rootObject.width > 0

        anchors.fill: button
        glowRadius:5
        spread: .3
        color: glowColor
        cornerRadius: 4
    }
    Rectangle{
        id:button
        height:parent.height
        width:parent.width
        color: fillColor
        radius: parent.radius

        Text
        {
            id : textDisp
            width : parent.width
            height : parent.height
            property real padding : width / 10

            color : textColor
            text : "text"

            font.pointSize: rootObject.fontSize > 0 ? rootObject.fontSize : 12
            font.family   : ZGlobal.style.text.normal.family
            font.bold     : ZGlobal.style.text.normal.bold
            font.italic   : ZGlobal.style.text.normal.italic

            horizontalAlignment : Text.AlignHCenter
            verticalAlignment   : Text.AlignVCenter


            x : horizontalAlignment == Text.AlignLeft ? padding : horizontalAlignment == Text.AlignRight ? -padding : 0
            visible             : imgSrc == "" && rootObject.width > 0? true : false
            scale : paintedWidth  > width + padding ? (width - padding)/paintedWidth : 1
        }

        Image
        {
            id : img
            source : ""
            width : parent.width /1.6
            height : parent.height/1.6
            anchors.centerIn: parent
            smooth : true
        }

        Text{
            id: vectorIcon
            font.pointSize:  textDisp.font.pointSize
            font.family: "FontAwesome"
            visible: fontAwesomeIcon.length > 0
            text: ""
            color:  textColor

            width : parent.width
            height : parent.height

            horizontalAlignment: textDisp.text.length > 0 && textDisp.horizontalAlignment == Text.AlignHCenter ? Text.AlignLeft : Text.AlignHCenter
            verticalAlignment  : Text.AlignVCenter
            x : horizontalAlignment == Text.AlignLeft ? paintedWidth /2 : horizontalAlignment == Text.AlignRight ? -paintedWidth /2 : 0

            scale : {
                if(paintedWidth > width && paintedHeight > height){
                    var wScl = width / paintedWidth
                    var hScl = height / paintedHeight
                    return Math.min(wScl, hScl)
                }
                else if(paintedWidth > width){
                    return width / paintedWidth
                }
                else if(paintedHeight > height){
                    return height / paintedHeight
                }
                return 1
            }
        }


        MouseArea
        {
            id : msArea
            hoverEnabled: true
            anchors.fill: parent
            onEntered :
            {
                if(isEnabled){
                        if(!button2Effects){
                            button.state = "HOVER"
                            hovered(rootObject)
                        }else{
                            button.state = "HOVER2"
                            hovered(rootObject)
                        }
                }
            }

            onExited  :
            {
                if(isEnabled){
                    if(!button2Effects){
                        button.state = "NORMAL"
                        unhovered(rootObject)
                    }else{
                        button.state = "NORMAL"
                        unhovered(rootObject)
                    }
                }
            }

                //TODO add the button2Effects to these states as well
            onPressed : if(isEnabled)  button.state = "PRESSED"
            onReleased: if(isEnabled)  button.state = "NORMAL"
            onClicked : if(isEnabled) {
                            if(iconEffects.moveDistance!==0) button.state="ACCEPTED"
                            btnClicked(rootObject)
                        }
        }


        Rectangle{
            enabled:false
            id:borderRect
            anchors.centerIn: parent

            color:"transparent"
            border.color: activeBorder
            border.width:  rootObject.border.width
            width : parent.width - borderRect.border.width
            height : parent.height - borderRect.border.width
            radius: rootObject.radius
        }



        states:
            [
                State {
                    name: "NORMAL"
                    PropertyChanges { target: button;         color: fillColor }
                    PropertyChanges { target: borderRect;         border.color: activeBorder }
                    PropertyChanges { target: textDisp;       color: textColor }
                    PropertyChanges { target: glowEffect;    glowRadius:5}
                },
                State {
                    name: "PRESSED"
                    PropertyChanges { target: button;         color: hoverColor }
//                    PropertyChanges { target: button;             color: pressedFill }
//                    PropertyChanges { target: border;             border.color: pressedBorder }  //  nightPressedColor
//                    PropertyChanges { target: textDisp;           color: pressedBorder }
//                    PropertyChanges { target: glowEffect;        glowRadius:7}
                },
                State {
                    name: "HOVER"
                    PropertyChanges { target: button;         color: hoverColor }
//                    PropertyChanges {  target: border;          border.color: pressedBorder }  //  nightPressedColor
                    PropertyChanges {  target: glowEffect;     glowRadius:glowEffect.glowRadius*=.3}
                },
                State {
                    name: "HOVER2"
                    PropertyChanges { restoreEntryValues: true; target: rootObject;     textColor: "#ffffff" ; fillColor: ZGlobal.style.info }
                    PropertyChanges {  target: borderRect;          border.color: pressedBorder }  //  nightPressedColor

                    //                    PropertyChanges {  target: glowEffect;     glowRadius:glowEffect.glowRadius*=.3}
                },
                State {
                    name: "CLICKED"
                    PropertyChanges { target: button;         color: hoverColor }
//                    PropertyChanges {  target: border;          border.color: pressedBorder }  //  nightPressedColor
//                    PropertyChanges {  target: glowEffect;     glowRadius:glowEffect.glowRadius*=.3}
                },
                State {
                    name:"ACCEPTED"
                    PropertyChanges {restoreEntryValues: true;  target: vectorIcon;       x: button.width+iconEffects.moveDistance}  //  nightPressedColor
                    PropertyChanges {restoreEntryValues: true;  target: vectorIcon;       rotation: iconEffects.rotation}  //  nightPressedColor
                    PropertyChanges {restoreEntryValues: true;  target: textDisp;          visible:false}
                }

//                State{ //TODO implement this state
//                    name:"ACTIVE"
//                    PropertyChanges { target: button;         color: hoverColor }
//                }

            ]

        transitions: [
            Transition {
                from: "*"
                to: "PRESSED"
                ParallelAnimation{
//                    NumberAnimation{properties:"glowRadius"; duration:225}
                    ColorAnimation{duration:250}
                }
            },
            Transition {
                from: "*"
                to: "HOVER"
                ParallelAnimation{
//                    NumberAnimation{properties:"glowRadius"; duration:225}
                    ColorAnimation{ duration:250}
                }
            },
            Transition {
                from: "*"
                to: "NORMAL"

                ParallelAnimation{
//                    NumberAnimation{properties:"glowRadius"; duration:120}
//                    ColorAnimation{duration:250}
                }
            },
            Transition {
                from: "*"
                to: "ACCEPTED"
                reversible:true

                id:acceptedAni
                ParallelAnimation{
                    alwaysRunToEnd: true

                    NumberAnimation{properties:"x"; duration:iconEffects.moveDuration}
                    NumberAnimation{properties:"rotation"; duration:iconEffects.rotationDuration}
                    ColorAnimation{duration:120}
                }
            }
        ]
//        Component.onCompleted: state="NORMAL"
    }





}
