import QtQuick 2.0

// ZDragCell, Ver 1.0 , 11/19/2014 by SSK
// Built on top of ZCell. Used specifically in draggable containers (titleRow)
ZCell
{
    id : rootObject
    property int index      //The displayIndex of this item
    property int arrIndex   //The arrayIndex in the parent Container where this object resides

    signal dragStarted (var self)                          //Notifies that a drag was started
    signal beingDragged(var self, real xPos, real YPos)    //Notifies that it is currently being dragged
    signal gotDragged  (var self, real xPos, real YPos)    //Notifies that a drag was finished

    property real oldX : x                    //An internal property that lets us assign dragTypeX
    property real oldY : y                    //An internal property that lets us assign dragTypeY

    property bool dragTypeX : false            //false = leftDrag , true = rightDrag
    property bool dragTypeY : false            //false = downDrag , true = upDrag

    property bool allowXDrag : true            //enables / disables X dragging
    property bool allowYDrag : true            //enables / disables Y dragging

    //handle change of allowXDrag
    onAllowXDragChanged:
    {
        if(allowXDrag)
        {
            if(allowYDrag)                msArea.drag.axis = Drag.XAndYAxis
            else                          msArea.drag.axis = Drag.XAxis
        }
        else
        {
            if(allowYDrag)                msArea.drag.axis = Drag.YAxis
            else                          msArea.drag.axis = Drag.None
        }
    }

    //handle change of allowYDrag
    onAllowYDragChanged:
    {
        if(allowYDrag)
        {
            if(allowXDrag)                msArea.drag.axis = Drag.XAndYAxis
            else                          msArea.drag.axis = Drag.YAxis
        }
        else
        {
            if(allowXDrag)                msArea.drag.axis = Drag.XAxis
            else                          msArea.drag.axis = Drag.None
        }
    }

    //The mouse area in charge of the drag (this fills the whole cell)
    MouseArea
    {
        id : msArea
        anchors.fill: parent
        drag.target: parent

        property bool isDragging : drag.active
        onIsDraggingChanged      :
        {
            if(!drag.active) gotDragged(rootObject,getXBasedOnDragTypeX(),getYBasedOnDragTypeY())
            else             dragStarted(rootObject)
        }
    }

    //If the X is changed of this object and MsArea has drag.active, it calls the beingDragged!
    onXChanged:
    {
        if(msArea.isDragging)
        {
            if(oldX < x)       dragTypeX = true      //dragging right
            else if(oldX > x)  dragTypeX = false     //dragging left

            oldX = x
            beingDragged(rootObject, getXBasedOnDragTypeX(), getYBasedOnDragTypeY())
        }
    }

    //If the Y is changed of this object and MsArea has drag.active, it calls the beingDragged!
    onYChanged:
    {
        if(msArea.isDragging)
        {
            if     (oldY < y)  dragTypeY = false      //dragging down
            else if(oldY > y)  dragTypeY = true       //dragging up

            oldY = y
            beingDragged(rootObject, getXBasedOnDragTypeX(), getYBasedOnDragTypeY())
        }
    }


    //Returns a different xPos based on what type of drag is done.
    //If it's leftwards  -> return the leftEdge of the cell (just the x position)
    //If it's rightwards -> return the rightEdge of the cell (the x position + the width of the cell)
    function getXBasedOnDragTypeX()
    {
        if(dragTypeX)            return x + width
        else                     return x
    }

    //Returns a different yPos based on what type of drag is done
    //If it is upwards   -> return the top edge of the cell (just the y position)
    //If it is downwards -> return the bot edge of the cell (the y position + the height of the cell)
    function getYBasedOnDragTypeY()
    {
        if(dragTypeY)           return y
        else                    return y + height
    }



}
