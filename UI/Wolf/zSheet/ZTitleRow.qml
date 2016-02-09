import QtQuick 2.0
import "Functions.js" as Functions
Item
{
    id : boxContainer
    width: 100
    height: 62

    property var      ordering    : []

    property variant  arr         : []
    property int      arrLen      : arr.length
    property color    bgkColor    : "green"
    property color    textColor   : "white"
    property int      fontSize    : 20
    property bool     boxesEnabled : false
    property bool     init          : false

//    onArrLenChanged: if(init) update()
//    onArrChanged   : if(init) update()


    function getXOf(cellNum)
    {
        if(cellNum > -1 && cellNum < children.length)
            return children[cellNum].x
        else
            return 0
    }


    function printOrdering()
    {
        console.log("Ordering")
        for(var i = 0; i < ordering.length; ++i)
            console.log(ordering[i], children[ordering[i]].index, arr[ordering[i]])
    }

    function updatePositions(self,xPos,yPos)
    {
        var newIndex = findIndexAtPos(xPos)

//        console.log("index",self.index,"newIndex",newIndex)
        if(newIndex < self.index)
        {
            for(var i = newIndex ; i < self.index ; ++i)
            {
                var child = getChildAt(i)
                if(child != null)
                {
                    child.index++
                    ordering[child.index] = child.arrIndex
                }
            }

            self.index = newIndex
            ordering[self.index] = self.arrIndex
        }
        else if(newIndex > self.index)
        {
            //in this case, we will just swap?
            child = getChildAt(newIndex)
            if(child != null)
            {
                child.index = self.index
                ordering[self.index] = child.arrIndex
            }


            self.index = newIndex
            ordering[self.index] = self.arrIndex
        }
        updateView()
    }


    function getChildAt(orderIndex)
    {
        for(var i = 0; i < children.length; ++i)
        {
            if(children[i].index == orderIndex)
                return children[i]
        }
        return null
    }


    function updateView()
    {
        for(var i = 0; i < children.length; ++i)
        {
            children[ordering[i]].x = children[i].width * (i)
            children[i].color = bgkColor
        }
    }

    function updateZValues(obj)
    {
        for(var C in children)
            children[C].z = -1
        obj.z = 1
    }

    function updateHighlight(self,xPos,yPos)
    {
        var newIndex = findIndexAtPos(xPos)
        for(var C in children)
            children[C].color = bgkColor

        if(newIndex != self.index)
            children[ordering[newIndex]].color = "yellow"
    }

    function findIndexAtPos(xPos)
    {
        var deltaX      = width / children.length
        var newIndex    = Math.floor(xPos / deltaX)


        //safety checks
        if(newIndex < 0)
            newIndex = 0
        else if(newIndex >= children.length)
            newIndex = children.length -1

        return newIndex
    }


    function update()
    {
        if(arr != null && arr.length > 0)
        {
            if(children.length != arr.length)
            {
                children = []
                ordering = []
                for(var i = 0; i < arr.length; i++)
                {
                    var obj        = Functions.getNewObject("ZDragCell.qml",boxContainer)
                    obj.allowYDrag = false
                    obj.width      = Qt.binding(function() { return width / children.length })
                    obj.height     = Qt.binding(function() { return height})
                    obj.color      = Qt.binding(function() { return bgkColor})
                    obj.fontColor  = Qt.binding(function() { return textColor})
                    obj.fontSize   = Qt.binding(function() { return fontSize})
                    obj.text       = Qt.binding(function() { return arr[i]})
                    obj.isEnabled  = Qt.binding(function() { return boxesEnabled})

                    ordering[i]    = obj.index      = obj.arrIndex =  i

                    obj.dragStarted.connect(updateZValues)
                    obj.beingDragged.connect(updateHighlight)
                    obj.gotDragged.connect(updatePositions)
                }
            }
            else
            {
                for(var j = 0; j < arr.length; j++)
                    children[j].text = arr[j]
            }
            updateView()
        }
    }




}






