import QtQuick 2.0
import QtQuick.Controls 1.1

Item
{
    signal isDying(var obj)
    Component.onDestruction: isDying(this)

    id : rootObject
    property var self : this
    width : 300
    height : 30
	visible : isVisible && totalDegrees > 0
    property int cmpSize : 30
    property int  rot : 0
    property int totalDegrees    : 0
    property int currentPosition : 0
    property bool buttonsVisible  : true
	property bool isVisible 	  : true

    property color btnColor             : "#ff0000"
    property color btnHoverColor        : "#770000"
    property color btnClickedColor      : "#000000"
    property color btnTextColor         : "#ffffff"

    signal scrollBarChanged(int index)
    signal btnDec_Clicked
    signal btnInc_Clicked



    Component.onCompleted: if(totalDegrees < 0)     totalDegrees = 0
    onTotalDegreesChanged: if(totalDegrees < 0)     totalDegrees = 0
    onCurrentPositionChanged:
    {
        if(totalDegrees > 1)
        {
            if(currentPosition >= totalDegrees)
                currentPosition = totalDegrees - 1
            else if(currentPosition < 0)
                currentPosition = 0

            scrollBarChanged(currentPosition)
        }
    }



    transform: Rotation
                {
                    origin.x : 0
                    origin.y : 0
                    angle    : rot
                }




    Rectangle
    {
        id : bar
        width : parent.width - (cmpSize * 2)
        height : parent.height
        color :  Qt.rgba(0.4,0.4,0.4,0.6)
        radius : height/2
        anchors.left: btn_decrease.right
		border.width : 1
		border.color : "black"
		x : cmpSize

        //Sets the bar to a location based on where it was clicked!
        MouseArea
        {
            anchors.fill: parent
            onClicked:
            {
                var selWidth = bar.width / totalDegrees
                currentPosition = mouseX / selWidth
            }
        }

        Rectangle
        {
            id : indicator
            width : cmpSize/1.25
            height : width
            radius : width/2
            color  : Qt.rgba(0.2,0.2,0.2,0.7)
            border.width: 1
            border.color: "black"

            x: (bar.width - width)/(totalDegrees -1) * currentPosition


            anchors.top: parent.top
            anchors.topMargin: parent.height/2 - height/2
        }


    }


    ZBase_Button
    {
        id : btn_decrease


        defaultColor    :  btnColor
        hoverColor      :  btnHoverColor
        clickedColor    :  btnClickedColor
        textColor       :  btnTextColor

        width  : cmpSize
        height : width
        fontSize : 12
        //x : -width

        anchors.top: parent.top
        anchors.topMargin: parent.height/2 - height/2

        visible : buttonsVisible
        enabled : buttonsVisible
//        border.width : 1

        btnText : "<"
        onBtnClicked: { currentPosition--;  btnDec_Clicked(); }
    }

    ZBase_Button
    {
        id : btn_increase

        defaultColor    :  btnColor
        hoverColor      :  btnHoverColor
        clickedColor    :  btnClickedColor
        textColor       :  btnTextColor

        width  : cmpSize
        height : width
        x  : bar.width
        visible : buttonsVisible
        enabled : buttonsVisible
        fontSize : 12
//        border.width : 1

        anchors.left: bar.right
        anchors.top: parent.top
        anchors.topMargin: parent.height/2 - height/2

        btnText : ">"
        onBtnClicked: { currentPosition++;  btnInc_Clicked(); }
    }
}




