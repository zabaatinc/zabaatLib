import QtQuick 2.0
import QtQuick.Controls 1.2
import Zabaat.UI.Wolf 1.0
import "Functions.js" as Functions


TabView
{
    id : tv
    width  : 500
    height : 500

    property real lMargin : 1
    property real rMargin : 1
    property real tMargin : 1
    property real bMargin : 1
    property real pgWidthInches  : 8.5
    property real pgHeightInches : 11
    property alias rowHeight : btnRow.height
    property var pdfWriterPtr : null


    property alias index    : tv.currentIndex
    readonly property alias tabCount: tv.count
    onIndexChanged: if(pdfWriterPtr) pdfWriterPtr.currentSection = index


    function getCurTab() { var t = getTabItem(index); console.log(index,t); return t }

    function setEditMode(value)
    {
        for(var i = 0; i < tv.count ; i++)
        {
            if(getTabItem(i))
                getTabItem(i).setEditMode(value)
        }
    }

    function getTabItem(index)
    {
        if(index > -1 && index < tv.count)
            return getTab(index).item
        return null
    }

    function getTabTitle(index)
    {
        if(index > -1 && index < tv.count)
            return tv.contentItem.children[index].title
        else
            return 'undefined'
    }

    function setTabTitle(index, title)
    {
        if(index > -1 && index < tv.count)
            return tv.contentItem.children[index].title = title
    }


    function grabImages(directory)
    {
        if(pdfWriterPtr)
        {
            if(directory)
                privates.directory = directory
            setEditMode(false)
            privates.imgReadySections = privates.imgReadyThreshold = 0

            for(var i = 0; i < tv.count ; i++)
            {
                if(getTabItem(i))
                {
                    getTabItem(i).pdfWriterPtr = tv.pdfWriterPtr
                    getTabItem(i).finishedImgArr.disconnect(privates.tabFinishImgArr)    //we disconnect first so we dont create mutliple connections to the same slot!
                    privates.imgReadyThreshold++
                    getTabItem(i).finishedImgArr.connect(privates.tabFinishImgArr)

                }
            }

            for(i = 0; i < tv.count ; i++)
            {
                if(getTabItem(i))
                    getTabItem(i).grabAllImages()
            }
        }
    }

    function addPdfTab(name, dontAddToPdfWriter)
    {
        var cmp = Qt.createComponent("ZPdfSection.qml")
        var t = tv.addTab(name, cmp)
        t.active = true //force this #*&#$*#$ to load!!! TOO LAZY!!

        var p = t.item
        p.width       = Qt.binding(function()      { return tv.width  } )
        p.height      = Qt.binding(function()      { return tv.height } )
        p.sectionName = Qt.binding(function()      { return t.title }   )

        p.lMargin = Qt.binding(function()      { return tv.lMargin })
        p.rMargin = Qt.binding(function()      { return tv.rMargin })
        p.tMargin = Qt.binding(function()      { return tv.tMargin })
        p.bMargin = Qt.binding(function()      { return tv.bMargin })

        p.pgWidthInches = Qt.binding(function()      { return tv.pgWidthInches })
        p.pgHeightInches= Qt.binding(function()      { return tv.pgHeightInches })

        if(!dontAddToPdfWriter)
            pdfWriterPtr.addSection(name)
    }




    Item
    {
        id : privates
        property int imgReadySections  : 0
        property int imgReadyThreshold : 0
        property bool innateProperty : true
        property string directory : ""

        function tabFinishImgArr(name)
        {
            imgReadySections++

            if(imgReadySections > 0 && imgReadyThreshold > 0 &&  imgReadySections >= imgReadyThreshold)
            {
                setEditMode(true)
                pdfWriterPtr.finalize(directory)
            }
        }
    }

    Row
    {
        id : btnRow
        y : -height - 20
        property bool innateProperty : true

        Text        {            text : index        }

        ZButton
        {
            id : addSectionBtn
            width : 64
            btnText : "+"
            onBtnClicked :
            {
                if(sectionNameBox.text != "")
                    addPdfTab(sectionNameBox.text)
                else
                {
                    var num  = tv.count + 1
                    addPdfTab("untitled_section_" + num)
                }
            }
        }

        ZButton
        {
            id : changeSectionBtn
            width : 64
            btnText : "Chg"
            onBtnClicked :
            {
                if(sectionNameBox.text != "")
                     setTabTitle(index, sectionNameBox.text)
            }
        }

        ZButton
        {
            id : delSectionBtn
            width : 64
            btnText : "Del"
            onBtnClicked :
            {
                if(tv.count > 1 && pdfWriterPtr)
                {
                    pdfWriterPtr.deleteSection(getTabTitle(index))
                    tv.removeTab(index)

                    for(var i = 0; i < tv.count; i++)
                    {
                        if(getTabItem(i))
                            console.log(i, getTabTitle(i))
                    }

                    index = pdfWriterPtr.currentSection
                }
            }
        }

        ZTextBox
        {
            id : sectionNameBox
        }

    }






    function saveStr(tabStr)
    {
        if(!tabStr)
            tabStr = ""

        var str = tabStr + "import QtQuick 2.0   \n" +
                  tabStr + "import QtQuick.Controls 1.2 \n" +
                  tabStr + "import Zabaat.UI.Wolf 1.0 \n" +
                  tabStr + "import Zabaat.PdfTools 1.0 \n" +
                  tabStr + "ZPdfBook\n{\n"

        str += tabStr + '\tid : rootObject'    + "\n"
        str += tabStr + '\tproperty var dataSection'  + "\n"
        str += tabStr + '\twidth :'          + tv.width  + "\n"
        str += tabStr + '\theight:'          + tv.height + "\n"
        str += tabStr + '\tpgWidthInches:'   + tv.pgWidthInches + "\n"
        str += tabStr + '\tpgHeightInches:'  + tv.pgHeightInches + "\n"
        str += tabStr + '\tlMargin:'         + tv.lMargin + "\n"
        str += tabStr + '\trMargin:'         + tv.rMargin + "\n"
        str += tabStr + '\ttMargin:'         + tv.tMargin + "\n"
        str += tabStr + '\tbMargin:'         + tv.bMargin + "\n"


        for(var i = 0; i < tv.count ; i++)
        {
            var child = getTabItem(i)
            if(child && child.saveStr)
            {
                str += tabStr + "\t" + "Tab\n" + tabStr +  "\t{\n"
                str += tabStr + "\t\t" + "title : " + Functions.spch(getTab(i).title) + "\n"

                var childstr =  Functions.removeImports(child.saveStr(tabStr + "\t\t"))
                childstr = Functions.replaceLine(childstr, 'width', tabStr + "\t\t\twidth:rootObject.width"  , 1)
                childstr = Functions.replaceLine(childstr, 'height', tabStr + "\t\t\theight:rootObject.height" , 1)
                childstr = Functions.replaceLine(childstr, 'pgWidthInches', tabStr + "\t\t\tpgWidthInches:rootObject.pgWidthInches" , 1)
                childstr = Functions.replaceLine(childstr, 'pgHeightInches', tabStr + "\t\t\tpgHeightInches:rootObject.pgHeightInches" ,1)
                childstr = Functions.replaceLine(childstr, 'lMargin', tabStr + "\t\t\tlMargin:rootObject.lMargin" ,1)
                childstr = Functions.replaceLine(childstr, 'rMargin', tabStr + "\t\t\trMargin:rootObject.rMargin" ,1)
                childstr = Functions.replaceLine(childstr, 'tMargin', tabStr + "\t\t\ttMargin:rootObject.tMargin" ,1)
                childstr = Functions.replaceLine(childstr, 'bMargin', tabStr + "\t\t\tbMargin:rootObject.bMargin" ,1)
                childstr = Functions.replaceLine(childstr, 'sectionName', tabStr + "\t\t\tsectionName:parent.title" ,1)
                //childstr = Functions.replaceLine(childstr, 'dataSection', tabStr + "\t\t\tsectionName:parent.title" ,1)
//                childstr = childstr.substr(0,childstr.length - 2) + tabStr + "\t\t\t sectionName:parent.title\n" + tabStr + "\t\t}"
                childstr = childstr.split('dataSection').join('rootObject.dataSection')

                str += childstr
                str += tabStr + "\t" + "}\n"
            }
        }



        str += "}\n"

       return str;
    }







}

