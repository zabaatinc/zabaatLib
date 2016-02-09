import QtQuick 2.4
import Zabaat.Controller 1.0
import QtQuick.Controls 1.2
import Qt.labs.folderlistmodel 2.1
import Qt.labs.settings 1.0
import Zabaat.Misc.Util 1.0
//import Zabaat.Misc.Util 1.0 as Util

pragma Singleton
Item
{
   id : rootObject
   property bool debugMode                  : false
   property bool debugToConsole             : false
   property var   hud                       : null  //whatever holds the HUD sets this
   property alias settings                  : settings
   property alias functions                 : functionsObj
   property alias logic                     : logicObj
   property alias serverVars                : serverVarsObj
   property alias userVars                  : userVarsObj
   property alias client                    : serverVarsObj.client
   property alias app                       : appObj
   property alias style                     : styleObj
   property var   objects                   : ({})
   property string debugShortCut            : "Ctrl+Shift+D"
   property string toggleDebugModeShortCut  : "Ctrl+Shift+T"
   property alias  grabQMLsFromServer       : serverVarsObj.grabQmlsFromServer
   property alias  animator                 : _animationControl
   property alias _                         : underscore
   property alias libAccounting             : accountingLib
   property var   moment                    : Moment

   /*! example usage of these signals
      Connections {
          target : ZGlobal
          onObjectAdded : {
              if(name === "aliasMap") {
                  gSearcher.state = "advanced"
                  gSearcherComboBox._model = ZGlobal.objects.aliasMap
              }
          }
       }
   !*/
   signal objectChanged(string name, var obj);
   signal objectAdded  (string name, var obj);
   signal objectChangedOrAdded(string name, var obj);

   property int status: Component.Loading
   property bool fontsLoaded : false
   onFontsLoadedChanged: if(fontsLoaded) console.log(fontContainer.getCustomLoadedFonts())




    function debugMsg(){
        if(debugMode)
        {
            try{
                hud.debugMsg.apply(this,arguments)
            }catch(e) { console.log("error printing to hud's console", e.message) }

            if(debugToConsole)  console.log.apply(this,arguments)
        }
    }
    function debugBypass(){ //doesnt care about the debugBool
        try{
            hud.debugMsg.apply(this,arguments)
        }catch(e) { console.log("error printing to hud's console", e.message) }

        if(debugToConsole)  console.log.apply(this,arguments)
    }

    QtObject {
        id : logicObj

        function or(variable){
            if(isDef(variable)){
                for(var i = 1 ; i < arguments.length; i++){
                    if(variable === arguments[i])
                        return true
                }
            }
            else{
                for(i = 0; i < arguments.length; i++){
                    if(arguments[i])
                        return true
                }
            }

            return false
        }
        function not(variable){
            if(isDef(variable)){
                for(var i = 1 ; i < arguments.length; i++){
                    if(variable === arguments[i])
                        return false
                }
            }
            else{
                for(i = 0; i < arguments.length; i++){
                    if(arguments[i])
                        return false
                }
            }

            return true
        }
        function and(){
            for(var i = 0; i < arguments.length; i++){
                if(!arguments[i])
                    return false
            }
        }
        function isUndef(){
            if(arguments.length === 0)
                return true

            for(var i = 0; i < arguments.length ; i++){
                var item = arguments[i]
                if(item === null || typeof item === 'undefined')
                    return true
            }
            return false
        }
        function isDef(){
            if(arguments.length === 0)
                return false

            for(var i = 0; i < arguments.length; i++){
                var item = arguments[i]
                if(item === null || typeof item === 'undefined')
                    return false
            }
            return true
        }

    }
    QtObject {
        id : functionsObj
        //If this function is misbehaving, use getNewObject(Qt.resolveUrl(name), <parentName>) from
        //wherever you are calling it. This will solve messages like 'QQmlComponent not ready' if it
        //is caused by Qt not being able to find the qml file!!

        property QtObject colors: QtObject {
            id : colors
            function getDifferent(color){
                var lighter = Qt.lighter(color)
                var darker  = Qt.darker(color)

                var lightDiff = Math.sqrt( Math.pow(lighter.r - color.r,2) +
                                           Math.pow(lighter.g - color.g,2) +
                                           Math.pow(lighter.b - color.b,2)
                                          )

                var darkDiff = Math.sqrt( Math.pow(darker.r - color.r,2) +
                                          Math.pow(darker.g - color.g,2) +
                                          Math.pow(darker.b - color.b,2)
                                        )

                if(lightDiff >= darkDiff)
                    return lighter
                return darker
            }
        }


        function getNewObject(name,parent){
            var cmp = Qt.createComponent(name)
            if(cmp.status !== Component.Ready)
                debugMsg(name,cmp.errorString())

            return cmp.createObject(parent)
        }
        function spch(str)    {     return  "\"" + str + "\"";   }
        function getQmlObject(imports,qmlStr,parent) {

//            console.log("______")
//            console.trace()
//            console.log("______")

            var str = ""
            if(typeof imports !== 'string')
            {
                for(var i in imports)
                    str += "import " + imports[i] + ";\n"
            }
            else
                str = "import " + imports + ";"

            var obj = Qt.createQmlObject(str + qmlStr,parent,null)
            return obj
        }
        function replaceLine(str, searchTerm, newLine, numReplaces){
            var strarr = str.split('\n')
            var replaced = 0
            for(var s in strarr)
            {
                if(strarr[s].indexOf(searchTerm) != -1)
                {
                    strarr[s] = newLine
                    replaced++
                    if(numReplaces && replaced >= numReplaces)
                        break
                }
            }
             return strarr.join('\n')
        }
        function showConsole() {
            if(hud && typeof hud.displayConsole != 'undefined')
                hud.displayConsole()
        }
        function getCustomLoadedFonts() { return fontContainer.getCustomLoadedFonts() }
        function setWindowPtr(win) {
            if(win)
            {
                app.width         = Qt.binding( function() { return win.width  } )
                app.height        = Qt.binding( function() { return win.height } )
                app.x             = Qt.binding( function() { return win.x      } )
                app.y             = Qt.binding( function() { return win.y      } )
                app.mainWindowPtr = Qt.binding( function() { return win        } )

                var action = functions.getQmlObject(["QtQuick 2.4", "QtQuick.Controls 1.2"], "Action{}", win)
                action.shortcut = rootObject.debugShortCut
                action.triggered.connect(functions.showConsole)
                action.enabled = Qt.binding(function() { return rootObject.debugMode} )

                var action2 = functions.getQmlObject(["QtQuick 2.4", "QtQuick.Controls 1.2"], "Action{}", win)
                action2.shortcut = rootObject.toggleDebugModeShortCut
                action2.triggered.connect(functions.toggleDebug)
            }
        }
        function toggleDebug()  { debugMode = !debugMode }
        function stdTimeZoneOffset() {
            var today = new Date()

            var jan = new Date(today.getFullYear(), 0, 1);
            var jul = new Date(today.getFullYear(), 6, 1);
            return Math.max(jan.getTimezoneOffset(), jul.getTimezoneOffset());
        }
        function getDateTimeZone(date) {
            //return date.getTimezoneOffset() < stdTimezoneOffset();
//            console.log(date.getTimezoneOffset(), stdTimeZoneOffset(), stdTimeZoneOffset() - date.getTimezoneOffset() )
            return stdTimeZoneOffset() - date.getTimezoneOffset();
        }


        function readFile(source, callback) {
            var xhr = new XMLHttpRequest;
            xhr.open("GET", source);
            xhr.onreadystatechange = function ()
            {
                if (xhr.readyState === XMLHttpRequest.DONE && isDef(callback))
                {
                    callback(xhr.responseText)
                }
            }
            xhr.send();
        }
        function readJSON(source, callback) {
            readFile(source, function(jsData) {

                var a = JSON.parse(jsData);
                if(callback)
                    callback(a)
//                try {

//                }
//                catch(e) {
//                    console.log("ZGLOBAL.read   JSON failed to parse", e)
//                    if(callback)
//                        callback(null)
//                }
            })
        }

        //source is a relative path bro! or url!
        function saveSettings(source){
            //TODO implement
        }

        function loadSettingsFromJSON(source) {
            readFile(source, function(output){
                    try{
                        var a = JSON.parse(output);
                        a     = a[0]
                        loadSettingsObject(a, rootObject)
                    }
                    catch(e){
                        console.log("unable to load file", source)
                    }

                })
        }
        function loadSettingsObject(obj, thisPtr) {
            if(!thisPtr)
                thisPtr = rootObject

            if(isDef(thisPtr))
            {
                for(var k in obj)
                {
                    if(thisPtr.hasOwnProperty(k))
                    {
                        if(typeof obj[k] === 'object')     loadSettingsObject(obj[k],thisPtr[k])
                        else                               thisPtr[k] = obj[k]
                    }
                }
            }
        }
        function getProperties(obj, exclude, doesNotContain){
            var propArr = []

            if(!isUndef(obj)) {
                if(underscore.isArray(obj)){  //is array
                    for(var i = 0; i < obj.length ; i++){
                        propArr.push(i)
                    }
                }
                else{
                    for(var o in obj){
                        var doesNotContainPass = -2
                        if(doesNotContain)
                            doesNotContainPass = o.indexOf(doesNotContain)

                        if(doesNotContainPass < 0)  //-1 && -2 are both passes!!
                        {
                            if(!isUndef(exclude) && !isUndef(exclude.length) &&  exclude.length > 0)
                            {
                                if(underscore.indexOf(exclude,o,false) === -1)
                                        propArr.push(o)
                            }
                            else {
                                propArr.push(o)
                            }
                        }
                    }
                }
            }

            return propArr
        }
        function req (options, data, callback) {  //generic XHR request function for POST / GET
            // @params options  OBJECT    protocol (http,https), host, port, path (includes options and params)
            // @params data  OBJECT  (optional - you can send in your keys/values as a preformatted string if you really want to, but you should still send in the PATH)    {key:value , key1:value1}  these will be parsed to a string and appended to the path
            var xhr = new XMLHttpRequest(),
                uri,
                method,
                userAgent;

            if (typeof options ==='object'){
                uri = options
                method = options.method || 'get'
                if(uri.protocol == "http" || uri.protocol == "https") {}//you done good son!
                else uri.protocol = "http"  //TODO  - default to https
                if (!uri.host){uri.host = settings.serverName}
                if(!uri.port){uri.port = settings.serverPort}
                if(!uri.path){uri.path = ""}
            }

            if(uri.path.charAt(0)=="/"){uri.path.substring(1,uri.path.length)}  //if you send in a "/Globals we remove the / for you!

            if (typeof data ==='object'){
                var tempData = '?' //header request wants the ? before it starts processing params
                for (var d in data){
                    tempData+= d+'='+data[d]+'&'
                }
                data = tempData.slice(0,tempData.length-1);
            }


            //sending part
            if (method === 'get') {
                xhr.open('GET', uri.protocol + '://' + uri.host +":"+uri.port+ '/' + uri.path + data);
                xhr.send(null);
            } else {
                xhr.open('POST', uri.protocol + '://' + uri.host +":"+uri.port+ '/' + uri.path + data);
                xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
                xhr.send();
            }

            xhr.onreadystatechange = function() {
                if (xhr.readyState !== 4) { // full body received
                    return;
                }
                callback({status: xhr.status, header: xhr.getAllResponseHeaders(), body: xhr.responseText});
            };
    }

        function addAction(shortcut, func) {
            if(app.mainWindowPtr)
            {
                var action
                if(typeof appObj.actionsMap[shortcut] === 'undefined')
                {
                    action = functions.getQmlObject(["QtQuick 2.4", "QtQuick.Controls 1.2"], "Action{ property var funcPtr : null }", app.mainWindowPtr.contentItem)
                    action.shortcut = shortcut
                    action.funcPtr = func
                    action.triggered.connect(action.funcPtr)
                    appObj.actionsMap[shortcut] = action
                }
                else{
                    action = appObj.actionsMap[shortcut]
                    action.triggered.disconnect(action.funcPtr)     //disconnect old function
                    action.funcPtr = func
                    action.triggered.connect(action.funcPtr)        //connect new one
                }
            }
        }
        function removeAllActionsThatReturnFalse(predicate){
            if(isUndef(predicate))
                predicate = function() { return false }

            for(var shortcut in appObj.actionsMap){
                var action = appObj.actionsMap[shortcut]
                if(!predicate(shortcut)){
                    action.triggered.disconnect(action.funcPtr)     //disconnect old function
                }
            }

        }
        function removeAction(shortcut){
            if(typeof appObj.actionsMap[shortcut] !== 'undefined'){
                var action = appObj.actionsMap[shortcut]
                action.triggered.disconnect(action.funcPtr)     //disconnect old function
            }
        }

        function capitalizeFirstLetter(string) {
            return string.charAt(0).toUpperCase() + string.slice(1);
        }
        function nextChar(c) {
            return String.fromCharCode(c.charCodeAt(0) + 1);
        }
        function len(obj){
            var count = 0
            for(var o in obj)
                count++
            return count
        }
        function replaceChar(string, index, character) {
            return string.substr(0, index) + character + string.substr(index+character.length);
        }
        function replaceAll(find, replace, str) {
          return str.replace(new RegExp(escapeRegExp(find), 'g'), replace);
        }
        function escapeRegExp(string) {
            return string.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1");
        }
        function moveArrayElem(arr, old_index, new_index) {
            if (new_index >= arr.length) {
                var k = new_index - arr.length;
                while ((k--) + 1) {
                    arr.push(undefined);
                }
            }
            arr.splice(new_index, 0, arr.splice(old_index, 1)[0]);
            return arr; // for testing purposes
        }


        function fitToParent_Snug(obj){

            var smallnessX = arguments.length >= 2 ? arguments[1] : 0.05
            var smallnessY = arguments.length >= 3 ? arguments[2] : 0.08
            var parent     = arguments.length >= 4 ? arguments[3] : obj.parent

            if(obj && parent){
                obj.width                    = Qt.binding(function(){ return parent.width  * (1 - smallnessX)      })
                obj.height                   = Qt.binding(function(){ return parent.height * (1 - smallnessY)      })
                obj.anchors.horizontalCenter = parent.horizontalCenter
                obj.anchors.top              = parent.top
                obj.anchors.topMargin        = 15
            }
        }
        function clearChildren(obj){
            if(obj && typeof obj.children !== 'undefined'){
                for(var i = obj.children.length - 1; i > -1; i--){
                    var child = obj.children[i]
                    child.parent = null
                    child.destroy()
                }
            }
        }
        function printObject(obj, tabStr, key){
             if(tabStr === null || typeof tabStr === 'undefined'){
                 tabStr = ""
                 console.log(obj)
             }

             if(obj){
                 var type = getType(obj)
                 if(type === 'listmodel' || type === 'array'){
                     console.log(tabStr + key)
                     var lenProperty = type === 'array' ? 'length' : 'count'
                     for(var i = 0; i < obj[lenProperty]; i++){
                         var item = type === 'array' ? obj[i] : obj.get(i)
                         printObject(item, tabStr + "\t", i)
                     }
                 }
                 else if(type === 'object'){
                     console.log(tabStr + key)
                     for(var o in obj){
                         item = obj[o]
                         printObject(item, tabStr + "\t", o)
                     }
                 }
                 else {
                     console.log(tabStr + key +  ":" + obj)
                 }
             }
        }

        //builds a string where it replaces all instances of %s with the args provided! ex., buildString("im a %s in %s",'herp','heaven') will return "im a herp in heaven"
        function buildString(str){
            var args = Array.prototype.slice.call(arguments, 1)
            console.log(args)
            var index = 0
            return str.replace(/%s/g, function(match, number)
            {
                var ret = typeof args[index] != 'undefined' ? args[index] : index ;
                index++
                return ret
            });
        }

        function arrEq(arr1, arr2){

            var exists1 = isUndef(arr1)
            var exists2 = isUndef(arr2)

            if(exists1 === exists2){
                if(!exists1)
                    return true
                else if(arr1.length === arr2.length){
                    for(var i = 0; i < arr1.length; i++){
                        if(arr1[i] != arr2[i])
                            return false
                    }
                }
            }
            return true
        }
        function isUndef(){
            if(arguments.length === 0)
                return true

            for(var i = 0; i < arguments.length ; i++){
                var item = arguments[i]
                if(item === null || typeof item === 'undefined')
                    return true
            }
            return false
        }
        function isDef(){
            if(arguments.length === 0)
                return false

            for(var i = 0; i < arguments.length; i++){
                var item = arguments[i]
                if(item === null || typeof item === 'undefined')
                    return false
            }
            return true
        }

        function countOccurences(str, searchText){
            return str.split(searchText).length - 1
        }
        function modelObjectToJs(mo){
            var obj =  {}

            for(var k in mo){
                if(k !== 'objectName' &&  k !== 'objectNameChanged' && k.indexOf("__") === -1)
                    obj[k] = mo[k]
            }

            return obj
        }

        function endsWith(str, suffix, ignoreCase) {
            if(isUndef(ignoreCase))
                ignoreCase = false

            if(ignoreCase){
                str = str.toLowerCase()
                suffix = suffix.toLowerCase()
            }

            return str.indexOf(suffix, str.length - suffix.length) !== -1;
        }
        function startsWith(str, prefix, ignoreCase){
            if(isUndef(ignoreCase))
                ignoreCase = false

            if(ignoreCase){
                str = str.toLowerCase()
                prefix = prefix.toLowerCase()
            }

            return str.indexOf(prefix) === 0;
        }
        function contains(str, term, ignoreCase){
            if(isUndef(ignoreCase))
                ignoreCase = false

            if(ignoreCase){
                str = str.toLowerCase()
                term = term.toLowerCase()
            }

            return str.indexOf(term)
        }

        //http://stackoverflow.com/questions/149055/how-can-i-format-numbers-as-money-in-javascript
        function moneyify(number, modifier, c, d, t){
            if(isUndef(modifier))
                modifier = 1

            var n = number * modifier
            c = isNaN(c = Math.abs(c)) ? 2 : c
            d = d == undefined ? "." : d
            t = t == undefined ? "," : t
            var s = n < 0 ? "-" : ""
            var i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + ""
            var j = (j = i.length) > 3 ? j % 3 : 0
            return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
         }

        function numbersOnly(str){
            return str.replace(/[^\d.-]/g, '');
        }
        function isADecimalNumber(str){
            return str.match(/^\d*\.?\d*$/g);
        }
        function getDelegateInstance(lv, idx, delIndexName, quickDelIdentifier){
            if(lv && lv.count && idx >= 0 && idx < lv.count){

                if(isUndef(delIndexName))               delIndexName = "_index"
                if(isUndef(quickDelIdentifier))         quickDelIdentifier = null

                for(var i = 0; i < lv.contentItem.children.length; i++)
                {
                    var elem = lv.contentItem.children[i]
                    if(quickDelIdentifier !== null){
                        if(elem[quickDelIdentifier] && elem[delIndexName] === idx)
                            return elem
                    }
                    else
                    {
                        if(elem[delIndexName] === idx)
                            return elem
                    }
                }
            }
            return null
        }
        function getType(obj){
            if(obj === null)
                return null

            if(typeof obj === 'undefined')
                return 'undefined'

            if(underscore.isArray(obj))
                return 'array'
            if(obj.toString().toLowerCase().indexOf('listmodel') !== -1 ||
               obj.toString().toLowerCase().indexOf('sortfilterproxymodel') !== -1 )
                return 'listmodel'

            if(typeof obj === 'object')
                return 'object'

            return typeof obj
        }
        function phoneNumberify(str) {
            if(str && str.indexOf("-") === -1)
                return str.substr(0, 3) + '-' + str.substr(3, 3) + '-' + str.slice(6)
            return str
        }

        function addObject(name, obj) {
            rootObject.objects[name] = obj
            objectAdded(name,rootObject.objects[name]);
            objectChangedOrAdded(name, rootObject.objects[name])
        }
        function setObject(name, value) {
            if(isDef(rootObject.objects[name])){
                if(rootObject.objects[name] !== value) {
                    rootObject.objects[name] = value
                    objectChanged(name,rootObject.objects[name]);
                    objectChangedOrAdded(name, rootObject.objects[name]);
                }
            }
        }
        function objectChanged(name){
            if(isDef(rootObject.objects[name])) {
                rootObject.objectChanged(name,rootObject.objects[name]);
                objectChangedOrAdded(name, rootObject.objects[name]);
            }
        }

        function swapValues(obj1, prop1, obj2, prop2){
            if(isDef(obj1,prop1,obj2)){
                var temp1 = obj1[prop1]

                if(!isUndef(prop2))
                    prop2 = prop1

                obj1[prop1] = obj2[prop2]
                obj2[prop2] = obj1[prop1]
            }
        }


    }
    QtObject {
       id : serverVarsObj
       property string  hostName        : ""
       property int     port            : 0
       property string  protocol        : ""
       property string  httpProtocol    : "http"
       property string  sessionCookie   : ""

       property bool    grabQmlsFromServer : false
       property string  qmlServerPath      : grabQmlsFromServer ?  "http://" + hostName + ":" + port + "/" : ""
       property ZClient client : ZClient {
           uri                  : serverVars.protocol + "://" +  serverVars.hostName + ":" + serverVars.port
           externalDebugFunc    : debugMsg
           debugMode            : false //socketIO
           controller.debugMode : false //controller
           token                : ''
           onStatusUpdate       : hud && hud.addMessage ? hud.addMessage("\uf1e6 ",'Server connection lost, reconnect in '+reconnectTimer) : function(){}
           //TODO - make the server
           function setToken(token){
               if (typeof client.token === 'string'){
                   client.token = token
                   client.connect()
               }else{console.log('Globals.client - invalid typoe of token sent, expected string')}
           }



       }
        Component.onCompleted: {  //TODO - dynamic settings object loader?

        }

    }
    QtObject {
       id : userVarsObj
       property string lastUserName    : "wolfy"
       property string userName        : ""
       property string firstName       : ""
       property string lastName        : ""
       property string userId          : ""
    }
    Item     {
        id : styleObj
        // for app border  #ebebeb
        property color accent        : "#2B3D51"
        property color danger        : "#EA4B35"
        property color warning       : "#F59C00"
        property color success       : "#01BC9D"
        property color info          : "#2C97DD"
        property color _default      : "#95A5A5"


        property int    containerRadius: 3
        property alias text : textObj

        Item {
            id : textObj
            property url    fontSource      : ""
            onFontSourceChanged: fontList.folder = Qt.resolvedUrl(fontSource)
            property string defaultFontName : "Courier"
            property string fancyFontName   : "Diogenes"

            property color color1         : "black"
            property color color2         : "white"

            property alias  heading1      : heading1Obj.font
            property alias  heading2      : heading2Obj.font
            property alias  heading3      : heading3Obj.font
            property alias  subtitle      : subtitleObj.font
            property alias  normal        : normalObj.font
            property alias  fancy         : fancyObj.font

            Item {
                id : fontLoaders
                FolderListModel {
                    id : fontList
                    nameFilters     : ["*.ttf", "*.otf", "*.fnt" ]
                    showDirs        : false
                    showDotAndDotDot: false
                    onCountChanged  : if(count > 0){
                                          fontLoaders.loadFonts()
//                                          console.log(Qt.fontFamilies())
                                      }
                }
                Item {
                    id : fontContainer
                    property var fonts : []
                    property int totalFonts  : -1
                    property int fontsLoaded : -1
                    onFontsLoadedChanged: if(fontsLoaded !== -1 && fontsLoaded === totalFonts)
                                              rootObject.fontsLoaded = true

                    function clear() {
                        fonts = []
                        for(var i = 0; i < children.length; i++)
                        {
                            children[i].parent = null
                            children[i].destroy()
                        }
                        children = []
                    }
                    function getCustomLoadedFonts(){
                        var arr = []
                        for(var i = 0; i < fonts.length; i++)
                            arr.push(fonts[i].name)
                        return arr
                    }

                }
                function loadFonts() {
                    fontContainer.clear()
                    fontContainer.totalFonts = fontList.count
                    fontContainer.fontsLoaded = 0

                    for(var i = 0; i < fontList.count; i++) {
                        var fl        = functions.getQmlObject(["QtQuick 2.4"], "FontLoader{ }", fontContainer)
                        fl.statusChanged.connect(function() { if(status === FontLoader.Ready) fontContainer.fontsLoaded++})

                        fontContainer.fonts.push(fl)

                        var filePath = fontList.get(i, 'filePath')
                        if(filePath.toString().indexOf(":") !== 0) {
                            fl.source = "file:///" + filePath
                        }
                        else{
                            //is in QRC
                            fl.source = filePath.toString().slice(1)
                        }
                    }
                }
            }

            //Apparently it's impossible to create fonts!! We will use this hacky way instead.
            Text  {  id : heading1Obj ; font.family: rootObject.style.text.defaultFontName;    font.pointSize: 20 }
            Text  {  id : heading2Obj ; font.family: rootObject.style.text.defaultFontName;    font.pointSize: 18 }
            Text  {  id : heading3Obj ; font.family: rootObject.style.text.defaultFontName;    font.pointSize: 16 }
            Text  {  id : subtitleObj ; font.family: rootObject.style.text.defaultFontName;    font.pointSize: 15 }
            Text  {  id : normalObj   ; font.family: rootObject.style.text.defaultFontName;    font.pointSize: 12 }
            Text  {  id : fancyObj    ; font.family: rootObject.style.text.fancyFontName  ;    font.pointSize: 15 }
        }
    }
    QtObject {
        id : appObj
        property var mainWindowPtr: null
        property int width: 1024
        property int height: 768
        property int x: 0
        property int y: 0
        property var actionsMap : ({})
    }
    Settings {
         id:settings //                        \/        <-  it's a snake!
         property string username   :  ''
         property string password   :  ''

         property string serverName :  ''
         property string serverPort :  ''
         property string systemColor:  ''

         property bool   devMode   : false
         property string version   :  ''
         property bool   autoLogin : false

         property double backgroundOpacity : 0.98
         property int cellsPerRow_mainPages : 5
     }

    Underscore    { id  : underscore         }
    AccountingLib { id  : accountingLib      }
    ZAnimator     { id  : _animationControl  }


    Component.onCompleted: {
        serverVarsObj.hostName= settings.serverName
        serverVarsObj.port    = settings.serverPort
        rootObject.status     = Component.Ready // leave in every project
    }


}


