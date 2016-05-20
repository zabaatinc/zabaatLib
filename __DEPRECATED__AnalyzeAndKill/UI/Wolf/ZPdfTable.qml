import QtQuick 2.2
import "zBaseComponents"

/*! \brief Generates a pdf using the model provided. This table generated will be in text format! The model can be a listModel or an object array. It will be autoconverted into a listmodel. Requires a pointer of type
    PdfWriter to function. The PdfWriter qml type can be found in Zabaat.PdfTools 1.0. This does not save the pdf but rather draws a multiline text onto the cache of the PdfWriter. The PdfWriter's finalize() method
    must be called to save.

    \inqmlmodule Zabaat.UI.Wolf 1.0
    \relates PdfWriter, Zabaat.PdfTools 1.0
*/
ZBase_PdfTable
{
    id : rootObject

    // ####     ZEditRelated    ##########################################
    property string fileName  : "ZPdfTable.qml"
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



