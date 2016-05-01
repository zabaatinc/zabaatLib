import QtQuick 2.0
import "Functions.js" as Functions
Rectangle
{
	id : rootObject
    property var self : this

    signal isDying(var obj)
    Component.onDestruction: isDying(this)

    property var  theParent
	property var  editOptions
	
    property bool emitSignalOnRelease : false
	property bool resizeVisible  	  : false
	property bool restorePosOnDrop 	  : false 
	property bool editOptionsEnabled  : true
	property bool editMode 			  : false

    property int origX : 0
    property int origY : 0

    signal zPressed()
    signal zReleased(string name,int x,int y)

	onEditOptionsChanged : 
	{
		if(editOptions) 
		{ 
			editMode = true; 
			if(theParent)
			{
				origX = theParent.x
				origY = theParent.y
				
				//theParent never has had his properties set by our editor!
				if(theParent.propArr && theParent.propArr.length == 0)
				{
					for(var i = 0; i < theParent.uniqueProperties.length; i++)
                    {
                        if(theParent[theParent.uniqueProperties[i]] != null)
                            theParent.propArr[theParent.uniqueProperties[i]] = theParent[theParent.uniqueProperties[i]].toString()
                        else
                            theParent.propArr[theParent.uniqueProperties[i]] = "null"
                    }
						
                    theParent.propArr['x'] = theParent.x
                    theParent.propArr['y'] = theParent.y
					theParent.propArr['rotation'] = theParent.rotation 
					theParent.propArr['width']    = theParent.width 
					theParent.propArr['height']   = theParent.height 
				}
				
				if(theParent.eventArr && theParent.eventArr.length == 0)
				{
					for(var s in theParent.uniqueSignals)
                        theParent.eventArr['on' + capitalizeFirstLetter(s)] = {  params : "(" + theParent.uniqueSignals[s].join(",") + ")" , action : "" }
						
					for(i = 0; i < theParent.uniqueProperties.length; i++)
					{
                        var sigName = "on" + capitalizeFirstLetter(theParent.uniqueProperties[i]) + "Changed"
						theParent.eventArr[sigName] = { params : "()" , action : "" }
					}
					
					theParent.eventArr['onXChanged'] 		= { params : "()" , action : "" }
					theParent.eventArr['onYChanged'] 		= { params : "()" , action : "" }
					theParent.eventArr['onRotationChanged'] = { params : "()" , action : "" }
					theParent.eventArr['onWidthChanged'] 	= { params : "()" , action : "" }
					theParent.eventArr['onHeightChanged'] 	= { params : "()" , action : "" }
				}
			}
		}
		else 
			editMode = false;
	}
	
	function restorePos()
	{
		if(theParent)
		{
			theParent.x = origX
			theParent.y = origY
		}		
	}
	

    function getPropArr()
    {
       return theParent.propArr;
    }

    function saveStr(tabStr)
    {
        if(!tabStr)
            tabStr = ""

        //first lets add the name of this component!!
        var s_str   = tabStr + theParent.fileName.substring(0,theParent.fileName.length - 4)
        s_str += "\n" + tabStr + "{\n"


        //deal with properties
        var propArr = theParent.propArr

        //if we didnt explicitly define these essential properites, we should just grab them from the parent!
        if(!propArr['x'])          s_str += tabStr + "\tx:" + theParent.x + "\n"
        if(!propArr['y'])          s_str += tabStr + "\ty:" + theParent.y + "\n"
        if(!propArr['width'])      s_str += tabStr + "\twidth:"  + theParent.width  + "\n"    //To keep a ratio to the parent, so the whole thing scales
        if(!propArr['height'])     s_str += tabStr + "\theight:"  + theParent.height + "\n"    //To keep a ratio to the parent, so the whole thing scales
        if(!propArr['rotation'])   s_str += tabStr + "\trotation:"  + theParent.rotation + "\n"    //To keep a ratio to the parent, so the whole thing scales

        for(var p in propArr)
        {
            var value = propArr[p]

            if(value.length > 0)
            {
                if(value.charAt(0) == '&')    //we have stumbled onto a binding!!
                    s_str += tabStr + "\t" + p+ ": dataSection." + value.substring(1,value.length) + "\n"
                else
                {
                    if(value != "true" && value != "false" && (isNaN(value) || value.length == 0))   //if val is NOT a number we need to speechify it
                        value = Functions.spch(value)

                    s_str += tabStr + "\t" + p+ ":" + value + "\n"
                }
            }
        }


        //deal with signals
        var sigArr = theParent.eventArr
        for(var s in sigArr)
        {
            value = sigArr[s]
            if(value.length > 0)
            {
                if(value.charAt(0) == '&')    //we have stumbled onto a binding!!
                    s_str += tabStr + "\t" + s+ ": dataSection." + value.substring(1,value.length) + "\n"
                else
                    s_str += tabStr + "\t" + s+ ":{" + value + "}\n"
            }
        }

		
			s_str += tabStr + "\tpropArr : ({" 
		
			for(p in propArr)
			{
				value = propArr[p]
				if(isNaN(value) || value.length == 0)
					value = Functions.spch(value)

				s_str += "\n" + tabStr + "\t\t\t\t" + p + ":" + value + ","
			}
            if(s_str.charAt(s_str.length -1) == ',')    s_str = s_str.substring(0,s_str.length-1) + "})\n"
            else                                        s_str += "})\n"
		
            s_str += tabStr + "\teventArr : ({"
			for(p in sigArr)
			{
				value = sigArr[p]
                if(value != "[object Object]")
                {
                    if(isNaN(value) || value.length == 0)
                        value = Functions.spch(value)

                    s_str += "\n" + tabStr + "\t\t\t\t" + p + ":" + value + ","
                }
			}
            if(s_str.charAt(s_str.length -1) == ',')    s_str = s_str.substring(0,s_str.length-1) + "})\n"
            else                                        s_str += "})\n"
			
			
		
		//now lets save our propArr and eventArr for RE-EDITING this thing!
		//s_str += tabStr + "\t" + "propArr  : " + JSON.stringify(propArr)  + "\n"
		//s_str += tabStr + "\t" + "eventArr : " + JSON.stringify(sigArr) + "\n"
		
		
		
		
        s_str += tabStr + "}\n"

        return s_str
    }


    function capitalizeFirstLetter(string)
    {
        return string.charAt(0).toUpperCase() + string.slice(1);
    }


    function setProp(name, value)
    {
        if(value.length > 0)
        {
            if(value.charAt(0) == "&")
            {
                value = value.substring(1,value.length)
                if(theParent.dataSection && parseValueInDataSection(value) )
                {
                    //hee hee we has this value in the data section! be happy and rejoice
					try
					{
                        theParent[name] 		= parseValueInDataSection(value)
						theParent.propArr[name] = "&" + value
					}
                    catch(e){ console.log(e.message)}
                }
            }
            else
            {
                try
                {
                    theParent[name] = value
                    theParent.propArr[name] = value
                }
                catch(e){ console.log(e.message)}
            }
        }
    }

    function setSignal(name, value)
    {
        if(value.length > 0)
        {
            name = name.substring(0, name.indexOf("("))
            theParent.eventArr[name] = value
        }
    }


    function parseValueInDataSection(value)
    {
        if(Object.prototype.toString.call(value) !== '[object Array]' )
        {
            value = value.split('[').join('.')	//remove all  [
            value = value.split(']').join('')  //replace all ] with .
            value = value.split('.')
        }

        if(theParent && theParent.dataSection)
        {
            var obj = theParent.dataSection
            for(var i = 0; i < value.length ; i++)
            {
                if(obj)
                    obj = obj[value[i]]
                else
                    break
            }
            return obj
        }
        return null
    }


    Rectangle
    {
        id     : edit_moveCircle

        border.color: "black"
        border.width: 1
        color : "transparent"

        width   : enabled ? theParent.width : 0
        height  : enabled ? theParent.height : 0
        enabled : theParent && editOptions && editMode
		visible : enabled

        x : 0
        y : 0

        MouseArea
        {
            id : moveArea

            hoverEnabled: true
            anchors.fill: parent
            drag.target : theParent
			
			property bool dragActive : drag.active
			
            onDoubleClicked : if(editOptions && editOptionsEnabled) editOptions.setTarget(rootObject)
			onDragActiveChanged : 
			{
				if(!dragActive)	
				{
					zReleased(theParent.fileName,theParent.x,theParent.y)
					if(restorePosOnDrop)
						restorePos()
				}
                else
                    zPressed()
			}

        }
    }

	Rectangle
    {
        id : rotRect
        width : resizeArea.width
        height : resizeArea.height
		x : theParent ?  theParent.width/2  - width/2  	: width/2
		y : theParent ?  theParent.height/2 - height/2	: height/2
		visible :theParent && editOptions && resizeVisible && editMode
        border.color: "black"
        border.width: 3
		radius : height/2
        color : "yellow"

        onXChanged: if(rotationArea.dragActive)  calcAngle(x,y)
        onYChanged: if(rotationArea.dragActive)  calcAngle(x,y)

        function calcAngle(X,Y)
        {
            var rad   = Math.atan(Y/X)
            var deg   = (rad * 180/Math.PI)

            theParent.rotation += deg
//            rootObject.functions.rotateKids(assignedPartName,deg)
//            rootObject.oldRot = rootObject.rotation
        }


        MouseArea
        {
            id : rotationArea
            anchors.fill: parent
            drag.target: parent
            property bool dragActive : drag.active
			onDragActiveChanged:
			{
				if(!dragActive)
				{
					rotRect.x =  theParent ?  theParent.width/2  - width/2   : width/2
					rotRect.y =  theParent ?  theParent.height/2 - height/2	 : height/2
				}
			}
        }
    }
	
    Rectangle
    {
        id     : edit_resizeCircle

        border.color: "black"
        border.width: 2

        width  : 15
        height : 15
        radius : 7
        visible : enabled
        enabled : theParent && editOptions && resizeVisible && editMode


        x : enabled ? theParent.width - width : 0
        y : enabled ? theParent.height - height : 0

        MouseArea
        {
            id : resizeArea


            hoverEnabled: true
            anchors.fill: parent
            drag.target : parent

            onPressed : {myTimer.start(); myTimer.oldX = parent.x; myTimer.oldY = parent.y }
            onReleased: myTimer.stop()


            Timer
            {
                property int oldX : 0
                property int oldY : 0

                id : myTimer
                interval : 20
                repeat: true
                running :false
                onTriggered:
                {
                    var deltaX = oldX - edit_resizeCircle.x
                    var deltaY = oldY - edit_resizeCircle.y

                    theParent.width  -= deltaX
                    theParent.height -= deltaY

                    oldX = edit_resizeCircle.x
                    oldY = edit_resizeCircle.y
                }
            }
        }
    }










}
