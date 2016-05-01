import QtQuick 2.2
import "zBaseComponents"

/*! \brief Gives us a quick way of creating a messagebox with OK and Cancel options!
    \inqmlmodule Zabaat.UI.Wolf 1.0
    \code
    ZMsgBox
    {
        msgboxId: 10
        message : 'Enter your name'
        onOkClicked : function(text,id) { some code to use the text provided in the messageBox and/or the msgBoxId (given here as id) }
        onCancelClicked : function() { some code to use if the user hits cancel }
    }
    \endcode
*/
ZBase_MsgBox
{
    id : rootObject

    // ####     ZEditRelated    ##########################################
    property string fileName  : "ZMsgBox.qml"
	property var 	editOptions : null
	property alias  zEditPtr  : zedit
	
	property var 	dataSection : ({})	//## use this for stroing globally available javascript objects and functions
	property var 	propArr  	: []	//## zEdit will use this to store and load information as readable format for us! Cause we might have assigned a value to 
	property var    eventArr 	: []	//## zEdit will use this to store and load information as readable format for us! Cause we might have assigned a value to 
	
    property alias  emitSignalOnRelease : zedit.emitSignalOnRelease
    signal   z_Released(string name, int x, int y)
    signal   z_Pressed
    //####################################################################

    ZEdit
    {
        id : zedit
        theParent : rootObject
		editOptions : rootObject.editOptions
        onZReleased: z_Released(name,x,y)
        onZPressed:  z_Pressed
    }

}


