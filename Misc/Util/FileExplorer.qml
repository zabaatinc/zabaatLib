import QtQuick 2.0
import Zabaat.UI.Wolf 1.0
import Qt.labs.folderlistmodel 2.1


Column{
    id : headerCol

    property alias directory          : flm.folder
    property alias folderListModelPtr : flm
    property alias extensions         : flm.nameFilters
    property string message           : "Choose File"

    property int delegateWidth  : delegateSize.x
    property int delegateHeight : delegateSize.y
    property int headerWidth    : headerSize.x
    property int headerHeight   : headerSize.y

    signal         selected(string folderName, string fileName, string path)
    property alias count : flm.count

    function getAllFileNames(){
        var retArr = []
        for(var i = 0; i < flm.count; i++){
            var file = flm.get(i,'fileName')
            if(file && !flm.get(i,'fileIsDir')){
                retArr.push(file)
            }
        }
        return retArr
    }

    function getAllFolderNames(){
        var retArr = []
        for(var i = 0; i < flm.count; i++){
            var fldr = flm.get(i,'fileName')
            if(fldr && flm.get(i,'fileIsDir')){
                retArr.push(fldr)
            }
        }
        return retArr
    }



    QtObject{
        id : delegateSize
        property int x : rootObject.width
        property int y : 40
    }
    QtObject{
        id : headerSize
        property int x : rootObject.width
        property int y : 40
    }

    ZText{
        width  : headerSize.x
        height : headerSize.y * 1/2
        text   : message
        color  : "black"
        fontColor: "white"
    }

    Row{
        width : headerSize.x
        height : headerSize.y * 1/2

        ZButton{
            width  : parent.width * 1/5
            height : parent.height
            showIcon : true
            text : ""
            fontAwesomeIcon: "\uf148"
            onBtnClicked : flm.folder = flm.parentFolder
        }

        ZText{
            width  : parent.width * 3/5
            height : parent.height
            text   : flm.folder.toString().replace("file:///","")
        }

        ZButton{
            property var del : delegateInstanceAt(rootObject.currentIndex)
            width : parent.width * 1/5
            height : parent.height
            text : "OK"
            onBtnClicked: del ? selected(flm.folder, del.myText, del.filePath) : selected(flm.folder, "", "")
        }
    }


    function delegateInstanceAt(index){
        var firstFileChild = null
        for(var i = 0; i < rootObject.contentItem.children.length; i++){
            var child = rootObject.contentItem.children[i]
            if(child.imADelegate && index == child._index && !child.fileIsDir)             return child
            else if(!child.fileIsDir)                                                      firstFileChild = rootObject.contentItem.children[i]
        }
        if(firstFileChild)
            return firstFileChild
        return null
    }


    ListView{
        id     : rootObject
        width  : parent.width
        height : parent.height - headerSize.y

        model : FolderListModel{
            id : flm
            showDirs     : true
            showDirsFirst: true
            nameFilters  : ["*"]
        }


        delegate: ZButton{
            property bool imADelegate : true
            property int _index : index

            width : delegateSize.x
            height : delegateSize.y
            property var myText: flm.get(index,"fileName")

            showIcon: true
            fontAwesomeIcon: fileIsDir ? "\uf07b" : "\uf15b"
            text           : myText ? myText : ""
            onBtnClicked: {
                if(fileIsDir)   flm.folder = fileURL
                else            selected(flm.folder.toString(),myText, fileURL)
            }
        }



    }


}




