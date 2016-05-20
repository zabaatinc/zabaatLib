import QtQuick 2.0
import "Functions.js" as Functions
import QtQuick.Controls 1.2

Item
{
	id : rootObject
    property var self : this
	property var target : null
	property bool barOrientationRt : true
	property int barWidth 			: 26
	property int cellHeight 		: 48
	property bool scrollBarVisible : true
	property int fontSize : 18
	
	property var dataSectionIdentifiers : []
	property var dataSection : null
	onDataSectionChanged : 	//we want to recurse thru the js object and find everything (expose all properties)
	{
		dataSectionIdentifiers = []
		populateDataSectionIdenfiers(dataSection)
	}
	
	function objEmptyCheck(obj)
	{
		var count = 0
		for(var k in obj)
		{
			count++
			break
		}
		if(count == 0)
			return true
		return false
	}
	
	function populateDataSectionIdenfiers(obj , parentKey)
	{
		if(!parentKey)
			parentKey = ""
	
		for(var key in obj)
		{
		   //console.log(key)
             if(key.toLowerCase().indexOf("ptr") == -1 && key.toLowerCase().indexOf("pointer") == -1 &&
               (Object.prototype.toString.call(obj[key]) === '[object Array]'  ||
               Object.prototype.toString.call(obj[key]) === '[object Object]' ||
               typeof obj[key] === 'object'))
            {
				if(parentKey != "")
				{
					if(!isNaN(key))	//if key is a number
					{
						populateDataSectionIdenfiers(obj[key], parentKey + "[" + key + "]")
						dataSectionIdentifiers.push(parentKey + "[" + key + "]")
					}
					else
					{
						populateDataSectionIdenfiers(obj[key], parentKey + "." + key)
						dataSectionIdentifiers.push(parentKey + "." + key)
					}
				}
				else
				{
					populateDataSectionIdenfiers(obj[key], key)
					dataSectionIdentifiers.push(key)
				}
            }
            else
				if(parentKey != "")
				{
					if(!isNaN(key))	//if key is a number
						dataSectionIdentifiers.push(parentKey + "[" + key + "]")
					else
						dataSectionIdentifiers.push(parentKey + "." + key)
				}
				else
					dataSectionIdentifiers.push(key)
        }
	}
	
	function setTarget(newTarget)
	{
		if(target != null)		// we already have something else. we need to hide its resizeArea
		{
			target.resizeVisible = false
			dataSection = null
            tv.clear()
		}
		
		if(newTarget)
		{
			target = newTarget
			target.resizeVisible = true
			tv.populate()
			
			target.theParent.dataSection = dataSection
			scrollBarVisible = true
		}
		else
		{
			scrollBarVisible = false
		}
	}
	
	
	
	ZBase_Button
	{
		id : delBtn
		btnText : "Delete"
//		radius : height/2
		width : parent.width
		height : 32
		onBtnClicked : 
		{
			if(target)
			{
				target.theParent.destroy()
				setTarget(null)
			}
		}
	}
	
	
	TabView
	{
		id : tv
		
		function populate()
		{
			getTab(0).item.populate(target.theParent.propArr)
			getTab(1).item.populate(target.theParent.eventArr)
		}
		function clear() {}
		
	
		y : delBtn.height
		width : parent.width
		height : parent.height - delBtn.height 
		
		Tab
		{
			title : 'properties'
			width : parent.width
			height : parent.height
			active : true
			

			ZBase_ScrollingColumn
			{
				id : propertiesCol
				width : parent.width
				height : parent.height
				
				barOrientationRt : rootObject.barOrientationRt
				cellHeight 	     : rootObject.cellHeight
				barWidth 		 : rootObject.barWidth
				scrollBarVisible : rootObject.scrollBarVisible
				
				isAnchored : true
				anchors.top 	  : parent.top
				spacing : 0 

				function populate(arr)
				{
					clear()
					for(var a in arr)
					{
						var lbltext = addChild("ZLabelText.qml")
						lbltext.fontSize = fontSize
						lbltext.label = a
						lbltext.value = arr[a]
						lbltext.dataSection = rootObject.dataSectionIdentifiers
						lbltext.labelTextChanged.connect(target.setProp)
					}
					proportionalize.start()
				}
				
				function connector(prop, value)
				{
					if(target)
					{
						try
						{
                            target.propArray[prop] = value			//for saveStr function!!
						}
						catch(e) { console.log(e.message) }
					}
				}
			}
		}
		
		
		Tab
		{
			title : "signals"
			width : parent.width
			height : parent.height
			active : true
		
			ZBase_ScrollingColumn
			{
				id : signalCol
				width : parent.width
				height : parent.height
				
				barOrientationRt : rootObject.barOrientationRt
				cellHeight 	     : rootObject.cellHeight
				barWidth 		 : rootObject.barWidth
				scrollBarVisible : rootObject.scrollBarVisible
				
				isAnchored : true
				anchors.top 	  : parent.top
				spacing : 0 

				function populate(arr)
				{
					clear()
					for(var a in arr)
					{
						var lbltext = addChild("ZLabelText.qml")
						lbltext.fontSize = fontSize
						lbltext.label = a + arr[a].params
						lbltext.value = arr[a].action
						lbltext.dataSection = rootObject.dataSectionIdentifiers
						lbltext.labelTextChanged.connect(target.setSignal)
					}
					proportionalize.start()
				}
				
				function connector(prop, value)
				{
					if(target)
					{
						try
						{
							target.setSignal(prop,value)
							//target.propArray[prop] = value			//for saveStr function!!
						}
						catch(e) { console.log(e.message) }
					}
				}
			}
		
		}
		
		
	}
	
	
	


	
	


}

