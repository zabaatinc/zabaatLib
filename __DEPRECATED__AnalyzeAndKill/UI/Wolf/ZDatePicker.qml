import QtQuick 2.2
import "zBaseComponents"

/*!
    \inqmlmodule Zabaat.UI.Wolf 1.0
    \brief Uses ZTextBox and a Calendar to pick a date! The ZTextBox has an input Validator on it, which makes inputting invalid dates impossible.
    \code
        ZDatePicker
        {
            id : startDatePicker
            labelName : "startDate"
            width : parent.width/2 - dateRow.spacing
            winOffsetX : offsetX
            winOffsetY : offsetY
        }
    \endcode
*/
ZBase_DatePicker
{
    id : rootObject

    // ####     ZEditRelated    ##########################################
    property string fileName  : "ZDatePicker.qml"
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



