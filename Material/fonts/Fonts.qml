//Loads all the fonts in dir. By default, it will load fontAwesome. Happy times :D
import QtQuick 2.4
import Qt.labs.folderlistmodel 2.1
//import "../"

pragma Singleton
QtObject {
    id : rootObject

    property alias dir               : fontList.folder
    readonly property alias numFonts : fontContainer.totalFonts
    property bool     loaded         : false

    property string font1 : ""
    property string font2 : ""
    readonly property string fa   : "FontAwesome"   //these fonts come included :)
    readonly property string rosa : 'rosacons'      //these fonts come included :D

    onLoadedChanged      : if(loaded) console.log("Fonts loaded:", getCustomFonts())
    Component.onCompleted: logic.log("Singleton Fonts is born")

    function getCustomFonts(){
        var arr = []
        for(var i = 0; i < fontContainer.fonts.length; i++)
            arr.push(fontContainer.fonts[i].name)
        return arr
    }
    function getAllAvailableFonts(){
        return Qt.fontFamilies()
    }

    property Item __private : Item {
        id : logic
        property bool debug : false
        function log(){
            if(debug){
                console.log.apply(this,arguments)
            }
        }

        FolderListModel {
            id : fontList
            folder          : "emptyFolder"
            showDirs        : false
            showDotAndDotDot: false
            onFolderChanged : if(!loadTimer.running){ loadTimer.start() }
            onCountChanged  : if(!loadTimer.running){ loadTimer.start() }
            nameFilters     : ["*.ttf", "*.otf", "*.fnt" ]


            property Timer myTimer : Timer {
                //the delay is helpful so when the count property is increased (as it will, one by one)
                //we dont duplicate calls to loadFonts()!
                id : loadTimer
                running : true
                repeat : false
                interval : 100
                onTriggered : {
                      logic.loadFonts()
//                    var thisDir = Qt.resolvedUrl("./")
//                    var lastChar = thisDir[thisDir.length - 1]
//                    if(lastChar === "/" || lastChar === "\\")
//                        thisDir = thisDir.slice(0,-1)

//                    if(fontList.folder.toString() === thisDir) {
//                        logic.loadFonts()
//                    }
                }
            }

        }
        Item {
            id : fontContainer
            property var fonts       : [fontAwesome, rosacons]
            property int totalFonts  : 2
            property int fontsLoaded : -1
            onFontsLoadedChanged: {
                if(fontsLoaded !== -1 && fontsLoaded === totalFonts)
                    rootObject.loaded = true
            }

            FontLoader {
                id     : fontAwesome
                source : "FontAwesome.otf"
            }

            FontLoader {
                id : rosacons
                source : "rosacons.ttf"
            }



            function clear() {
                //dont clear, i think this destroys some things really hard! just dont import FA
                //to your projects?
//                fonts = []
//                for(var i = 0; i < children.length; i++) {
//                    children[i].parent = null
//                    children[i].destroy()
//                }
//                children = []
            }
        }


        function loadFonts() {
            console.log("Load fonts called")
            rootObject.loaded = false
            fontContainer.clear()
            fontContainer.totalFonts = fontList.count //+1 is for font awesome
            fontContainer.fontsLoaded = 0


            for(var i = 0; i < fontList.count; ++i) {
                var fl        = getQmlObject(["QtQuick 2.4"], "FontLoader{}", fontContainer)
                fl.statusChanged.connect(function() { if(fl.status === FontLoader.Ready) fontContainer.fontsLoaded++})
                fontContainer.fonts.push(fl)

                var filePath = fontList.get(i, 'filePath')
                if(filePath.toString().indexOf(":") !== 0) {
                    fl.source = "file:///" + filePath
                }
                else{
                    fl.source = filePath.toString().slice(1)
                }
            }
        }
        function getQmlObject(imports,qmlStr,parent) {
            var str = ""
            if(typeof imports !== 'string') {
                for(var i in imports)
                    str += "import " + imports[i] + ";\n"
            }
            else
                str = "import " + imports + ";"

            var obj = Qt.createQmlObject(str + qmlStr,parent,null)
            return obj
        }


    }
}


