import QtQuick 2.4
import Qt.labs.folderlistmodel 2.1

pragma Singleton
QtObject {
    id : rootObject

    property alias  dir               : flm.folder
//    onDirChanged : console.log("Colors.dir",dir)

    property bool loaded              : false
    property string defaultColorTheme : "default"

    //rebind all the colors on these events
    onDefaultColorThemeChanged: if(loaded)
                                    logic.rebind()
    onLoadedChanged           : if(loaded)
                                    logic.rebind()

    //PUBLIC FUNCTIONS
    //If you give it only one arg (colorName) , it will return you that color of the defaultColorTheme
    //if you give it only one arg with a ".", it will return you a color from that theme. e.g., default.accent

    function get(theme, colorName){    //UNIVERSAL COLOR ACCESSOR IN A SINGLETON. HAPPY TIMES!
//        console.log("CALLING get func", theme, colorName)
        if(arguments.length === 1){     //if we only got 1 arg (i.e, no colorName)
            if(theme.indexOf(".") === -1){
                if(logic.isColorName(theme)){
                    colorName = theme
                    theme = defaultColorTheme
                }
                else {
                    colorName = "standard"
                }
            }
            else {
                theme     = theme.split(".")
                colorName = theme[1]
                theme     = theme[0]
            }
        }


        var    obj = logic.map[theme] ? logic.map[theme] : stockColors
        return obj[colorName] ? obj[colorName] : "black"
    }
    function getAllColorPalletes(){
        var arr = []
        if(logic.map){
            for(var m in logic.map)
                arr.push(m)
        }
        return arr
    }
    function getRandomColor(){
        return Qt.rgba(Math.random(),Math.random(),Math.random(), 1)
    }

    //borrowed from https://github.com/papyros/qml-material/blob/develop/modules/Material/Theme.qml
    function isDarkColor(color) {
        var a = (0.299 * color.r + 0.587 * color.g + 0.114 * color.b);
        return a < 0.49;
    }
    function isLightColor(color){
        return !isDarkColor(color)
    }
    function getContrastingColor(color, val){
        if(val === null || typeof val === 'undefined')
            val = 2
        return isDarkColor(color) ? Qt.lighter(color, val) : Qt.darker(color, val)
    }
    function mix(color1,color2,val) {
        if(val < 0)   val = 0;
        if(val > 1)   val = 1;

        var dVal = 1 - val;

        var r = (color2.r * val) + (color1.r  * dVal)
        var g = (color2.g * val) + (color1.g  * dVal)
        var b = (color2.b * val) + (color1.b  * dVal)
        return  Qt.rgba(r,g,b)
    }
    function colorhashFunc(name){
        function hashFunc(str){
            var hash = 0, i, chr, len;
              if (str.length === 0)
                  return hash;
              for (i = 0; i < str.length; i++) {
                chr   = str.charCodeAt(i);
                hash  = ((hash << 5) - hash) + chr;
//                    hash |= 0; // Convert to 32bit integer
              }
              return hash;
        }
        var h = Math.abs(hashFunc(name)).toString()
        if(h.length > 9){
            h = h.slice(0,-1)
        }
        else while(h.length < 9){
            h += "0"
        }

        //now subdivide the string in 3 sections
        var r = (+h.substr(0,3))/1000
        var g = (+h.substr(3,3))/1000
        var b = (+h.substr(6,3))/1000
        return Qt.rgba(r,g,b,1)
    }
    function contrastingTextColor(color) {
        if(isDarkColor(color)){
            return isDarkColor(text1) ? text2 : text1
        }
        else {
            return isDarkColor(text1) ? text1 : text2
        }
    }
    function contrastingTextState(color) {
        if(isDarkColor(color)){
            return isDarkColor(text1) ? "t2" : "t1"
        }
        else {
            return isDarkColor(text1) ? 't1' : 't2'
        }
    }

    function rgbToHex255(r,g,b,a){
        //http://stackoverflow.com/questions/5623838/rgb-to-hex-and-hex-to-rgb
        function componentToHex(c) {
            var hex = c.toString(16);
            return hex.length == 1 ? "0" + hex : hex;
        }
        return "#" + componentToHex(a) + componentToHex(r) + componentToHex(g) + componentToHex(b);
    }
    function rgbToHex(r,g,b,a){
        //http://stackoverflow.com/questions/5623838/rgb-to-hex-and-hex-to-rgb
        r = Math.floor(parseFloat(r) * 255);
        g = Math.floor(parseFloat(g) * 255);
        b = Math.floor(parseFloat(b) * 255);
        a = Math.floor(parseFloat(a) * 255);

        return rgbToHex255(r,g,b,a);
    }


    function hexToRgb255(hex){
        //http://stackoverflow.com/questions/5623838/rgb-to-hex-and-hex-to-rgb
        var defaultVal = { r: 0, g : 0, b : 0, a : 1 }
        var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        if(result !== null){
            return {
                r: parseInt(result[1], 16),
                g: parseInt(result[2], 16),
                b: parseInt(result[3], 16),
                a : 255
            }
        }

        //try regexing on 4. so we can  get a.
        result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result ? {
            a: parseInt(result[1], 16),
            r: parseInt(result[2], 16),
            g: parseInt(result[3], 16),
            b: parseInt(result[4], 16)
        } : defaultVal;
    }

    function hexToRgb(hex){
        //http://stackoverflow.com/questions/5623838/rgb-to-hex-and-hex-to-rgb
        var res = hexToRgb255(hex);
        res.a /= 255;
        res.r /= 255;
        res.g /= 255;
        res.b /= 255;
        return res;
    }

    //returns all colors as a js object. This means this dont get updated obviously, duh
    function getAllAsJsObject() {
        return {
            accent   : accent  ,
            danger   : danger  ,
            warning  : warning ,
            success  : success ,
            info     : info    ,
            standard : standard,
            text1    : text1   ,
            text2    : text2   ,
            gray     : gray    ,
            darker   : {
                accent   : darker.accent  ,
                danger   : darker.danger  ,
                warning  : darker.warning ,
                success  : darker.success ,
                info     : darker.info    ,
                standard : darker.standard,
                text1    : darker.text1   ,
                text2    : darker.text2   ,
                gray     : darker.gray    ,
            },
            lighter  : {
                accent   : lighter.accent   ,
                danger   : lighter.danger   ,
                warning  : lighter.warning  ,
                success  : lighter.success  ,
                info     : lighter.info     ,
                standard : lighter.standard ,
                text1    : lighter.text1    ,
                text2    : lighter.text2    ,
                gray     : lighter.gray
            },
            contrasting : {
                accent    : contrasting.accent   ,
                danger    : contrasting.danger   ,
                warning   : contrasting.warning  ,
                success   : contrasting.success  ,
                info      : contrasting.info     ,
                standard  : contrasting.standard ,
                text1     : contrasting.text1    ,
                text2     : contrasting.text2    ,
                gray      : contrasting.gray
            }
        }
    }


    //For ease of use. So we don't have to remember the color names and call functions. happy times!!!!/////
    property color accent   : get("accent" )
    property color danger   : get("danger" )
    property color warning  : get("warning")
    property color success  : get("success")
    property color info     : get("info"   )
    property color standard : get("standard")
    property color text1    : get("text1"   )
    property color text2    : get("text2"   )
    property color gray     : Qt.rgba(0.3,0.3,0.3)

    property SvgColors names : SvgColors {  }

    property QtObject darker : QtObject {
        property color accent   : Qt.darker(accent )
        property color danger   : Qt.darker(danger )
        property color warning  : Qt.darker(warning)
        property color success  : Qt.darker(success)
        property color info     : Qt.darker(info   )
        property color standard : Qt.darker(standard)
        property color text1    : Qt.darker(text1   )
        property color text2    : Qt.darker(text2   )
    }
    property QtObject lighter : QtObject {
        property color accent   : Qt.lighter(accent )
        property color danger   : Qt.lighter(danger )
        property color warning  : Qt.lighter(warning)
        property color success  : Qt.lighter(success)
        property color info     : Qt.lighter(info   )
        property color standard : Qt.lighter(standard)
        property color text1    : Qt.lighter(text1   )
        property color text2    : Qt.lighter(text2   )
    }
    property QtObject contrasting : QtObject {
        property color accent   : getContrastingColor(accent )
        property color danger   : getContrastingColor(danger )
        property color warning  : getContrastingColor(warning)
        property color success  : getContrastingColor(success)
        property color info     : getContrastingColor(info   )
        property color standard : getContrastingColor(standard)
        property color text1    : getContrastingColor(text1   )
        property color text2    : getContrastingColor(text2   )
    }

    ////////////////////////////////////////////////////////////////////////////////


    property Item __private: Item {
        id : logic
        property var map : ({})
        property bool debug : false
        function log(){
            if(debug){
                console.log.apply(this,arguments)
            }
        }

        function rebind(){
            accent = danger = warning = success = info = standard = text1 = text2 = "white"
            accent   = Qt.binding(function() { return  get("accent" )  } )
            danger   = Qt.binding(function() { return  get("danger" )  } )
            warning  = Qt.binding(function() { return  get("warning")  } )
            success  = Qt.binding(function() { return  get("success")  } )
            info     = Qt.binding(function() { return  get("info"   )  } )
            standard = Qt.binding(function() { return  get("standard") } )
            text1    = Qt.binding(function() { return  get("text1"   ) } )
            text2    = Qt.binding(function() { return  get("text2"   ) } )

            darker.accent   = Qt.binding(function() { return Qt.darker(accent )  } )
            darker.danger   = Qt.binding(function() { return Qt.darker(danger )  } )
            darker.warning  = Qt.binding(function() { return Qt.darker(warning)  } )
            darker.success  = Qt.binding(function() { return Qt.darker(success)  } )
            darker.info     = Qt.binding(function() { return Qt.darker(info   )  } )
            darker.standard = Qt.binding(function() { return Qt.darker(standard) } )
            darker.text1    = Qt.binding(function() { return Qt.darker(text1   ) } )
            darker.text2    = Qt.binding(function() { return Qt.darker(text2   ) } )

            lighter.accent   = Qt.binding(function() { return Qt.lighter(accent )  } )
            lighter.danger   = Qt.binding(function() { return Qt.lighter(danger )  } )
            lighter.warning  = Qt.binding(function() { return Qt.lighter(warning)  } )
            lighter.success  = Qt.binding(function() { return Qt.lighter(success)  } )
            lighter.info     = Qt.binding(function() { return Qt.lighter(info   )  } )
            lighter.standard = Qt.binding(function() { return Qt.lighter(standard) } )
            lighter.text1    = Qt.binding(function() { return Qt.lighter(text1   ) } )
            lighter.text2    = Qt.binding(function() { return Qt.lighter(text2   ) } )

            contrasting.accent   = Qt.binding(function() { return getContrastingColor(accent  ,1.2)  } )
            contrasting.danger   = Qt.binding(function() { return getContrastingColor(danger  ,1.2)  } )
            contrasting.warning  = Qt.binding(function() { return getContrastingColor(warning ,1.2)  } )
            contrasting.success  = Qt.binding(function() { return getContrastingColor(success ,1.2)  } )
            contrasting.info     = Qt.binding(function() { return getContrastingColor(info    ,1.2)  } )
            contrasting.standard = Qt.binding(function() { return getContrastingColor(standard,1.2) } )
            contrasting.text1    = Qt.binding(function() { return getContrastingColor(text1   ,1.2) } )
            contrasting.text2    = Qt.binding(function() { return getContrastingColor(text2   ,1.2) } )
        }

        function isColorName(str){
            return str === "accent" ||
            str === "danger"        ||
            str === "warning"       ||
            str === "success"       ||
            str === "info"          ||
            str === "standard"      ||
            str === "text1"         ||
            str === "text2"
        }


        QtObject {
            id : stockColors
            objectName : "DerpyDefaults"
            property color accent   : "#2B3D51"
            property color danger   : "#EA4B35"
            property color warning  : "#F59C00"
            property color success  : "#01BC9D"
            property color info     : "#2C97DD"
            property color standard : "#95A5A5"
            property color text1    : "black"
            property color text2    : "white"
        }
        Timer {
            id          : initTimer
            interval    : 10
            repeat      : false
            running     : true
            onTriggered : flm.nameFilters = ["*.qml"]
        }
        FolderListModel {
            id  : flm
            showDirs        : false
            showDotAndDotDot: false
            nameFilters     : ["*.hateYourLife"]
            onFolderChanged : { logic.log("Colors Folder =" , folder) ; decidetoLoad("folder") }
            onCountChanged  : decidetoLoad("count")

            function decidetoLoad(caller){
//                console.log('DECIODE TO LOAD CALLED', count)
                logic.log("Colors decideToLoad called" , caller , count)
                if(count > 0 && !initTimer.running) {
                    colorContainer.load()
                }
            }
        }
        Item {
            id : colorContainer
            property int totalColors  : -1
            property int colorsLoaded : -1

            onColorsLoadedChanged: {
                if(colorsLoaded !== -1 && colorsLoaded === totalColors)
                    rootObject.loaded = true
            }

            function clear(){
                for(var i = 0; i < children.length; i++) {
                    var child = children[i]
                    child.parent = null
                    if(child)
                        child.destroy()
                }
                children = []
            }

            function load(){
                logic.map = {}
                rootObject.loaded = false
                colorContainer.clear()
                colorContainer.totalColors  = flm.count
                colorContainer.colorsLoaded = 0

                for(var i = 0; i < flm.count; i++) {
                    var path = flm.get(i, 'filePath').toString()
                    path = path.indexOf(":") !== 0 ? "file:///" + path : path.slice(1)

                    var name = path.split("/")
                    name     = name[name.length -1]
                    name     = name.replace(".qml", "")

//                    console.log("load colors", path)

                    logic.map[name] = getNewObject(path, colorContainer)
                    colorsLoaded++
                }
            }


            function getNewObject(name,parent){
                var cmp = Qt.createComponent(name)
                if(cmp.status !== Component.Ready)
                    logic.log(name,cmp.errorString())
                return cmp.createObject(parent)
            }
        }
    }




}

