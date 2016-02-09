import QtQuick 2.1
import QtQuick.Window 2.2
import Zabaat.Misc.Global 1.0

/*!
   \brief Gives us a ZTextBox with a dropdown that tries to provide options for autocompletion of the text. This dropdown is populated by
          the string array provided in model.
   \inqmlmodule Zabaat.UI.Wolf 1.0
    \code
    ZBase_AutoCompleteBox
    {
        model : ["hello","world"]
    }
    \endcode
*/
ZBase_TextBox
{
    id : rootObject
    property var self : this
    width: 200
    height: 62
    color : "white"

    /*! The current text entered */
    text      : ""

    /*! The label of this ZTextBox*/
    labelName : ""

    /*! The special character which tells this component to start looking for autocompletion. Can be set to blank if we always want to autoComplete. Defaults to '&' */
    property string startAutoCompleteOn : "&"

    /*! The array of strings that this component is going to compare text to, to provide autocomplete information (in the form of a selectable listview)*/
    property alias model : lv.model
    property var uniqueValues : ["osBorderHeightOff","osBorderWidthOff","model","fontColor","fontSize","padding"]
    property var uniqueSignals : ({gotFocus:[], lostFocus:[] })
    property var winPtr : null


    function matchFromStart(inStr,bigStr)
    {
        inStr = inStr.toLowerCase()
        bigStr = bigStr.toLowerCase()

        //console.log('compare', inStr, 'to', bigStr)
        if(inStr.length > 0 && bigStr.length > 0 && bigStr.length >= inStr.length)
        {
            for(var i = 0; i < inStr.length; i++)
            {
                if(inStr.charAt(i) != bigStr.charAt(i))
                {
                    return false
                }
            }
            return true
        }
        return false
    }

    ItemPositionTracker
    {
        trackedItem : rootObject
        movedItem   : ref
    }

    Item
    {
        id : ref
        visible : win.visible
    }


    Window
    {
        id : win
        flags   : Qt.Popup | Qt.WindowStaysOnTopHint | Qt.NoDropShadowWindowHint
        modality: Qt.NonModal

        x : ZGlobal.app.x + ref.x
        y : ZGlobal.app.y + ref.y + rootObject.height

        width : rootObject.width
        height : 250
        visible : false
        color : "transparent"


        Timer
        {
            id : lvVisTimer
            running : true// rootObject.text.length > 0
            repeat : true
            interval: 250
            onTriggered: win.visible = visibleFunction()

            function visibleFunction()
            {
                if(rootObject.text.length == 0)
                    return false

                if(startAutoCompleteOn != "")
                {
                    if(rootObject.text.length > startAutoCompleteOn.length && matchFromStart(startAutoCompleteOn,rootObject.text))
                    {
                        for(var i = 0; i < model.length; i++)
                        {
                            if(  (rootObject.text.substring(startAutoCompleteOn.length,rootObject.text.length)).toLowerCase() == model[i].toLowerCase())
                                return false
                        }
                        return true
                    }
                    else
                        return false
                }
                else
                {
                    for(i = 0; i < model.length; i++)
                    {
                        if(rootObject.text.toLowerCase() == model[i].toLowerCase())
                            return false
                    }
                }

                return true
            }
        }


        ListView
        {
            id : lv
            width : parent.width
            height : parent.height

            model : ["derp","derpitudes","herp","herpitudes"]

            function matchFunction(str)
            {
                var matchTo = rootObject.text
                if(startAutoCompleteOn != "" && matchFromStart(startAutoCompleteOn, rootObject.text))
                    matchTo = matchTo.substring(startAutoCompleteOn.length, matchTo.length)

                if(rootObject.matchFromStart(matchTo,str))
                    return rootObject.height

                return 0
            }


            delegate : Rectangle
            {
                width  : rootObject.width
                height : lv.matchFunction(lv.model[index])
                color  : rootObject.color
                border.width: 1
                border.color: "black"
                Text
                {
                    font : rootObject.font
                    id : listText
                    width : rootObject.width
                    height : parent.height
                    visible : parent.height > 0
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment : Text.AlignVCenter
                    text : lv.model[index]
                }

                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered :  parent.color = Qt.darker(rootObject.color)
                    onExited  :  parent.color = rootObject.color
                    onClicked :
                    {
                        if(rootObject.startAutoCompleteOn != "")      rootObject.text = rootObject.startAutoCompleteOn + listText.text
                        else                                          rootObject.text = listText.text

                        rootObject.focus = true
                    }
                }
            }


        }




    }






}

