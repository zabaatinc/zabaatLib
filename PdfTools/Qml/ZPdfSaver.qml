import QtQuick 2.0
import Zabaat.PdfTools 1.0
import Zabaat.WolfSys  1.0

Item
{
    width: 400
    height: 600

    property url bluePrintDir     : "/Reports"
    property url saveDir          : "../../../Reports"
    opacity : 0

    function save(bluePrintName, reportName, data, bpDir, outDir) {
        reportLoader.openAfterSave = false
        reportLoader._init(bluePrintName, reportName, data, bpDir, outDir)
    }
    function saveAndOpen(bluePrintName, reportName, data, bpDir, outDir) {
        reportLoader.openAfterSave = true
        reportLoader._init(bluePrintName, reportName, data, bpDir, outDir)
    }

    Loader {
        id : reportLoader
        source : ""

        property var    dataSection    : null
        property url    saveLocation   : ""
        property bool   openAfterSave  : true
        property bool   saving          : false


        onStatusChanged: if(status === Component.Ready && item && source !== "" && saveLocation !== "" ) {
                             item.pdfWriterPtr = pdfWriter
                             item.statusChanged.connect(_writePdf)

                             if(openAfterSave)
                                 item.saved.connect(_open)

                             item.setDataSection(dataSection)
                         }



        function _init(bluePrintName, reportName, data, bpDir, outDir) {
            source = ""     //make this blank!

            if(!bpDir)
                bpDir = bluePrintDir

            if(!outDir)
                outDir = saveDir

            var qrcIndex = outDir.toString().indexOf('qrc:///') !== -1
            if(qrcIndex)
                outDir = outDir.toString().slice(6)


            dataSection    = data
            saveLocation   = outDir + "/" + reportName
            saving          = false
            source         = bpDir + "/" +  bluePrintName
        }
        function _writePdf() {
            if(!saving){
                saving = true

                //load this pdf's properties and tabs into our pdfWriter.dll
                if(item.status === Component.Ready && pdfWriter._init(item.dataSection.pdf ))
                    item.grabImages(Qt.resolvedUrl(saveLocation))
            }
        }
        function _open(fileName) {
            Qt.openUrlExternally(fileName)
        }


    }


    PdfWriter {
        id : pdfWriter
        width : 1000
        height : 1000

        pageNumberOnFooter : 1
//        onPageNumberOnFooterChanged : console.log("pageNumber on footer changed", pageNumberOnFooter)

//        Timer {
//            interval : 2000
//            running : true
//            repeat : true
//            onTriggered: console.log("pageNumber on footer changed", pdfWriter.pageNumberOnFooter)
//        }

        function _init(item)
        {
            var success = false
            width = reportLoader.item.width
            height = reportLoader.item.height

            try {
                pdfWriter.reset()
                pdfWriter.l_Margin = item.leftMarginIn
                pdfWriter.r_Margin = item.rightMarginIn
                pdfWriter.t_Margin = item.topMarginIn
                pdfWriter.b_Margin = item.botMarginIn
                pdfWriter.pageSize = item.pgWidthIn + "," +  item.pgHeightIn
                pdfWriter.dpi      = item.dpi

                var i = 0
                while(pdfWriter.numSections < reportLoader.item.tabCount) {
                    ++i
                    pdfWriter.addSection('newSection' + i)
                }

                for(i = 0; i < reportLoader.item.tabCount; i++)
                    pdfWriter.changeSectionName(reportLoader.item.getTab(i).title, i)


                for(i = 0; i < reportLoader.item.tabCount; i++)
                {
                    //  item.setEditMode(true, cmpPicker.editOptions)
//                    console.log(pdfWriter.getSectionName(i))
                    //pdfWriter.changeSectionName(oldSectionName, reportLoader.item.getTab(i).title)
                }

                success = true
            }
            catch(e) {
                success = false
            }

            return success
        }

    }


}

