import QtQuick 2.2
import "zBaseComponents"

/*!
    \inqmlmodule Zabaat.UI.Wolf 1.0
    \brief Creates a radial display of values to be picked. Comes with quite a bit of configuration options.

    \note If the values in the model are numeric, make sure the greatest value is the first thing in the array!
    \code
        //Allows for
        ZRadialPicker
        {
            id : radPicker_1
            model : [4,1,2,3]
            blobColor : "green"
            accentColor : ZGlobal.style.danger
            extraHoverPx : 20
            digitalOnly: true
            enableMagnitudeChange : true
            maxMagnitude : 2
        }

        ZRadialPicker
        {
            id : radPicker_2
            model : ['eat','sleep','derp','more derps']
            extraHoverPx : 20
            digitalOnly: false
            enableMagnitudeChange : false
        }
    \endcode
*/
ZBase_RadialPicker
{
    id : rootObject

    // ####     ZEditRelated    ##########################################
    property string fileName  : "ZRadialPicker.qml"
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



