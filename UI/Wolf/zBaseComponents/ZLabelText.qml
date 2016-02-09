import QtQuick 2.0

Row
{
	id : rootObject
    property var self : this
	width  : 350
	height : 16

    property alias  label  : lbl.text
    property real   labelRatio : 2/5
    property alias  labelColor: lbl.color
    property alias  labelBgkColor : lblrect.color
    property color  labelBorderColor : "black"

    property alias value  : input.text
    property alias valueColor : input.fontColor
    property alias valueBgkColor : input.color
    property color valueBorderColor : "black"

    property int fontSize : 18
	property var dataSection : []


    property int borderWidth : 1

	onDataSectionChanged : 
	{
		if(!dataSection)
			input.model = []
		else
			input.model = dataSection
	}
	
	signal labelTextChanged(string label,string value);
	
	Rectangle
	{
		id 		: lblrect
        width 	: parent.width * labelRatio
		height  : parent.height
        color   : "darkgray" ; border.width : rootObject.borderWidth; border.color : labelBorderColor;
		Text
		{
			id : lbl

			anchors.horizontalCenter : parent.horizontalCenter
			anchors.verticalCenter : parent.verticalCenter
			
			height : parent.height
			
			horizontalAlignment : Text.AlignHCenter; verticalAlignment : Text.AlignVCenter;
			font.pointSize : fontSize
			wrapMode : Text.WrapAnywhere
			
			
			onTextChanged : widthCheck()
			function widthCheck() 
			{
				font.pointSize = fontSize
				while(width > lblrect.width && font.pointSize > 1)
					font.pointSize--
			}
			
			
		}
	}

	
	
	ZBase_AutoCompleteBox
	{
		id : input
        width : parent.width  - lblrect.width
		height : parent.height
        color  : "white" ;
		model : dataSection

		onTextChanged : { labelTextChanged( lbl.text,input.text)}
	}
	
	
	
	

}
