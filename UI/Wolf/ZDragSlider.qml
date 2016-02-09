import QtQuick 2.4
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0
import Zabaat.Misc.Global 1.0


Item
{
    id:rootObj
    height: 71
    width: 200

    signal emitVal()

    //settings
    property double minOffset: 0  //min offset
    property double maxOffset: 100 //max offset
    property int displayedValueGain: 1
    property int presetPercent: 100

    property string whenToEmit: "onReleased" //TODO - not implemented

    onWhenToEmitChanged: {
        var acceptableValues = ["onReleased","onChanged"]
        for (var v in acceptableValues){
            if (whenToEmit !== acceptableValues[v]){
                whenToEmit = "onReleased"
                console.log("ZDragSlider unacceptable option chosen")
            }
        }
    }



    property string label   : ""
    property double value   : ((fill.width / __totalPossibleMaxValue) * ((maxOffset - minOffset))+minOffset).toFixed(2) //TODO scale to value
    property bool   day     : false


    //sets how far the ball is from the edge
    property int __dragMinOffset: 0
    property int __dragMaxOffset: rootObj.width - rootObj.width/90
    property int __totalPossibleMaxValue: __dragMaxOffset - button.width

    property string buttonBorder  : ZGlobal.style.text.color1
    property string fillBorder    : ZGlobal.style.text.color1
    property alias containerColor : container.color
    property string txtColor      : ZGlobal.style.info
    property alias  bubbleTextSize : bubbleText.font.pointSize

    function setValue(val) {
        //have to work backwards on this
        //((fill.width / __totalPossibleMaxValue) * ((maxOffset - minOffset))+minOffset).toFixed(2)
//        button.x = val * (presetPercent/100)
        var newVal =  __totalPossibleMaxValue * val / ((maxOffset - minOffset)+ minOffset).toFixed(2)
        button.x = newVal  //fill.width is the same as button.x
    }


    Image {
        id: image
        source: (day) ? "./images/bubbleDay.png" : "./images/bubbleNight.png"
        x: button.x + button.width/2 - image.width/2
        anchors.bottom: container.top
        visible : false

        Text
        {
            id: bubbleText
            text: value * displayedValueGain
            verticalAlignment: Text.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -2
            font {
                family   : ZGlobal.style.text.normal.family
                bold     : ZGlobal.style.text.normal.bold
                italic   : ZGlobal.style.text.normal.italic
                pointSize: ZGlobal.style.text.normal.pointSize
            }

            color: day ? ZGlobal.style.text.color1 : ZGlobal.style.text.color2
        }
    }
//    RectangularGlow {
//        id: effect
//        anchors.fill: container
//        glowRadius:3
//        spread: .4
//        color: glowColor
//        cornerRadius: 5
//        opacity: 1
//    }
    Rectangle {
        id: container

        color: containerColor
        width: rootObj.width
        height: rootObj.height/2

        border.color: fillBorder
        radius: 5
        border.width: 1

        Rectangle
        { // this things width is the value of the output
            id: fill
            height: 6
            radius: 3
            x: __dragMinOffset + button.width/2
            width: button.x
            color: txtColor
            anchors.verticalCenter: parent.verticalCenter

            gradient:
                Gradient
                {
                    GradientStop
                    {
                        id:stop1
                        position: 0
                        color: Qt.darker(txtColor)
                    }
                    GradientStop
                    {
                        id:stop2
                        position: .5
                        color: txtColor
                    }
                    GradientStop
                    {
                        id:stop3
                        position: 1
                        color:Qt.darker(txtColor)
                    }
                }
        }

        Rectangle
        {
            id: button
            width:  rootObj.height/2
            height: rootObj.height/2
            color: Qt.lighter(txtColor)
            border.color: buttonBorder
            border.width: 1
            radius:12
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.8

            MouseArea
            {
                id: ma
                anchors.fill : parent
                drag.target  : parent
                drag.minimumX: __dragMinOffset
                drag.maximumX: __dragMaxOffset - button.width
                onPressed    : { button.scale = 1.25 ; image.visible = true;    }
                onReleased   : { button.scale = 1    ; image.visible = false;   }

            }
        }

        Text{
            id: labelText
            text: label
            height : rootObj.height/2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:  parent.bottom
            font : ZGlobal.style.text.normal
//            font.family: ZGlobal.style.text.defaultFontName
//            font.pointSize: ZGlobal.style.text.normal.pointSize
            color: txtColor
        }
    }


//    Component.onCompleted: {
//        button.x = __totalPossibleMaxValue * (presetPercent/100)
//    }
}
