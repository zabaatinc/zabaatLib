import QtQuick 2.2
import "zBaseComponents"

/*!
    \inqmlmodule Zabaat.UI.Wolf 1.0
    \brief Creates a radial display of values to be from a time based model. Uses ZBase_TextBox and ZBase_TimePicker (which is an extension of ZBase_RadialPicker)
    The ZTextBox is input validated so incorrect times cannot be entered! The format is hh:mm ap
*/
ZBase_TextBox_TimePicker
{
    id : rootObject

    // ####     ZEditRelated    ##########################################
    property string fileName  : "ZTextBox_TimePicker.qml"
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



