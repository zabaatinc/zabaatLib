import QtQuick 2.0
import 'Functions.js' as Functions

Item
{
    id : rootObject
    property var self : this
    width  : 150
    height : 800

    property var container : null
    property alias dataSection : editPanel.dataSection
    property alias editOptions : editPanel
    onContainerChanged: if(container)   zscroll.populate()
    property var objectCreationCallBack : null

    property bool hidden : false
    onHiddenChanged:
    {
        if(hidden)
        {
            x = -width
            allcol.scrollBarVisible = false
        }
        else
        {
            x = 0
            allcol.scrollBarVisible = true
        }
    }

   NumberAnimation on x { duration : 300 }

    Column
    {
        id : allcol
        anchors.fill: parent
        property bool scrollBarVisible : true

        ZBase_ScrollingColumn
        {
            width  : parent.width
            height : parent.height / 2
            scrollBarVisible : parent.scrollBarVisible

            id : zscroll
            cellHeight : 60
            spacing    : 10
			//::CONFIG AREA::  put the components in here that you want to show up in the side bar
            function populate()
            {
                createObject("ZButton")
				createObject("ZReportTable")
                createObject("ZTableView")
				createObject("ZHeaderTableView")
            }


            function createObject(name)
            {
                var obj                         = addChildQml(["QtQuick 2.0", "Zabaat.UI.Wolf 1.0", "'Functions.js' as Functions"], name + "{}" )
                obj.editOptions                 = editPanel
                obj.zEditPtr.restorePosOnDrop   = true
                obj.zEditPtr.editOptionsEnabled = false
                obj.z_Released.connect(creation)

            }


            function creation(name,x,y)
            {
                var point = mapToItem(container, x,y)
                if(objectCreationCallBack == null)
                {
                    if(container)
                    {
                        if(name.indexOf(".qml") != -1)
                            name = name.substr(0,name.length-4)


                        var newObj = Functions.getQmlObject(["QtQuick 2.0", "Zabaat.UI.Wolf 1.0","'Functions.js' as Functions"] , name + "{}", container)
                        newObj.dataSection = dataSection
                        newObj.editOptions = editPanel
                        newObj.x = point.x
                        newObj.y = point.y
                    }

                }
                else
                    objectCreationCallBack(name,point.x,point.y)
            }




        }


        ZEditOptions
        {
            id     : editPanel

            width  : parent.width
            height : parent.height / 2
            scrollBarVisible : parent.scrollBarVisible


            Rectangle
            {
                border.width:  1
                width : 32
                height : width
                radius : height/2
                x : editPanel.width

                MouseArea
                {
                    anchors.fill: parent
                    onClicked: hidden = !hidden
                }
            }
        }
    }


    function setEditMode(value, list)
    {
        var editIO = value ? editPanel : null
        for(var l in list)
            list[l].editOptions = editIO
    }


}





