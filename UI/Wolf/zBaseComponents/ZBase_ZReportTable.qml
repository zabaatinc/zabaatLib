import QtQuick 2.0
import QtQuick.Controls 1.2
import "Functions.js" as Functions

/*! \brief Generates multiple ZTableViews, cutting them off at pgHeight distances. This is useful for short pdf Reports. Fails Qt's grabImage method (for pdf saving) if the table(s) are very large.
    \inqmlmodule Zabaat.UI.Wolf 1.0
*/
Rectangle
{
    id : rootObject
    property var self : this
    width  : pgWidth
    height : pgHeight

    property var uniqueProperties : ["pgWidth","pgHeight","model", "hideColumns", "bgkColor"]
    property var uniqueSignals    : ({})
    property var hideColumns      : []

    color : "white" //change to transparent when qt fixes their pdf transparent glitch!
//    border.width : 1

    signal isDying(var obj)
    Component.onDestruction: isDying(this)

    /*! The pixel width of the page. This is used for DPI transformations/conversions */
    property int pgWidth  : 377

    /*! The pixel height of the page. This is used for DPI transformations/conversions */
    property int pgHeight : 522

    /*! The background color of the drawable table(s). */
    property color bgkColor : "white"

    /*! This is the object that provides all the data and the style data for this class. This is an array of objects of type { header : [arr] , model : [arr] }
      \code
      //example
      model : [ { header : [ {row : 1, label : 'firstName', text : 'Wolf', align : 'left' },
                             {row : 1, label : 'lastName', text : 'Man',  align : 'right' } ]
                  model :  [ { hoursWorked : 10, onDay : 'wednesday' },
                             { hoursWorked : 10, onDay : 'thursday' }]
                },
                { header : [ {row : 1, label : 'firstName', text : 'Tuna', align : 'left' },
                             {row : 2, label : 'lastName', text : 'Warrior',  align : 'right' } ]
                  model :  [ { hoursWorked : 20, onDay : 'wednesday' },
                             { hoursWorked : 30, onDay : 'thursday' }]
                }
              ]
      \endcode
    */
    property var model : null
    onModelChanged     : if(model != null && typeof model !== 'undefined' && model != "null") makeNewTable(model, true)

    //This is just so our component menu can see what this is from the sidebar.
    Text
    {
        text : "ZReportTable"
        font.pointSize: 12
        visible : model ? false : true
        width : rootObject.width
    }

//    Timer
//    {
//        id : modelCheckTimer
//        interval : 250
//        repeat : true
//        running : true
//        onTriggered :
//        {
//            console.log("checking model",model)
//            if(model != null)
//            {
//                console.log("NEW MODEL")
//                makeNewTable(model)
//                stop()
//            }
//        }

//    }


    function translateY()
    {
        if(rootObject.y > pgHeight)
            return rootObject.y % pgHeight
        return rootObject.y
    }


    function makeNewTable(model, first)
    {
        var lm

        if(!model.hasOwnProperty('count'))
        {
            lm = Functions.getQmlObject(["QtQuick 2.0", "QtQuick.Controls 1.3"], "ListModel{}", lmContainer )
            lm.append(model)
        }
        else
            lm = model

        var relY = translateY()

        var table    = Functions.getNewObject("ZBase_ZTableView.qml",col)
        table.width  = Qt.binding(function() { return  pgWidth} )
        table.height = first ?  pgHeight - relY : pgHeight
        table.alternatingRowColors = false
        table.cellColor = table.cellColor_Alternate = bgkColor
        table.hideColumns = hideColumns

        if(!first)
        {
            var lastCreated = col.children[col.children.length - 2]
            table.y         = lastCreated.y + lastCreated.height + 3
        }

        rootObject.height = col.children.length * pgHeight - relY

        table.model = lm
        if(first)            breakIntoPages(table, model, relY )
        else                 breakIntoPages(table, model)
    }

    function breakIntoPages(element, model , yPos)
    {
        if(!yPos)
            yPos = 0

        var newModel = []

        //the way to determine that we need to break this table further apart is to know if the element at the edge of the page is the last one or not?
        var row = element.rowAt(10, pgHeight - yPos - 1)
        if(row != -1 && row != element.rowCount - 1)    //isnt the last row
        {
            var index = 0
            for(var i = row  -1 ; i < model.length; i++)
            {
                newModel[index]  = model[i]
                element.model.remove(element.model.count - 1)
                index++
            }

            if(newModel.length != 0)
                makeNewTable(newModel)
        }
        else
        {
            //we should resize the table to be exactly as long as its row
            var lastY = pgHeight + yPos
            while(element.rowAt(10, lastY) == -1)
                lastY -= 10

            while(element.rowAt(10,lastY) != -1)
                lastY++

            lastY += element.headerHeight

            element.height = lastY
            //rootObject.height -= (pgHeight - lastY )
            rootObject.height = element.y + element.height

        }
    }


    Item  {  id : lmContainer   }
    Item  {  id : col;    anchors.fill : parent  }



}
