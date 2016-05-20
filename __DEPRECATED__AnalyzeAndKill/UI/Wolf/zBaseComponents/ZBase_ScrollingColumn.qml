import QtQuick 2.0
import "Functions.js" as Functions

ZBase_Column
{
    id : col
	property alias 	scrollBarVisible : scrolly.isVisible
    property var self : this
	
    color : "transparent"
	radius : 10

    property bool 	barOrientationRt  : true
    property int    barWidth 		  : 20
    property alias  proportionalize   : proportionalise
    property alias  barBtnSize        : scrolly.cmpSize
    property bool   isAnchored        : false

    property alias scrollyX : scrolly.x
	
	

    spacing : 30
    onYChanged : updateChildrenVisiblity()
    onChildrenChanged:
    {
        scrolly.totalDegrees = children.length
//            msArea.drag.minimumY = -(col.children.length * (cellHeight + spacing)   )
        updateChildrenVisiblity()
    }

    Timer
    {
        id : proportionalise
        property bool dontkillme : true
        running : true
        repeat : false
        interval : 2
        onTriggered :
        {
            scrolly.width = Qt.binding(function() { return col.height } )
            scrolly.height = Qt.binding(function() { return barWidth} )
            scrolly.x = Qt.binding(function() { var x = barOrientationRt? col.width + barWidth + scrolly.height/2: -scrolly.height/2 ; return x  } )
//            scrolly.y = Qt.binding(function() { return scrolly.currentPosition * (cellHeight + spacing)  } )

            if(!isAnchored)          col.y                   = -scrolly.currentPosition * (cellHeight + spacing)
            else                     col.anchors.topMargin   = -scrolly.currentPosition * (cellHeight + spacing)

            scrolly.anchors.top       = parent.top
            scrolly.anchors.topMargin =  scrolly.currentPosition *  (cellHeight + spacing)


            updateChildrenVisiblity()
            stop()
        }
    }


    ZBase_Scrollbar
    {
        id              : scrolly
        height 			: barWidth
        width           : col.height
        buttonsVisible  : true
        totalDegrees    : 0
        rot : 90
        anchors.top     : parent.top

        property bool dontkillme : true
        onScrollBarChanged:
        {
            if(!isAnchored)          col.y                   = -index * (cellHeight + spacing)
            else                     col.anchors.topMargin   = -index * (cellHeight + spacing)

            scrolly.anchors.topMargin =  index *  (cellHeight + spacing)
            updateChildrenVisiblity()
        }
    }

    function updateChildrenVisiblity()
    {
        for(var i = 0; i < children.length; ++i)
        {
            if(!children[i].dontkillme)
            {
                var childY =  children[i].y
                if(childY < scrolly.anchors.topMargin || childY >= scrolly.anchors.topMargin + scrolly.width)           children[i].visible = false
                else                                                                                                    children[i].visible = true
            }
        }
    }

    function addChild(qmlName)
    {
        var obj = Functions.getNewObject(qmlName,col)

        obj.width  = width - 5
        obj.height = cellHeight

        return obj
    }
	
	function addChildQml(imports, qmlStr)
	{
		var obj = Functions.getQmlObject(imports,qmlStr,col)
        obj.width  = width - 5
        obj.height = cellHeight
	
        return obj
	}

    function clear()
    {
        for(var i = children.length - 1; i >= 0 ; i--)
        {
            var child = children[i]
            if(!child.dontkillme)
            {
                child.parent = null
                child.destroy()
            }
        }
    }






}
