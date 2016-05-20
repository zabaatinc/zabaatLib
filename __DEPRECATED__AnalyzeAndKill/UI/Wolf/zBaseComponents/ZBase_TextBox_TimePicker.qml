import QtQuick 2.4
import Zabaat.Misc.Global 1.0
import QtQuick.Window 2.0

/*!
    \inqmlmodule Zabaat.UI.Wolf 1.0
    \brief Creates a radial display of values to be from a time based model. Uses ZBase_TextBox and ZBase_TimePicker (which is an extension of ZBase_RadialPicker)
    The ZTextBox is input validated so incorrect times cannot be entered! The format is hh:mm ap
*/
ZBase_TextBox
{
    id : rootObject
    property var self : this

    /*! The time to initiate this object on. Defaults to \c new Date() */
    property date initTime : new Date()

    /*! The current selected time as a Javascript date! */
    property date dateFormatAns : initTime

    /*! For this object's use only. Do not alter. */
    property bool feedback : false

    /*! Useful for embedding within other windows than the main one. Give it the offset of the window this is in*/
    property int winOffsetX : 0

    /*! Useful for embedding within other windows than the main one. Give it the offset of the window this is in*/
    property int winOffsetY : 0

    property var uniqueProperties :  ['model','digitalOnly','enableMagnitudeChange','maxMagnitude','magnitude','value','extraHoverPx','amPm','initTime','labelName']
    property var uniqueSignals    : ({blobClicked  :[]})

    /*! Becomes Component.Ready when the initTime variable is loaded*/
    property int status : Component.Loading


    onVisibleChanged: if(rootObject && !visible) win.visible = false

    dTextInput.validator: RegExpValidator  { regExp:  /^([1-9]|0[1-9]|1[012])[:]([0-5][0-9]|0[0-9])[ ](am|pm)$/ }

    /*! The text caption that appears under the ZTextBox*/
    labelName : ""
    onTextChanged : {
        if(!feedback && text.length == 8 && status == Component.Ready)   //hh = 2 , mm = 2, : = 1, am/pm = 2, ' '  = 1,                      2 + 2 + 2 + 1 + 1 =8
        {
            feedback = true

            dateFormatAns = extractTime()
            timePicker.setTime(dateFormatAns)

            feedback = false
        }
    }

    function extractTime() {
        var time = new Date()
        var arr = text.split(':')

        var hrs = Number(arr[0])
        if(arr[1]) {
            var arr2 = arr[1].split(' ')
            var mins = arr2[0]
            hrs = arr2[1] && arr2[1] == "pm" && hrs != 12 ? hrs + 12 : hrs
            time.setHours(hrs,mins,0,0)
        }

        return time
    }

//    property bool cursorInit : false
    onCursorPositionChanged  : {
        if(rootObject.status === Component.Ready){
            if(dTextInput.focus)
                win.visible = true
        }
    }
    dTextInput.onFocusChanged: {
        if(dTextInput.focus && cursorInit) win.visible = true
        else                               win.visible = false
    }
    onClick: if(win) win.visible = true

    Timer {
        id : initTimer
        interval : 20
        running : true
        repeat : false
        onTriggered:
        {
            rootObject.feedback = true

            rootObject.text = Qt.formatTime(initTime, "hh:mm ap")
//            if(dTextInput.focus)  win.visible = true
//            else                  win.visible = false

            dateFormatAns = extractTime()
            timePicker.setTime(dateFormatAns)

            rootObject.feedback = false
            rootObject.status = Component.Ready
        }
    }

    Item
    {
        id : win
        width   : rootObject.width  //+ rootObject.width/8 + 20
        height  : width
        visible : false
        y       : rootObject.height

        Rectangle {
            anchors.fill: parent
            color : ZGlobal.style._default
            border.width: 1
            border.color: ZGlobal.style.accent
        }
        ZBase_TimePicker  {
            id : timePicker

            anchors.centerIn: parent
            width : rootObject.width

            onTimeStrChanged:  rootSet()
            onBlobClicked   : {rootSet(); win.visible = false}

            function rootSet() {
                if(!rootObject.feedback && rootObject.status === Component.Ready) {
                    rootObject.feedback = true

                    rootObject.text          = timeStr
                    rootObject.dateFormatAns = extractTime()

                    rootObject.feedback = false
                }
            }
        }

    }
}



