import QtQuick 2.0
import "Functions.js" as Functions
import Zabaat.Misc.Util 1.0

Item
{
    id : rootObject
    property var self : this
    width  : 500
    height : 500

    property int  scrollBarNotches : 100
    property bool showScrollBars : true
	property int  scrollBarBtnSize : 32
	property int  scrollBarThickness : 20
	
    property alias container : containerObj
    property alias color     : bgkClrRect.color
	property int vScrollBarOffset  : 0
	property int hScrollBarOffset  : 0
    property int status : Component.Loading
	
    function setEditMode(value, editOptions, par)
	{
        //console.log('ZBASE_PAGE.qml setEditMode')
        kidnapTimer.kidnap()

        if(!par)
            par = containerObj

        for(var c in par.children)
		{
            var child = par.children[c]
            if(child)
            {
                if(child.zEditPtr)
                {
                    child.zEditPtr.editMode = value
                    if(editOptions)
                        child.editOptions = editOptions
                }

                if(child.children.length > 0)
                    setEditMode(value, editOptions, child)
            }
		}


	}
	

    function getChildren()    {        return containerObj.children    }
    function clear()
    {
        for(var i = containerObj.children.length - 1; i >= 0; i--)
        {
            var child = containerObj.children[i]
            child.parent = null
            child.destroy()
        }
    }


    function pdfFunc(arg1)
    {
        for(var c in containerObj.children)
        {
            var child = containerObj.children[c]
            if(typeof child.pdfFunc !== 'undefined')
                child.pdfFunc(arg1)
        }
    }

    Item
    {
        id : clipArea
        property bool dontkillme : true
        width  : rootObject.width
        height : rootObject.height
        clip  : true

		Rectangle
		{
			id : bgkClrRect
			property bool dontkillme : true
			width : rootObject.width
			height : rootObject.height
			color : "white"
		}
		
        Rectangle
        {
            id : containerObj
            width  : parent.width
            height : parent.height
            property bool dontkillme : true
            property bool disableRecursiveKidnapCalls : false
//            onChildrenChanged : console.log("KIDNAPPING HOUR!", children.length)

            color : "transparent"
            visible : true

            function getMaxDimensions()
            {
                var max = {x : 0, y : 0 }
                for(var c in children)
                {
                    var child = children[c]
                    if(child.x + child.width > max.x)         max.x = child.x + child.width
                    if(child.y + child.height > max.y)        max.y = child.y + child.height
                }
                return max
            }


        }


        LoadChecker
        {
            id : loadChecker
            property bool dontkillme : true
            loaderName: rootObject.name ? rootObject.name : "no name loader"

            onAllReady: rootObject.status = Component.Ready
            scans : 3
            overrideWaitForLoad: true
            scanObject : containerObj
        }
    }

    ZBase_Scrollbar
    {
        id : scrolly
        visible : showScrollBars
        width : parent.height
        height : scrollBarThickness
        totalDegrees : scrollBarNotches
        rot : 90
        anchors.left : parent.right
        anchors.top  : parent.top
        anchors.leftMargin : cmpSize + vScrollBarOffset
        property bool dontkillme : true
		cmpSize : scrollBarBtnSize

        onScrollBarChanged :
        {
            var yMove      = containerObj.getMaxDimensions().y / totalDegrees     //the amount we move per change
            containerObj.y  = -index * yMove
        }
    }

    ZBase_Scrollbar
    {
        id : scrollx
        visible : showScrollBars
        width : parent.width
        height : scrollBarThickness
        totalDegrees : scrollBarNotches
        anchors.left : parent.left
        anchors.top : parent.bottom
        anchors.topMargin : scrollBarThickness + hScrollBarOffset
        property bool dontkillme : true
		cmpSize : scrollBarBtnSize

        onScrollBarChanged :
        {
            var xMove       = containerObj.getMaxDimensions().x / totalDegrees     //the amount we move per change
            containerObj.x    = -index * xMove
        }
    }


    //kidnaps stuff form the root into containerObj periodically. Sort of hacky but lets us use stuff like
    //ZPage
    //{
    //  Rect{}
    //}
    //Dont be suprised if all the children seem to have disappared
    Timer
    {
        id : kidnapTimer
        interval : 250
        repeat   : true
        running  : true
        property bool dontkillme : true
        onTriggered: kidnap()

        function kidnap(par)
        {
            if(!par)
                par = rootObject

            for(var i = par.children.length - 1; i >= 0; i--)
            {
                var child = par.children[i]

                if(child.openme)    //we dont want this guy, we just want the children of this guy!
                {
                    kidnap(child)   //recursive loop!
                   // child.destroy() //kill this item. we dont need it no more!
                }
                else if(!child.dontkillme)
                {
//                    console.log('kidnapping a ', child)
                    if(child.hasOwnProperty('status'))
                    {
                        Object.defineProperty(child.data[0],"waitForLoad",{value:true})
//                        child.data[0].waitForLoad = tr
//                        for(var k in child.data[0])
//                            console.log(k)

                        //console.log('finished giving waitForLoad', JSON.stringify(child.data,null,2))
//                        console.log("YAY FOR SOUPY TIMES zabaat so sexy ",typeof child.data[0].waitForLoad)

                    }

                    child.parent = containerObj
                }
            }


        }
    }


    Rectangle
    {
        id : borderRect
        anchors.fill: parent
        border.width: 1
        property bool dontkillme : true
        color : "transparent"
    }

	
	function saveStr(tabStr)
	{
		if(!tabStr)
			tabStr = ""
	
		var str =   tabStr + "import QtQuick 2.0 \n" +
					tabStr + "ZPage\n" +
					tabStr + "{\n" + 
					tabStr + "\tshowScrollBars   : " + showScrollBars + "\n" +
					tabStr + "\tscrollBarNotches : " + scrollBarNotches + "\n" +
					tabStr + "\tvScrollBarOffset : " + vScrollBarOffset + "\n" +
					tabStr + "\thScrollBarOffset : " + vScrollBarOffset + "\n" +
					tabStr + "\tcolor 			 : " + Functions.spch(color) + "\n" 
				
				
		str += childrenSaveStr(tabStr + "\t")			
		str += tabStr + "}\n"
		return str
	}
	
	function childrenSaveStr(tabStr)
	{
		if(!tabStr)
			tabStr = ""
		
		var str = ""	
		for(var c in container.children)
		{
			var child = container.children[c]
			if(child.zEditPtr)
			{
//				console.log("child has saveStr()!!")
				str += child.zEditPtr.saveStr(tabStr + "\t")
			}
		}
			
		return str	
	
	}
	
	
}


