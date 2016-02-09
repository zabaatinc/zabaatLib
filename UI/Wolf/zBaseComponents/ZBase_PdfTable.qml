import QtQuick 2.0
import QtQuick.Controls 1.2
import "Functions.js" as Functions
import Zabaat.PdfTools 1.0


/*! \brief Generates a pdf using the model provided. This table generated will be in text format! The model can be a listModel or an object array. It will be autoconverted into a listmodel. Requires a pointer of type
    PdfWriter to function. The PdfWriter qml type can be found in Zabaat.PdfTools 1.0. This does not save the pdf but rather draws a multiline text onto the cache of the PdfWriter. The PdfWriter's finalize() method
    must be called to save.

    \inqmlmodule Zabaat.UI.Wolf 1.0
    \relates PdfWriter, Zabaat.PdfTools 1.0
*/
Rectangle
{
    id : rootObject
    property var self : this
    width  : pgWidth
    height : pgHeight

    signal isDying(var obj)
    Component.onDestruction: isDying(this)

    property var uniqueProperties : ["pgWidth","pgHeight","bgkColor","pdfWriterPtr","model","styleInfo","fontName","fontSize","fontBold","fontItalic"]
    property var uniqueSignals    : ({})

    property int status : Component.Loading

    /*! The pixel width of the page. This is used for DPI transformations/conversions */
    property int pgWidth      : 377

    /*! The pixel width of the page. This is used for DPI transformations/conversions */
    property int pgHeight     : 522

    /*! The background color of the drawable item. */
    property color bgkColor   : "white"

    /*! The pointer to a PdfWriter qml object. Needed for this one to function */
    property var pdfWriterPtr : null

    /*! The default font to draw the table in */
    property alias fontName   : fontContainer.font.family

    /*! Self explanatory */
    property alias fontBold   : fontContainer.font.bold

    /*! Self explanatory */
    property alias fontSize   : fontContainer.font.pointSize

    /*! Self explanatory */
    property alias fontItalic : fontContainer.font.italic

    onPdfWriterPtrChanged: if(pdfWriterPtr) loadedObjects++

    /*! This is the object that provides all the data and the style data for this class. This is an array of objects of type { header : [arr] , model : [arr] }
      \code
      //example
      model : { 0: { header : [ {row : 1, label : 'firstName', text : 'Wolf', align : 'left' },
                             {row : 1, label : 'lastName', text : 'Man',  align : 'right' } ]
                  model :  [ { hoursWorked : 10, onDay : 'wednesday' },
                             { hoursWorked : 10, onDay : 'thursday' }]
                },
                1 :{ header : [ {row : 1, label : 'firstName', text : 'Tuna', align : 'left' },
                             {row : 2, label : 'lastName', text : 'Warrior',  align : 'right' } ]
                  model :  [ { hoursWorked : 20, onDay : 'wednesday' },
                             { hoursWorked : 30, onDay : 'thursday' }]
                }
                styleInfo : {  'hoursWorked'  : { maxLen : 3},
                               'onDay'        : { maxLen : 20},
                               'spacing' : 6
                             }
              }
      \endcode
    */
    property var model        : null
    onModelChanged:
    {
        if(model)
        {
            loadedObjects++
            if(model.styleInfo)
                styleInfo = model.styleInfo
        }
    }

    property int loadedObjects : 0
    onLoadedObjectsChanged: if(loadedObjects >= 2)  status = Component.Ready


    property var styleInfo    : null
    property int spacing      : styleInfo && styleInfo.spacing ? styleInfo.spacing : 1
    onSpacingChanged:
    {
        spacingStr = ""
        for(var i = 0; i < spacing; i++)
            spacingStr += ' '
    }

    property string spacingStr : ""

    property var pdfFunc      : function pdfWriterFunc(arg1)
    {
        console.trace()
        rootObject.opacity = 0
        //console.log('pdfWriter func called', JSON.stringify(arg1,null,2))
        if(pdfWriterPtr && model)
        {
            if(!arg1)
                arg1 = {x : 0, y: 0, part : 'body', section : 0 }
            else
            {
                if(typeof arg1.x       === 'undefined') arg1.x       = 0
                if(typeof arg1.y       === 'undefined') arg1.y       = 0
                if(typeof arg1.part    === 'undefined') arg1.part    = "body"
                if(typeof arg1.section === 'undefined') arg1.section = 0
            }

            var longStr = ""
            for(var m in model)
            {
                var headerStr = ""
                var modelStr  = ""

                if(model[m].header)
                    headerStr = extractHeader(model[m].header) + "\n" + getLineOf('-')
                if(model[m].model)
                    modelStr  = extractModel(model[m].model)  + "\n" + getLineOf('-')

                longStr += headerStr + modelStr + "\n"
            }

            pdfWriterPtr.drawMultiLineText(longStr, arg1.x, arg1.y, rootObject.width, rootObject.height, 0,1, Qt.black, Qt.black, arg1.part,  arg1.section, rootObject.fontName, fontContainer.getFontStyle(), rootObject.fontSize)
        }
    }


    function getLineOf(character) { return new Array(Math.floor(rootObject.width / fontContainer.font.pixelSize)).join(character) + "\n"  }


    Text {
        id : fontContainer
        text : "ZPdfTable"

        font.italic: true
        font.bold: false
        font.family: 'Courier New'
        font.pointSize: 12

        visible : model ? false : true
        width : rootObject.width

        function getFontStyle()
        {
            if(font.italic && font.bold)                return 'bold italic'
            else if(font.italic && !font.bold)          return 'italic'
            else if(font.bold && !font.italic)          return 'bold'
            else                                        return 'normal'
        }
    }



    function extractHeader(headerArr) {
        var rowArr = getRowArr(headerArr)
        var headerStr = ""
        for(var i = 0; i < rowArr.length; i++)
        {
            if(rowArr[i])
            {
                headerStr += rowString(rowArr[i])
                if(i != rowArr.length -1)
                    headerStr += '\n'
            }
        }
        return headerStr;
    }

    function getRowArr(headerArr) {
        var rowArr = []
        for(var i = 0; i < headerArr.length; i++)
        {
            if(typeof rowArr[headerArr[i].row] === 'undefined')                rowArr[headerArr[i].row] =   [headerArr[i]]
            else                                                               rowArr[headerArr[i].row].push(headerArr[i])
        }
        return rowArr
    }

    function rowString(rowArr)  {
        rowArr.sort(function(a,b)
        {
            var alignA = a.align
            var alignB = b.align

            if(alignA === 'left')
            {
                return -1
            }
            else if(alignA === 'center')
            {
                if(alignB === 'left')
                    return 1
                else
                    return -1
            }
            else
            {
                if(alignB === 'right')
                    return -1
                else
                    return 1
            }

            return 0
        })

        var totalChars = getLineOf(' ').length
        var str = ""
        for(var i in rowArr) {
            if(rowArr[i].label.length !== 0)    str += rowArr[i].label.toUpperCase() + ":" + rowArr[i].text + "\t"
            else                                str += rowArr[i].text + "\t"
        }

        return str
    }

     function extractModel(modelArr) {
        var hStr = null
        var mStr = ""
        for(var m in modelArr)
        {
            var hStr2 = ""
            for(var k in modelArr[m])
            {
                if(!hStr)
                    hStr2 += stylize(styleInfo, k, k)         + spacingStr
                mStr += stylize(styleInfo, k, modelArr[m][k]) + spacingStr
            }

            if(!hStr)
                hStr = hStr2

            mStr += '\n'
         }
         return hStr + '\n' + mStr
     }
     function stylize(styleInfo, key, value) {
         if(styleInfo && styleInfo[key])
         {
            var style = styleInfo[key]
            var lenDifference = style.maxLen - value.length

            if(lenDifference > 0)      return value + (new Array(lenDifference).join(' '))
            else if(lenDifference < 0) return value.substring(0, value.length + lenDifference)
            else                       return value
         }
         return ""  //TEEHEE WE DONT RETURN ANYTHING THAT DOESNT HAVE STYLE INFO CAUSE WE DIVAS! BRO!
     }




}

//        headerArray.sort(function(a,b)
//        {
//           var numA = Number(a.row)    //if this thing isnt a number, try converting it to one
//           var numB = Number(b.row)    //if this thing isnt a number, try converting it to one
//           if(numA && numB)
//               return numA - numB
//           return 0
//        } )

