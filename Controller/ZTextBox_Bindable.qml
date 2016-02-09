import QtQuick 2.0
import Zabaat.UI.Wolf 1.0

//TODO THIS BREAKS IF THE OBJECT GETS DELETED SOMEHOW. WHAT THE!!!
ZTextBox
{
    id : rootObject
    property string bindingStr        : ""
    property var model                : null
    property bool disableNotifications : true
    text : bindingFunction()

    function bindingFunction()
    {
        if(model)
        {
            var val = model.getFromMap(bindingStr)
            if(model && val == "N/A" &&  bindingStr != "" && !checkTimer.running)
                checkTimer.running = true
            return val
        }
        return "N/A"
    }

    //Ugh, ugly... Restores binding to our function cause Qt is stupid. It doesn't know that the output of the function changed
    //When a bindy gets deleted.
    Timer
    {
        id : checkTimer
        running : false
        repeat : true
        interval : 1000

        onTriggered :
        {
            text = "N/A"
            if(model && "N/A" != model.getFromMap(bindingStr) )
            {
               running = false
               text = Qt.binding(function() { return bindingFunction() }  )
            }
        }
    }

    onBindingStrChanged: if(model && !checkTimer.running)
                         {
                             disableNotifications = true
                             text = Qt.binding(function() { return bindingFunction() } )
                             disableNotifications = false
                         }
    onModelChanged     : if(model && !checkTimer.running)
                         {
                             disableNotifications = true
                             text = Qt.binding(function() { return bindingFunction() } )
                             disableNotifications = false
                         }
    onTextChanged      : if(!rootObject.disableNotifications &&  model && bindingStr !== "" && text != "N/A")
                         {
                            rootObject.disableNotifications = true
                            model.setToMap(bindingStr, text)
                            rootObject.disableNotifications = false
                         }

}
