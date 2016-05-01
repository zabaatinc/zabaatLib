import QtQuick 2.0

Rectangle
{
    id : rootObject
    property int spacing    : 30
    property int cellHeight : 60
	property bool autoUpdate : true
    property var self : this
	
	width  : 500
	height : 500
    //height : children.length * (spacing + cellHeight)
    color : "transparent"

    onChildrenChanged   : if(autoUpdate) updateChildren()
    onWidthChanged      : if(autoUpdate) updateChildren()
    onCellHeightChanged : if(autoUpdate) updateChildren()
	
    signal isDying(var obj)
    Component.onDestruction: isDying(this)

    function updateChildren()
    {
        for(var i = 0 ; i < children.length; ++i)
        {
            var child = children[i]
            child.width = rootObject.width
            child.height = cellHeight

            child.y = Qt.binding(function() {  return  (i - 1) * (spacing + cellHeight) } )
        }
    }
	
	function getMaxWidth()
	{
		var max = 0
		for(var c in children)
		{
			var child = children[c]
			if(child.width > max)
				max = child.width
		}
		return max
	}
	
	function getMaxHeight()
	{
		var max = 0
		for(var c in children)
		{
			var child = children[c]
			if(child.height > max)
				max = child.height
		}
		return max
	}
	
}
