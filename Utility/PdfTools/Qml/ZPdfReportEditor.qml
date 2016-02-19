import QtQuick 2.0
import QtQuick.Controls 1.0
//import Pdf 1.0
import Zabaat.PdfTools 1.0
import Zabaat.UI.Wolf 1.0
import "Functions.js" as Functions
import Zabaat.WolfSys 1.0

Rectangle
{
    id    : rootObject
    width : 1600
    height: 800
    visible : true
    color : "gray"

    property bool editMode   : true
    property var dataSection : ({ pdf : pdfProperties } )

    property var pdfProperties : ({       pgWidthPx      :   pdfWriter.pageWidthInches * pdfWriter.dpi ,
                                          pgHeightPx     :   pdfWriter.pageWidthInches * pdfWriter.dpi ,
                                          pgWidthIn      :   pdfWriter.pageWidthInches ,
                                          pgHeightIn     :   pdfWriter.pageHeightInches ,
                                          dpi            :   pdfWriter.dpi ,
                                          topMarginIn    :   pdfWriter.t_Margin ,
                                          topMarginPx    :   pdfWriter.t_Margin * pdfWriter.dpi ,
                                          botMarginIn    :   pdfWriter.b_Margin ,
                                          botMarginPx    :   pdfWriter.b_Margin * pdfWriter.dpi ,
                                          leftMarginIn   :   pdfWriter.l_Margin ,
                                          leftMarginPx   :   pdfWriter.l_Margin * pdfWriter.dpi ,
                                          rightMarginIn  :   pdfWriter.r_Margin ,
                                          rightMarginPx  :    pdfWriter.r_Margin * pdfWriter.dpi ,
                                          bodyWidthPx    :   ((pdfWriter.pageWidthInches - pdfWriter.l_Margin - pdfWriter.r_Margin)/pdfWriter.pageWidthInches) * pdfWriter.width,
                                          bodyHeightPx   :   ((pdfWriter.pageHeightInches - pdfWriter.t_Margin - pdfWriter.b_Margin)/pdfWriter.pageHeightInches) * pdfWriter.height
                                   })

    //we make sure we always keep our pdfProperties!
    onDataSectionChanged:
    {
        if(dataSection != null && typeof dataSection !== 'undefined')
        {
            if(typeof dataSection.pdf === 'undefined')
                dataSection.pdf = pdfProperties

            cmpPicker.dataSection = dataSection
            status = Component.Ready
        }
    }


    property int status    : Component.Loading
    property string pdfSource : "ZPdfBook.qml"

    Component.onCompleted: if(pdfSource == "ZPdfBook.qml")  status = Component.Ready


    function savePdf(dir, derp)
    {
        loader.item.grabImages(dir)
    }

    function saveQMLPdfBluePrint(name, derp)
    {
        sys.writeFile(name, loader.item.saveStr())
    }

    function setDataSection(obj)
    {
        for(var o in obj)
            rootObject.dataSection[o] = obj[o]

        cmpPicker.dataSection = dataSection
        status = Component.Ready
    }


    WolfSys  {  id : sys    }

    Row
    {
        id : theRow
        width : parent.width
        height : parent.height

        spacing : 48


        ZCmpMenu
        {
            id : cmpPicker
            container: pdfWriter
            height : rootObject.height
            width : parent.width/7
            dataSection: rootObject.dataSection
            objectCreationCallBack: function(name,x,y) { pdfWriter.determineParent(name,x,y) }

            z : 100
        }

        Column
        {
            id : col
            spacing : 20


            Row
            {
                id : ops
                ZButton
                {
                    btnText : "Save Pdf"
                    onBtnClicked : if(loader.item) createSaveDialog()
                    width : 128

                    function createSaveDialog()
                    {
                        var msgBox = Functions.getQmlObject(["QtQuick 2.0", "Zabaat.UI.Wolf 1.0"], "ZMsgBox{}", tmpContainer)
                        msgBox.message = "Enter name of Pdf"
                        msgBox.okClicked.connect(savePdf)
                    }
                }

                ZButton
                {
                    btnText : "Save BluePrint"
                    onBtnClicked : if(loader.item) createSaveDialog()
                    width : 128
                    visible: editMode

                    function createSaveDialog()
                    {
                        var msgBox = Functions.getQmlObject(["QtQuick 2.0","Zabaat.UI.Wolf 1.0"], "ZMsgBox{}", tmpContainer)
                        msgBox.message = "Enter name of QML BluePrint file"
                        msgBox.okClicked.connect(saveQMLPdfBluePrint)
                    }
                }


                Textbox
                {
                    caption : "left margin (in.)"
                    text : "1"
                    onTextersChanged: if(pdfWriter && Number(text)) pdfWriter.l_Margin = Number(text)
                    visible: editMode

                }

                Textbox
                {
                    caption : "top margin (in.)"
                    text : "1"
                    onTextersChanged: if(pdfWriter && Number(text)) pdfWriter.t_Margin = Number(text)
                    visible: editMode
                }

                Textbox
                {
                    caption : "right margin (in.)"
                    text : "1"
                    onTextersChanged: if(pdfWriter && Number(text)) pdfWriter.r_Margin = Number(text)
                    visible: editMode
                }

                Textbox
                {
                    caption : "bottom margin (in.)"
                    text : "1"
                    onTextersChanged: if(pdfWriter && Number(text)) pdfWriter.b_Margin = Number(text)
                    visible: editMode
                }

                Textbox
                {
                    caption : "Pg Size"
                    text : "AnsiA"
                    onTextersChanged: if(pdfWriter) pdfWriter.pageSize = text
                    visible: editMode
                }

                Textbox
                {
                    caption : "Pg Orientation"
                    text : "Portrait"
                    onTextersChanged: if(pdfWriter) pdfWriter.pgOrientation = text
                    visible: editMode
                }

                Textbox
                {
                    caption : "DPI"
                    text : "300"
                    onTextersChanged: if(pdfWriter && Number(text)) pdfWriter.dpi = Number(text)
                }
            }

            PdfWriter
            {
                id              : pdfWriter
                maxCanvasWidth  : theRow.width - 20
                maxCanvasHeight : theRow.height - 20 - ops.height - (theRow.spacing * 2)



                function updatePdfInfoInDataSection()
                {
                    dataSection.pdf =     {  pgWidthPx      :   pdfWriter.pageWidthInches * pdfWriter.dpi ,
											 pgHeightPx     :   pdfWriter.pageWidthInches * pdfWriter.dpi ,
											 pgWidthIn      :   pdfWriter.pageWidthInches ,
											 pgHeightIn     :   pdfWriter.pageHeightInches ,
											 dpi            :   pdfWriter.dpi ,
											 topMarginIn    :   pdfWriter.t_Margin ,
											 topMarginPx    :   pdfWriter.t_Margin * pdfWriter.dpi ,
											 botMarginIn    :   pdfWriter.b_Margin ,
											 botMarginPx    :   pdfWriter.b_Margin * pdfWriter.dpi ,
											 leftMarginIn   :   pdfWriter.l_Margin ,
											 leftMarginPx   :   pdfWriter.l_Margin * pdfWriter.dpi ,
											 rightMarginIn  :   pdfWriter.r_Margin ,
											 rightMarginPx  :    pdfWriter.r_Margin * pdfWriter.dpi ,
											 bodyWidthPx    :   ((pdfWriter.pageWidthInches - pdfWriter.l_Margin - pdfWriter.r_Margin)/pdfWriter.pageWidthInches) * pdfWriter.width,
											 bodyHeightPx   :   ((pdfWriter.pageHeightInches - pdfWriter.t_Margin - pdfWriter.b_Margin)/pdfWriter.pageHeightInches) * pdfWriter.height
                                          }

                    return dataSection.pdf
                }


                function determineParent(name,x,y)
                {
                    var par = loader.item.getCurTab().getChildAtXY(x, y)
                    if(par)
                    {
                        if(name.indexOf(".qml") != -1)
                            name = name.substr(0,name.length-4)

                        var newObj = Functions.getQmlObject(["QtQuick 2.0", "Zabaat.UI.Wolf 1.0","'Functions.js' as Functions"] , name + "{}", par)
                        newObj.dataSection = rootObject.dataSection
                        newObj.editOptions = cmpPicker.editOptions
                    }
                }



                onMarginsChanged:
                {
                    updatePdfInfoInDataSection()
                    if(loader.item)
                    {
                        loader.item.lMargin = pdfWriter.l_Margin
                        loader.item.rMargin = pdfWriter.r_Margin
                        loader.item.tMargin = pdfWriter.t_Margin
                        loader.item.bMargin = pdfWriter.b_Margin
                    }
                }

                onMaxCanvasWidthChanged : updatePdfInfoInDataSection()
                onMaxCanvasHeightChanged: updatePdfInfoInDataSection()



                Loader
                {
                    id      : loader
                    width   : pdfWriter.width
                    height  : pdfWriter.height
                    source  : rootObject.status == Component.Ready ? Qt.resolvedUrl(pdfSource) : ""

                    onSourceChanged      :  handleNewSource()
//                    Component.onCompleted:  handleNewSource()

                    function handleNewSource()
                    {
                        item.y      = Qt.binding(function() { return item.rowHeight  } )
                        item.width  = Qt.binding(function() { return width  } )
                        item.height = Qt.binding(function() { return height } )

                        if(item.hasOwnProperty('setDataSection'))
                        {
                            console.log('derp')
                            item.setDataSection(rootObject.dataSection)
                        }


                        if(item.tabCount == 0)       //this is an empty thinger
                            item.addPdfTab("untitled_section",true)
                        else                        //non empty , so we need to clear our pdfWriter's sections! and readjust the writer!
                        {
                            pdfWriter.reset()
                            pdfWriter.l_Margin = item.lMargin
                            pdfWriter.r_Margin = item.rMargin
                            pdfWriter.t_Margin = item.tMargin
                            pdfWriter.b_Margin = item.bMargin
                            pdfWriter.pageSize = item.pgWidthInches + "," +  item.pgHeightInches

                            for(var i = 0; i < item.tabCount; i++)
                            {
                                item.setEditMode(true, cmpPicker.editOptions)
                                pdfWriter.addSection( item.getTab(i).title)
                            }
                        }

                        item.pdfWriterPtr = pdfWriter
                    }
                }
            }










        }




    }






    Item
    {
        id : tmpContainer
    }

}

