import QtQuick 2.0
import "Functions.js" as Functions
import Zabaat.Controller 1.0

Rectangle
{
    //Expects its model Obj to be :

//    [  { header:[ {label : "station",   text : "programmer"  , align : "left" ,    row : "1"},
//                                           {label : "id",        text : "0"           , align : "right" ,  row : "1"},
//                                           {label : "firstName", text : "Shahan",       align : "left" ,    row : "0"},
//                                           {label : "lastName",  text : "Kazi"  ,       align : "right",    row : "0"},
//                                           {label : "MI",        text : "S"  ,          align : "center",    row : "0"}
//                                           ]
//                                         ,
//                                  model :  [{hoursLogged : "2", project : "Leviathan"  },
//                                            {hoursLogged : "1", project : "PdfWriter"  },
//                                            {hoursLogged : "0", project : "ZeusIsAngry"},

//                                            {hoursLogged : "1 ",   project : "Leviathan"  },
//                                            {hoursLogged : "2 ",   project : "PdfWriter"  },
//                                            {hoursLogged : "3 ",   project : "ZeusIsAngry"},
//                                            {hoursLogged : "4 ",   project : "Leviathan"  },
//                                            {hoursLogged : "5 ",   project : "PdfWriter"  },
//                                            {hoursLogged : "6 ",   project : "ZeusIsAngry"},
//                                            {hoursLogged : "7 ",   project : "Leviathan"  },
//                                            {hoursLogged : "8 ",   project : "PdfWriter"  },
//                                            {hoursLogged : "9 ",   project : "ZeusIsAngry"},
//                                            {hoursLogged : "10",   project : "Leviathan"  },
//                                            {hoursLogged : "11",   project : "PdfWriter"  },
//                                            {hoursLogged : "12",    project : "ZeusIsAngry"},

//                                            {hoursLogged : "14",   project : "Leviathan"  },
//                                            {hoursLogged : "15",   project : "PdfWriter"  },
//                                            {hoursLogged : "16",   project : "ZeusIsAngry"},
//                                            {hoursLogged : "17",   project : "Leviathan"  },
//                                            {hoursLogged : "18",   project : "PdfWriter"  },
//                                            {hoursLogged : "19",   project : "ZeusIsAngry"},
//                                            {hoursLogged : "20",   project : "Leviathan"  },
//                                            {hoursLogged : "21",   project : "PdfWriter"  },
//                                            {hoursLogged : "22",   project : "ZeusIsAngry"},
//                                            {hoursLogged : "23",   project : "Leviathan"  },
//                                            {hoursLogged : "24",   project : "PdfWriter"  },
//                                            {hoursLogged : "25",    project : "ZeusIsAngry"},
//                                            {hoursLogged : "26",   project : "ZeusIsAngry"},
//                                            {hoursLogged : "27",   project : "Leviathan"  },
//                                            {hoursLogged : "28",    project : "PdfWriter"  },
//                                            {hoursLogged : "29",    project : "HatingWolf"  },
//                                            {hoursLogged : "30",    project : "HatingWolf"  },
//                                            {hoursLogged : "31",    project : "HatingWolf"  },
//                                            {hoursLogged : "32",    project : "HatingWolf"  },
//                                            {hoursLogged : "33",    project : "HatingWolf"  },
//                                            {hoursLogged : "34",    project : "LovingWolf"  }
//                                           ]
//                                }


//                                ,{ header:[ {label : "firstName", text : "Matt",                                align : "left" ,    row : "0"},
//                                           {label : "MI",        text : "B"  ,                                 align : "center",    row : "0"},
//                                           {label : "lastName",  text : "Ansite"  ,                            align : "right",    row : "0"},
//                                           {label : "station",   text : "bytemaster netlord tunawhisperer"  ,  align : "left" ,    row : "1"},
//                                           {label : "id",        text : "0"           ,                        align : "right" ,  row : "1"}]
//                                           ,
//                                  model :  [{hoursLogged : "1 ",   project : "Leviathan"  },
//                                            {hoursLogged : "2 ",   project : "PdfWriter"  },
//                                            {hoursLogged : "3 ",   project : "ZeusIsAngry"},
//                                            {hoursLogged : "4 ",   project : "Leviathan"  },
//                                            {hoursLogged : "5 ",   project : "PdfWriter"  },
//                                            {hoursLogged : "6 ",   project : "ZeusIsAngry"},
//                                            {hoursLogged : "7 ",   project : "Leviathan"  },
//                                            {hoursLogged : "8 ",   project : "PdfWriter"  },
//                                            {hoursLogged : "9 ",   project : "ZeusIsAngry"},
//                                            {hoursLogged : "10",   project : "Leviathan"  },
//                                            {hoursLogged : "11",   project : "PdfWriter"  },
//                                            {hoursLogged : "12",    project : "ZeusIsAngry"},

//                                            {hoursLogged : "14",   project : "Leviathan"  },
//                                            {hoursLogged : "15",   project : "PdfWriter"  },
//                                            {hoursLogged : "16",   project : "ZeusIsAngry"},
//                                            {hoursLogged : "17",   project : "Leviathan"  },
//                                            {hoursLogged : "18",   project : "PdfWriter"  },
//                                            {hoursLogged : "19",   project : "ZeusIsAngry"},
//                                            {hoursLogged : "20",   project : "Leviathan"  },
//                                            {hoursLogged : "21",   project : "PdfWriter"  },
//                                            {hoursLogged : "22",   project : "ZeusIsAngry"},
//                                            {hoursLogged : "23",   project : "Leviathan"  },
//                                            {hoursLogged : "24",   project : "PdfWriter"  },
//                                            {hoursLogged : "25",    project : "ZeusIsAngry"},
//                                            {hoursLogged : "26",   project : "ZeusIsAngry"},
//                                            {hoursLogged : "27",   project : "Leviathan"  },
//                                            {hoursLogged : "28",    project : "PdfWriter"  },
//                                            {hoursLogged : "29",    project : "HatingWolf"  },
//                                            {hoursLogged : "30",    project : "HatingWolf"  },
//                                            {hoursLogged : "31",    project : "HatingWolf"  },
//                                            {hoursLogged : "32",    project : "HatingWolf"  },
//                                            {hoursLogged : "33",    project : "HatingWolf"  }
//                                           ]
//                                 }
//    ]


    id : rootObject
    property var self : this


    color : "white"

    width : pgWidth
    height : 500

    property var uniqueProperties   : ["model","clientPtr","networkSource","isReportTable","hideColumns","headerFontSize","headerFontColor","pgWidth","pgHeight","spacing", "cellColor", "cellColor_Alternate"]
    property var uniqueSignals      : ({})

    property var   clientPtr       : null   //expects a connected CLIENT!
    property var   networkSource   : null
    property var   model           : null
    property int   headerFontSize  : 14
    property color headerFontColor : "green"
    property bool  isReportTable   : false
    property int   status          : Component.Null
    property int   pgWidth         : 1000
    property int   pgHeight        : 500
    property var   hideColumns     : []
    property color cellColor       : "white"
    property color cellColor_Alternate : "#dfdfdf"


    property int   spacing: 5

    //This is just so our component menu can see what this is from the sidebar.
    Text
    {
        text : "ZHeaderTableView"
        font.pointSize: 12
        visible : model ? false : true
        width : rootObject.width
    }


    //This timer is here to stagger the creation of tables until we are sure our rootObject's width and height are set correctly.
    //This is dumb I know but talk to Qt. It's silly.
    Timer
    {
        id : initTimer
        interval : 250
        running : true
        repeat : false
        onTriggered :
        {
            status = Component.Loading
            if(model && model != "null")                createViewsOnModel()
            else if(networkSource)                      doNetworkRequest()
        }
    }


    Component.onCompleted : if(networkSource                            && status != Component.Null)    doNetworkRequest()
    onNetworkSourceChanged: if(networkSource && networkSource != "null" && status != Component.Null)    doNetworkRequest()
    onModelChanged        : if(model && model != "null"                 && status != Component.Null)    createViewsOnModel()
    onIsReportTableChanged: if(model && model != "null"                 && status != Component.Null)    createViewsOnModel()

    function clear()
    {
        col.contentItem.children = []
    }

    function translateY(yVal)
    {
        if(yVal > pgHeight)
            return yVal % pgHeight
        return yVal
    }

    function doNetworkRequest()
    {
        //console.log("doing network request")
        if(clientPtr && typeof clientPtr !== 'undefined' && clientPtr != "null")
            clientPtr.postReq(networkSource,{}, function(response) { console.log(JSON.stringify(response,null,2)); model = response[0] }, null, true    )
    }

    function createViewsOnModel()
    {
        console.log("create views on table")

        clear()
        var yVal = 0
        for(var m in model)
        {
            if(model[m].header)
            {
                var header = makeNewHeader(model[m].header)
                header.y   = yVal

                if(isReportTable && translateY(header.y) > translateY(header.y + header.height) )
                {
                    header.y += (pgHeight - translateY(header.y)) + 2
                    yVal     += (pgHeight - translateY(header.y)) + 2
                }

                var table = makeNewTable(model[m].model, header.y + header.height)
                yVal += header.height + table.height

                col.contentHeight += yVal
                yVal += spacing
            }
        }


        var lastItem = col.contentItem.children[col.contentItem.children.length - 1]
        if(lastItem)
            rootObject.height = lastItem.y + lastItem.height

        status = Component.Ready
    }

    function makeNewHeader(headerArray)
    {
        var header   = Functions.getQmlObject(["QtQuick 2.0"], "Rectangle{}", col.contentItem)
        header.border.width = 1
        header.width = Qt.binding(function() { return pgWidth } )

        var rows = []   //just to count how many actual rows there are!! so we can accurately set the height of our headerObject which contains all the text elements
        for(var i = 0; i < headerArray.length; i++)
        {
            var textI   = Functions.getQmlObject(["QtQuick 2.0"], "Text{}", header)
            textI.font.pointSize = Qt.binding(function() { return rootObject.headerFontSize } )
            textI.color = Qt.binding(function() { return rootObject.headerFontColor } )
            textI.width = Qt.binding(function() { return rootObject.width } )
            textI.anchors.left = header.left
            textI.text = "<b>" +  headerArray[i].label + "</b> : " + headerArray[i].text

            if(headerArray[i].align)
            {
                if      (headerArray[i].align == "center")        textI.horizontalAlignment = Text.AlignHCenter
                else if (headerArray[i].align == "right")         textI.horizontalAlignment = Text.AlignRight
            }

            var rowNum = Number(headerArray[i].row)
            if(rowNum > 0)
            {
                textI.y = textI.height * rowNum + 5 //5 is the px gap
                rows[rowNum] = true
            }
        }

        header.height = rows.length * (textI.height + 5)
        return header
    }


    function makeNewTable(model ,yPos)
    {
        if(!isReportTable)
        {
            var lm
            if(!model.hasOwnProperty('count'))  //is not a model
            {
                lm = Functions.getQmlObject(["QtQuick 2.0", "QtQuick.Controls 1.3"], "ListModel{}", lmContainer )
                lm.append(model)
            }
            else
                lm = model

            var table = Functions.getNewObject("ZBase_ZTableView.qml",col.contentItem)

            table.cellColor = cellColor
            table.cellColor_Alternate = cellColor_Alternate
            table.hideColumns = hideColumns
            table.y = yPos
            table.width = Qt.binding(function() { return pgWidth } )
            table.model = lm


            return table
        }
        else
        {
            console.log('not chaning model')
            var rtable      = Functions.getNewObject("ZBase_ZReportTable.qml",col.contentItem)
            rtable.hideColumns = hideColumns
            rtable.bgkColor    = cellColor
            rtable.y        = yPos
            rtable.pgWidth  = Qt.binding(function()  { return rootObject.pgWidth         } )
            rtable.pgHeight = Qt.binding(function()  { return rootObject.pgHeight        } )
            rtable.model    = model

            return rtable
        }
    }




    Item       {  id : lmContainer  }
    Flickable
    {
        id : col
        width : rootObject.width
        height : rootObject.height
        contentWidth:  rootObject.width
//        contentHeight: contentItem.childrenRect.height
    }



    //we are sorting the headerArray based on the row numbers
//        headerArray.sort(function(a,b)
//        {
//           var numA = Number(a.row)    //if this thing isnt a number, try converting it to one
//           var numB = Number(b.row)    //if this thing isnt a number, try converting it to one
//           if(numA && numB)
//               return numA - numB
//           return 0
//        } )


}
