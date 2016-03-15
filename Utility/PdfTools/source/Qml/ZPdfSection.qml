import QtQuick 2.0
import Zabaat.UI.Wolf 1.0
import "Functions.js" as Functions
Item
{
    id : rootObject
    width: 100
    height: 62


    property  string sectionName: "untitled_section"
    property var pdfWriterPtr : null

    property real lMargin : 1
    onLMarginChanged: console.log(lMargin)
    property real rMargin : 1
    property real tMargin : 1
    property real bMargin : 1
    property real pgWidthInches  : 8.5
    property real pgHeightInches : 11

    property var header  : null
    property var footer  : null
    property var body    : null
    property var lefter  : null
    property var righter : null
    onHeaderChanged: if(header) header.parent = _header
    onBodyChanged:   if(body)   body.parent = _body
    onLefterChanged: if(lefter) lefter.parent = _lefter
    onRighterChanged : if(righter) righter.parent = _righter
    onFooterChanged : if(footer) footer.parent = _footer

    signal finishedImgArr(string sectionName)
    property int grabReadySegments : 0


    onGrabReadySegmentsChanged:
    {
        if(grabReadySegments >= 5)
        {
            finishedImgArr(sectionName)
        }
    }



    function getPage(name)
    {
        if(name == 'header')        return _header
        else if(name == 'body')     return _body
        else if(name == 'lefter')   return _lefter
        else if(name == 'righter')  return _righter
        else if(name == 'footer')   return _footer
        return                      _body
    }



    function grabAllImages()
    {
        if(pdfWriterPtr)
        {
            grabReadySegments = 0

            grabImages(0, 'header' )
            grabImages(0, 'footer' )
            grabImages(0, 'lefter' )
            grabImages(0, 'righter')
            grabImages(1, 'body'   )
        }
    }



    function grabImages(index, prop)
    {
        if(!index)
            index = 0

        var pg = getPage(prop)
        if(pg && pg.container.data[index] && pg.container.data[index].grabToImage)
        {
            var x = pg.container.data[index].x
            var y = pg.container.data[index].y
            var point = getRelativeXY(prop,x,y)

            if(prop == 'footer')
                console.log(x,y,'-->',point.x,point.y)

            pg.container.data[index].grabToImage(function (result)
            {
                if(result && result.image)
                    pdfWriterPtr.drawImage(point.x,point.y,result.image,prop, pdfWriterPtr.getSectionIndex(sectionName))
                else
                    console.log('null img')

                grabImages(index + 1, prop)
            })
        }
        else
            grabReadySegments++
    }



    function getRelativeXY(name,x,y)
    {
        var offX  = 0
        var offY  = 0

        if     (name == "body")     { offX += _lefter.width;                offY += _header.height                }
        else if(name == "lefter")   { offX += 0;                            offY += _header.height                }
        else if(name == "righter")  { offX += _lefter.width + _body.width;  offY += _header.height                }
        else if(name == "footer")   { offX += 0;                            offY += _header.height + _body.height }

        return {x : x + offX, y : y + offY}
    }

    function getChildAtXY(x,y)
    {
        for(var c in theCol.children)
        {
            var section = theCol.children[c]
            if(section !== theRow && ptIsWithinObj(x,y,section))
                return section
        }

        for(c in theRow.children)
        {
            section = theRow.children[c]
            if(ptIsWithinObj(x,y,section))
                return section
        }

        return null
    }

    function ptIsWithinObj(x,y,obj)
    {
        if(x >= obj.x && x <= obj.x + obj.width && y >= obj.y && y <= obj.y + obj.height)
            return true
        return false
    }

    function saveStr(tabStr)
    {
        if(!tabStr)
            tabStr = ""

        var str =  tabStr + "import QtQuick 2.0   \n"         +
                   tabStr +  "import Zabaat.UI.Wolf 1.0   \n" +
                   tabStr +  "PdfSection                  \n" +
                   tabStr + "{                            \n"

        str += tabStr + '\tid :'     + sectionName  + "\n"
        str += tabStr + '\tsectionName :'     + Functions.spch(sectionName)  + "\n"
        str += tabStr + '\twidth :'  + width  + "\n"
        str += tabStr + '\theight:'  + height + "\n"
        str += tabStr + '\tpgWidthInches:'   + pgWidthInches + "\n"
        str += tabStr + '\tpgHeightInches:'  + pgHeightInches + "\n"
        str += tabStr + '\tlMargin:'  + lMargin + "\n"
        str += tabStr + '\trMargin:'  + rMargin + "\n"
        str += tabStr + '\ttMargin:'  + tMargin + "\n"
        str += tabStr + '\tbMargin:'  + bMargin + "\n"



        var headerStr = _header.childrenSaveStr(tabStr + "\t")
        if(headerStr == "")            headerStr = "null\n"
        else                           headerStr = 'Item\n' + tabStr + "\t{\n" + headerStr + tabStr + "\t}\n"

        var bodyStr = _body.childrenSaveStr(tabStr + "\t")
        if(bodyStr == "")               bodyStr = "null\n"
        else                            bodyStr = 'Item\n' + tabStr + "\t{\n" + bodyStr + tabStr + "\t}\n"

        var lefterStr = _lefter.childrenSaveStr(tabStr + "\t")
        if(lefterStr == "")             lefterStr = "null\n"
        else                            lefterStr = 'Item\n' + tabStr + "\t{\n" + lefterStr + tabStr + "\t}\n"

        var righterStr = _righter.childrenSaveStr(tabStr + "\t")
        if(righterStr == "")            righterStr = "null\n"
        else                            righterStr = 'Item\n' + tabStr + "\t{\n" + righterStr + tabStr + "\t}\n"

        var footerStr = _footer.childrenSaveStr(tabStr + "\t")
        if(footerStr == "")            footerStr = "null\n"
        else                           footerStr = 'Item\n' + tabStr + "\t{\n" + footerStr + tabStr + "\t}\n"

        str += tabStr + '\theader:'  + headerStr
        str += tabStr + '\tbody:'    + bodyStr
        str += tabStr + '\tlefter:'  + lefterStr
        str += tabStr + '\trighter:' + righterStr
        str += tabStr + '\tfooter:'  + footerStr

        str += tabStr + "}\n"
        return str;
    }


    function setEditMode(value)
    {
        _header.setEditMode(value)
        _body.setEditMode(value)
        _lefter.setEditMode(value)
        _righter.setEditMode(value)
        _footer.setEditMode(value)
    }




    Column
    {
        id : theCol
        width  : parent.width
        height : parent.height

        ZPage
        {
            id : _header
            readonly property string name : "header"
            showScrollBars: false
            width  : rootObject.width
            height : (tMargin / pgHeightInches) * rootObject.height
        }

        Row
        {
            id    : theRow
            width  : rootObject.width
            height : rootObject.height - _header.height - _footer.height

            ZPage
            {
                id : _lefter
                readonly property string name : "lefter"
                showScrollBars: false
                width  : (lMargin / pgWidthInches) * rootObject.height
                height : rootObject.height - _header.height - _footer.height
            }


            ZPage
            {
                id : _body
                readonly property string name : "body"
                width :  rootObject.width   - _lefter.width  - _righter.width
                height : rootObject.height  - _header.height - _footer.height
                scrollBarBtnSize : 16
                scrollBarThickness : 8

                vScrollBarOffset : _righter.width
                hScrollBarOffset : _footer.height

                Item
                {
                    id : _bodyCmp
                    anchors.fill: parent
                }
            }

            ZPage
            {
                id : _righter
                readonly property string name : "righter"
                showScrollBars: false
                width  : (rMargin / pgWidthInches) * rootObject.height
                height : rootObject.height - _header.height - _footer.height
            }
        }

        ZPage
        {
            id : _footer
            readonly property string name : "footer"
            showScrollBars: false
            width  : rootObject.width
            height : (bMargin / pgHeightInches) * rootObject.height
        }

    }

}

