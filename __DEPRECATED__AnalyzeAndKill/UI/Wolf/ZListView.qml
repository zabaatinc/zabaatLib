import QtQuick 2.2
import "zBaseComponents"

/*!
    \brief Kind of the same concept as ZDynamicForm. Very configurable and let's us produce quick ListViews without much effort!
    If an array or an object is provided as the model (and NOT a QQMlListModel), it will get copied up by this class and remade
    into a QQMlListModel. Any changes to the original array/object will not change this ListView. Provide a QQmlListModel if you want
    bindings
	\inqmlmodule Zabaat.UI.Wolf 1.0
	\code
		ZListView
		{
			id : lv
			model : modelArr
			ordering : ["firstName","lastName"]
			anchors.centerIn: parent
			displayFunctions : ({firstName : function(obj) { return obj.toUpperCase() } } )
			typeArr : ({
						   numbers : { type : 'ZLifeBar', importArr : ['Zabaat.UI.HUD.GameElements 1.0'], valueField : 'value', override : { total : 100, width : 400} }
					   })
			title : "Testing"
		}
	\endcode
*/
ZBase_ZListView
{
    id : rootObject

    // ####     ZEditRelated    ##########################################
    property string fileName  : "ZListView.qml"
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



