import QtQuick 2.4

// i'm thinking it would be useful to have a mouse area that would let you pass in the ApplicationWindow, it would map to it and then
// fill the screen but place its Z under the current obj, and map it's clicked function to closing it's parent.


MouseArea{
	id:rootObj
	property var fillObj: null
	
	
	
	Component.onCompleted{

	}
}
