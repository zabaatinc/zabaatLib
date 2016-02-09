import QtQuick 2.0
Item
{
	property bool debugMode : false

	function debugMsg()
	{
		if(debugMode)
		{
			var str = ""
			for(var i = 0; i < arguments.length; i++)
				str += arguments[i] + " "
			console.log(str)
		}
	}
}