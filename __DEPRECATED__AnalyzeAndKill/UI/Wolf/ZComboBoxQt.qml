import QtQuick 2.2
import "zBaseComponents"

/*! \brief Uses Qt's Combobox and provides some extra features. Takes in setupObj and shows all the values (of the properties therein) delimited by spaces.
           Normally this will hide the actual value field.
    \inqmlmodule Zabaat.UI.Wolf 1.0
    \code
        ZComboBoxQt
        {
            setupObj : [
                         { id : 0, firstName: 'Brett' , lastName: 'Ansite'},
                         { id : 1, firstName: 'Shahan', lastName: 'Kazi'}
                       ]
            actualValueField: 'id'
            initIndex : 1
            showValueField: true
        }
    \endcode
*/
ZBase_ComboBoxQt
{
    id : rootObject

    // ####     ZEditRelated    ##########################################
    property string fileName    : "ZComboBoxQt.qml"
	property var 	editOptions : null
	property alias  zEditPtr    : zedit
	
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




