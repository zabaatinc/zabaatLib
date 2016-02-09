import QtQuick 2.0
import Zabaat.UI.Wolf 1.0


// ZCell, Ver 1.0 , 11/19/2014 by SSK
// Built on top of ZBindVal and ZBase_TextBox
// Displays the ZBindVal in a textbox and changes the zModel if you change the string in the textbox
// NOTE : Calls doConnect() when zModel is assigned.
//        Make sure all other essentials are assigned before Zmodel is assigned!

// Example of valid ZCell
// ZCell
// {
//   bindStr : <bindStr>
//   zModel : <zModel>
// }

ZTextBox
{
    id : rootObject
    property string myType       : "ZCell"      //To be able to identify this easier when going through many dynamic objects
    property var  zModel         : null         //The zModel this textbox is connected to
    property string  bindStr     : ""           //The path of the value in the zModel this textbox is connected to. e.g., "0,lastName"
    property alias   index       : zbv.index    //The index (for ZSheetView)
    property bool  allowWrites   : true         //This allows us to change the text of this textbox without changing the underlying
                                                //ZBindVal . This is useful when the text change originated from the ZBindVal itself!

    //Calls doConnect() if the ZModel is not null and passes the zModel to the ZBindVal's zModel. (make sure this is by reference!)
    onZModelChanged :
    {
        if(zModel != null)
        {
            zbv.zModel = zModel
            doConnect()
        }
    }

    onBindStrChanged: zbv.bindStr = bindStr             //Tells the ZBindVal that the bindStr changed
    onTextChanged   : if(allowWrites) zbv.val = text    //Tells the ZBindVal that the value changed

    signal iChanged(int index, string value)            //Emitted when the value is changed by the user
    signal iChangedType(int index, var value)           //Emitted when the value TYPE is changed (it is no longer a string coming from the ZBindVal)

    //The ZBindVal which allows this textbox to connect to the zModel
    ZBindVal
    {
        id : zbv

        //When ZBindVal's value changes, change the textbox's value without signalling the ZBindVal that our text changed (avoid loopage)
        onValChanged:
        {
            if(rootObject != null && zbv != null)
            {
                if(typeof val === 'string')
                {
                    allowWrites = false
                    text = val
                    allowWrites = true

                    if(text == "N/A")                        isEnabled = false
                    else                                     isEnabled = true
                }
                else
                {
                    iChangedType(index,val)
                }
            }

        }

        //If it is a local change, change the border color to purple (the server has not confirmed it yet)
        onValChangedLocal:
        {
            if(rootObject != null && zbv != null)
            {
                border.color = "purple"
                iChanged(index,val)
            }
        }

        //If it is an external change, change the border color to black (the server has not confirmed it)
        onValChangedExternal:
        {
            if(rootObject != null && zbv != null)
            {
                border.color = "black"
                iChanged(index,val)
            }
        }
    }

    //Initiates the connection between the zmodel and this textbox by initiating the connection between the zModel and the ZBindVal
    function doConnect()    {  zbv.doConnect() }



}
