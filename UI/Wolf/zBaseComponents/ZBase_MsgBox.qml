import QtQuick 2.2


/*! \brief Gives us a quick way of creating a messagebox with OK and Cancel options!
    \inqmlmodule Zabaat.UI.Wolf 1.0
    \code
    ZBase_MsgBox
    {
        msgboxId: 10
        message : 'Enter your name'
        onOkClicked : function(text,id) { some code to use the text provided in the messageBox and/or the msgBoxId (given here as id) }
        onCancelClicked : function() { some code to use if the user hits cancel }
    }
    \endcode
*/
Rectangle
{
    property var self : this
    signal isDying(var obj)
    Component.onDestruction: isDying(this)

    id : rootObject
    width : 250
    height: 150
    radius: 5

    border.width: 4
    border.color: "black"
    color : "gray"

    /*! The id of this msgBox. Not useful in many situations but can be in some.*/
    property int    msgboxId : -1

    /*! The description of what this messagebox wants the user to provide*/
    property string message  : "Your text here!"

    property bool   isEnabled : true

    /*! The signal that is emitted when the user hits ok*/
    signal okClicked(string text, int id)

    /*! The signal that is emitted when the user hits cancel*/
    signal cancelClicked


    //Get unique property values
    property var uniqueProperties : [ "msgboxId","message"]
	property var uniqueSignals	  : ({ okClicked : ["text","id"], cancelClicked:[] })


    onIsEnabledChanged: textBoxRect.isEnabled = btn_ok.isEnabled = btn_cancel.isEnabled = isEnabled

    onWidthChanged:  { while(width  < txt_msg.width  && txt_msg.font.pointSize > 2) txt_msg.font.pointSize -= 1   }
    onHeightChanged: { while(height < txt_msg.height && txt_msg.font.pointSize > 2) txt_msg.font.pointSize -= 1   }

    Text
    {
        id : txt_msg
        x : parent.width/2 - txt_msg.width/2
        y : 10
        text : message
        font.pointSize: 24
    }


    ZBase_TextBox
    {
        id     : textBoxRect
        x      : parent.width/2 - textBoxRect.width/2
        y      : txt_msg.y  + height + 5
        width  : parent.width  / 1.2
        height : parent.height / 3
    }

    ZBase_Button
    {
        id : btn_ok
        x : btn_ok.width/2
        y : parent.height - btn_ok.height - 5

        width  : parent.width / 8
        height : width
        fontSize : 10

        btnText : "OK"
        onBtnClicked:
        {
            okClicked(textBoxRect.text,msgboxId)
            rootObject.destroy()
        }
    }

    ZBase_Button
    {
        id :btn_cancel
        x : rootObject.width - btn_ok.width/2 - btn_cancel.width
        y : parent.height - btn_cancel.height - 5
        fontSize : 10

        width  : parent.width / 8
        height : width


        btnText: "X"
        onBtnClicked:
        {
            cancelClicked()
            rootObject.destroy()
        }
    }







}


