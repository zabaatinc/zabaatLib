import QtQuick 2.4
import Zabaat.UI.Wolf 1.1
import Zabaat.UI.Wolf.Extended 1.0
import Zabaat.Misc.Global 1.0
import Qt.labs.folderlistmodel 2.1
import QtQuick.Window 2.0


Rectangle {
    id : rootObject
    width : parent ? parent.width  : ZGlobal.app.width
    height: parent ? parent.height : ZGlobal.app.height
    color : "transparent"
    property string title: "home"
    property var aliasMap : null
    property alias iconMap : navBar.iconMap

    property url rootPath : Qt.resolvedUrl(".")
    property url localComponentsPath : Qt.resolvedUrl("./Components")
    onLocalComponentsPathChanged     : console.log("LOCAL COMPNENTS PATH = ", localComponentsPath)
    property var windows    : []
    property var goBack        : function() {
                                    if(itemShower.prevItem !== null){
                                        itemShower.showNewItem(itemShower.prevItem)
                                    }
                                 }


    function getActiveWindow(){
        if(windows && windows.length > 0){
            for(var w in windows){
                if(windows[w].active)
                    return windows[w]
            }
        }

        if(ZGlobal.app.mainWindowPtr)
            return ZGlobal.app.mainWindowPtr

        return null
    }


    Component.onCompleted: {
        ZGlobal.functions.addObject('loadPageNew'         , functions.loadpageNew)
        ZGlobal.functions.addObject('objectsModel'        , om)
        ZGlobal.functions.addObject('aliasMap'            , aliasMap)
        ZGlobal.functions.addObject('birdsEyeFunction'    , mainFlipper.flip)
        ZGlobal.functions.addObject('setTitle', function(str, cb) { titleDisp.text = str; ZGlobal.client.controller.postReq('/globals/otherUsersOnPage',{page:str}, cb) })


        if(ZGlobal.functions.isUndef(windows))      windows = []

        ZGlobal.functions.addObject('windows', windows)
        ZGlobal.functions.addObject('getActiveWindow', getActiveWindow)
        ZGlobal.functions.addObject('registerNewWindow' , functions.registerNewWindow)


        if(ZGlobal.objects.setTitle)
            ZGlobal.objects.setTitle(title )

        ZGlobal.functions.addAction('F2', mainFlipper.flip)// functions.birdsEyeFunction)

        ZGlobal.functions.addObject("goBack",goBack)

        if(ZGlobal.functions.isUndef(ZGlobal.objects.logoutCallBacks))      ZGlobal.objects['logoutCallBacks'] = [om.wipe]
        else                                                                ZGlobal.objects.logoutCallBacks.push(om.wipe)
    }


    ObjectModel{  id : om  }


    ZFlippable {
        id : mainFlipper
        anchors.fill: parent
        flipSpeed : 333

        front : Item  {
            id : itemShower
            width   : mainFlipper.width
            height  : mainFlipper.height
            enabled : !mainFlipper.flipped

            function titleChangeFunc(){
                ZGlobal.objects.setTitle(showItem.item.title)
            }
            function isAnFKey(str){
                if(str) {
                    str = str.toLowerCase()
                    return str.indexOf('alt') !== -1 || (str.length === 2 && str.charAt(0) === 'f' && Number(str.charAt(1)))
                }
                return false
            }

            property var showItem : null
            property var prevItem : null
            onPrevItemChanged: {
                if(ZGlobal.functions.isUndef(ZGlobal.objects.hasPrev))
                    ZGlobal.functions.addObject('hasPrev', ZGlobal.functions.isDef(prevItem))

                if(prevItem)    ZGlobal.functions.setObject('hasPrev',true)
                else            ZGlobal.functions.setObject('hasPrev',false)
            }

            function showNewItem(obj) {
                if(obj)   {
                    //try { console.log('show me', obj, showItem !== obj) }  catch(e) { console.log(e.message) }
                    if(showItem !== obj)
                    {
                        if(showItem) {   //old showItem
                            showItem.parent = null
                            if(showItem.item.title){
                                showItem.item.titleChanged.disconnect(titleChangeFunc)
                            }

                            if(obj !== prevItem) {
                                prevItem = showItem     //make this the previous item, so we can show this if you close the new showItem
                            }
                        }

                        showItem = obj
                        showItem.width  = Qt.binding(function() { return rootObject.width - navBar.minMaxBtnWidth   })
                        showItem.height = Qt.binding(function() { return rootObject.height - minBtn.height          })
                        showItem.y             = minBtn.height
                        showItem.parent        = itemShower
                        showItem.anchors.right = itemShower.right

                        ZGlobal.functions.removeAllActionsThatReturnFalse(isAnFKey)

                        if(ZGlobal.functions.isDef(showItem.item)){
                            if(ZGlobal.objects.setTitle && typeof showItem.item.title === 'string'){
                                ZGlobal.objects.setTitle(showItem.item.title)
                                showItem.item.titleChanged.connect(titleChangeFunc)
    //                            console.log('connected title')
                            }

    //                        console.log("Hello friend, we will check somet things now. dont be afraid")
                            if(ZGlobal.functions.isDef(showItem.item.init)){
                                if(showItem.item.alwaysInit)                                                 showItem.item.init()
                                else if(showItem.item.status && showItem.item.status !== Component.Ready)    showItem.item.init()
                            }
                        }


                    }
                    navBar.minimized = true
                }
                else{
                    if(ZGlobal.objects.setTitle)
                        ZGlobal.objects.setTitle('')
                }
            }
            onEnabledChanged : if(enabled) {
                                  if(showItem === null){
                                      if(prevItem) showNewItem(prevItem)
                                      else         functions.loadpageNew('dash')
                                  }
                                  else if(reopenedObj !== null){
                                      showNewItem(reopenedObj)
                                      reopenedObj = null
                                  }
                                  else
                                    itemShower.titleChangeFunc()
                               }
            property var reopenedObj : null
        }
        back  : Rectangle  {
            id : recentsItem
            width            : mainFlipper.width
            height           : mainFlipper.height
            enabled          : mainFlipper.flipped
            color            : ZGlobal.style.warning
            onEnabledChanged : if(enabled)
                                   ZGlobal.objects.setTitle("Open Windows")

            RecentsView {
                width  : mainFlipper.width
                height : mainFlipper.height //- recentsTitle.height
                x      : cellWidth/2

                iconMap : rootObject.iconMap
                cellHeight: height/2
                anchors.top : parent.top
                anchors.topMargin : 40
                model   : om
                onReopen:  { itemShower.reopenedObj = obj; mainFlipper.flipped = false;  }
                onClose :  {
                    if(itemShower.showItem && itemShower.showItem.objectName === name)
                        itemShower.showItem = null
                }

                primaryTextColor  : ZGlobal.style.text.color1
                secondaryTextColor: ZGlobal.style.text.color2
                primaryBgColor    : 'transparent'
                secondaryBgcolor  : ZGlobal.style.accent
            }

        }
    }




    NavBar{
        id : navBar
        width : 200
        height : parent.height - btnRowBackground.height
        onSelected: itemShower.showNewItem(obj)     //this only matters for root folders!
        rootPath : rootObject.rootPath
        Component.onCompleted: {
            ZGlobal.functions.addAction('f1', function() { if(ZGlobal.objects.loginState && ZGlobal.objects.loginState())  navBar.minimized = !navBar.minimized })
        }
        onMinimizedChanged: {
            if(!navBar.minimized)
                navBar.forceActiveFocus();
        }
        enabled : ZGlobal.objects.loginState ? ZGlobal.objects.loginState() : false
        listPtr.onXChanged: {
//            console.log("x changed", listPtr.x)
//            if(itemShower.showItem){
//                itemShower.showItem.width = rootObject.width - listPtr.x
//            }

        }
        anchors.top: btnRowBackground.bottom
    }
    Rectangle {
        id : btnRowBackground
        width : parent.width
        height : minBtn.height
        ZButton{
            id : titleDisp
            text : "home"
            width : visible ? 32 * 5 : 0
            enabled: false
            height : minBtn.height
            border.width: 0
            defaultColor: btnRowBackground.color
            textColor   : ZGlobal.style.text.color1
    //        visible : ZGlobal.objects.loggedIn ? true : false
            Connections {
                target : ZGlobal
                onObjectChangedOrAdded: if(name === 'loggedIn') titleDisp.visible = obj
            }
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
    Row   {
        id : btnRow
        anchors.right: parent.right
        width        : minBtn.width + closeBtn.width + filler.width
        height       : minBtn.height
        visible      : itemShower.visible && itemShower.showItem != null && !functions.isRootItem(itemShower.showItem)

        Item {
            width          : filler.width
            height         : filler.height

            ZButton{
                id : filler
                width          : 64
                height         : 32
                text           : ""
                fontAwesomeIcon: "\uf06e"
                onBtnClicked   : {
                    lv.show = !lv.show
                }

                defaultColor: btnRowBackground.color
                textColor   : ZGlobal.style.text.color1
                visible        : lv.count > 0
                onVisibleChanged: {
                    if(visible)
                        ZGlobal.animator.colorAnimation(filler,'textColor',['white','green','yellow'],250,10, false)
                }

                property bool test : false
            }
            ListView{
                id : lv
                width   : filler.width * 3
                height  : width * 3

                property bool show : false
                visible            : lv.count > 0 && show
                x                  : -btnRow.width - 5
                anchors.top        : filler.bottom

                property var rooty: ZGlobal.client.controller.getModelWhenItArrives('otherUsersOnPage',this,'rooty',true)
                model : rooty ?  rooty.get(0).usernames : null
                onCountChanged : if(count > 0)  ZGlobal.animator.colorAnimation(filler,'textColor',['white','green','yellow'],250,10, false)

                delegate   :ZTextBox{
                    width  : filler.width * 4
                    height : 40
                    outlineVisible: false
                    enabled : false
                    labelName : ""
                    text : typeof username !== 'undefined' ? username : ''
                    outlineColor: 'black'
                    color       : '#19181c'
                    fontColor   : 'white'
                }
            }
        }

        ZButton {
            id : minBtn
            showIcon: true
            fontAwesomeIcon: '\uf068'
            onBtnClicked:{
                itemShower.visible = false
                recentsItem.visible = true
            }
            text : ""
            width : 32
            height : width
            defaultColor: btnRowBackground.color
            textColor   : ZGlobal.style.text.color1
            border.width: 1
        }
        ZButton {
            id : closeBtn
            showIcon: true
            defaultColor : ZGlobal.style.danger
            textColor: "white"
            fontAwesomeIcon: '\uf00d'
            text : ""
            width : 32
            height : width
            onBtnClicked:  {
                if(itemShower.showItem && itemShower.showItem.extraInfo.root)
                {
                    //call closeFunc on the open ObjectModel class of this type! The type is stored within the extraInfo.root
                    //and it is categorized by projects as we know. So there's going to bve WorkOrders, Customers, Vehicles, etc
                    om.map[itemShower.showItem.extraInfo.root].open.closeFunc(itemShower.showItem)

                    //let's show dashboard if no previous item exists.
                    if(itemShower.prevItem)       itemShower.showNewItem(itemShower.prevItem)
                    else                          functions.loadpageNew("dash")
//                    itemShower.showNewItem(null)

                }
            }
        }
    }

    Rectangle {
        width : parent.width
        height : minBtn.height
        color : 'transparent'
        border.width: 1

        Rectangle {
            width : 1   //cheyenne
            height : parent.height - (parent.border.width * 2)
            color : btnRowBackground.color
            x : 0
            anchors.verticalCenter: parent.verticalCenter
        }
    }


    QtObject{
        id : functions

        property color focusColor_win   : Qt.rgba(ZGlobal.style.accent.r, ZGlobal.style.accent.g, ZGlobal.style.accent.b)
        property color unfocusColor_win : Qt.lighter(focusColor_win,50)

        property int count : 0
        property alias aliasMap : rootObject.aliasMap
        property var isRootItem : function (obj){
            if(om.map[obj.objectName])
                return true
            return false
        }
        property var formArgs : function(args,str) {
            str = str.split(',')
//            console.log(str)
            for(var a in str)
            {
                var lineArr      = str[a].split('=')

                if(!args)
                    args = []

                if(ZGlobal._.isArray(args))
                    args.push({ name : lineArr[0] , value : lineArr[1] })
                else
                    args[lineArr[0]] = lineArr[1]
            }
            return args
        }


        //TODO --> make less dependent on "PROJECTS!"
        property var loadpageNew : function (source, args, inNewWindow) {
            //this makes it so we can pass in just aliases to this function!!
//            console.log(source,args,inNewWindow)
//            console.log(this, 'loadPageNew', arguments, source, args,inNewWindow)
            var srcStr = source.toString()
            if(!ZGlobal.functions.startsWith(srcStr, 'projects/', true))        source = 'projects/' + srcStr
            if(!ZGlobal.functions.endsWith  (srcStr, ".qml"     , true))        source = srcStr + ".qml"

            //console.log("SHIFT MODIFIER" ,ZGlobal.objects.keys.shift)
            if((ZGlobal.functions.isUndef(inNewWindow) || !inNewWindow ) && ZGlobal.objects.keys && ZGlobal.objects.keys.shift){
//                console.log(ZGlobal.objects.keys.shift)
                inNewWindow = { width : ZGlobal.app.width / 1.2 , height : ZGlobal.app.height / 1.2 }
            }


            //This needs to be smart enough to figure out if we give it a URL , what to load!
            var win         = null
            var rootSource  = null
            var rootArgs    = null
            source          = analyzeMap(source.toString())

//            console.log('LOADPAGENEW', source)
            var index = source.toLowerCase().indexOf('projects/')
            if(index !== -1) {
                rootSource = source.slice(index +9 )    //the length of projects/

                index = rootSource.indexOf('?')
                if(index !== -1){
                    rootArgs   = removeExtension(rootSource.slice(index + 1))    //only get the args in here
                    args       = formArgs(args,rootArgs)

//                    console.log(JSON.stringify(args, null, 2))

                    rootSource = rootSource.substring(0,index) + ".qml"
                    source = 'Projects/' + rootSource
                }


                rootSource   = rootSource.split('/')
                var thisItem = rootSource[rootSource.length - 1] ? removeExtension(rootSource[rootSource.length - 1]) : removeExtension(rootSource[0])
                rootSource   = removeExtension(rootSource[0])  //this is the root!


                if(!om.map[rootSource]){

                    if(ZGlobal.objects.hudMsg)
                        ZGlobal.objects.hudMsg("\uf071", 'No such file : '+ rootSource)
                    return false
                }

                 //this is one of the main thingers!
                if(om.map[thisItem]) {
                    //IS one of the root QMLS!!!
                    if(args){
                        var rootObj = om.map[thisItem].main.item
                        for(var i = 0; i < args.length; i++){
                            if(rootObj.hasOwnProperty(args[i].name))
                                rootObj[args[i].name] = args[i].value
                        }
                    }

                    itemShower.showNewItem(om.map[thisItem].main)
                    return
                }


                if(inNewWindow) {
                    win = ZGlobal.functions.getQmlObject(["QtQuick 2.4","QtQuick.Window 2.2","Zabaat.UI.Wolf 1.1","QtQuick.Controls 1.2", "Zabaat.Navigation 1.0", ZGlobal.functions.spch(localComponentsPath) ],
                                                                                                "Window{id : rootObject;
                                                                                                        width : 800; height : 640; visible : true;
                                                                                                        property alias zl : loader;
                                                                                                        property alias titleBar  : ztitle;
                                                                                                        property alias colorRect : clrRect;
                                                                                                        property int winIndex    : -1;
                                                                                                        property bool closeSignal : true;

                                                                                                        signal imClosing(var self);
                                                                                                        onClosing : imClosing(rootObject);

                                                                                                        color : 'transparent';
                                                                                                        Rectangle { id: clrRect; anchors.fill: loader;  }
                                                                                                        ZLoader { id : loader;
                                                                                                                  width: parent.width;  height : parent.height - ztitle.height;
                                                                                                                  anchors.top : ztitle.bottom;
                                                                                                                  property alias __titleStr : rootObject.title;
                                                                                                                  Component.onDestruction: rootObject.close(); }

                                                                                                        ZTitleBar{
                                                                                                         id : ztitle ; width : parent.width; height: 30; haveMinimize: false; haveMaximize : false;
                                                                                                         title : loader.item ? loader.item.title : rootObject.title;
                                                                                                         onTitleChanged: if(title !== ''){ parent.title = title;}
                                                                                                        }
                                                                                                        Rectangle { anchors.fill: parent; color : 'transparent'; border.width: 3}
                                                                                                        Action { shortcut : 'escape'; onTriggered : rootObject.close(); }
                                                                                                        Rectangle {
                                                                                                            anchors.fill: parent;
                                                                                                            color : 'darkGray';
                                                                                                            opacity : 0.6;
                                                                                                            visible : !rootObject.active;
                                                                                                        }
                                                                                                }", Qt.application)
                    rootSource          = null
//                    console.log('setting flags')
                    win.flags           = Qt.FramelessWindowHint | Qt.WindowMinimizeButtonHint |  Qt.Window | Qt.MSWindowsOwnDC

//                    win.title           = title
//                    win.titleBar.title  = title
                    win.titleBar.winPtr = win
                    win.width           = ZGlobal.functions.isUndef(inNewWindow.width)  ? rootObject.width  / 1.2 : inNewWindow.width
                    win.height          = ZGlobal.functions.isUndef(inNewWindow.height) ? rootObject.width  / 1.2 : inNewWindow.height
                    win.x               = ZGlobal.app.width/2 - win.width/2
                    win.y               = ZGlobal.app.height/2 - win.height/2
                    win.titleBar.focusColor      = focusColor_win
                    win.titleBar.unfocusColor    = unfocusColor_win

                    //Just so we can keep track of all our windows !!! and can then later use this to determine which window is active!!
                    registerNewWindow(win)


                    //TODO, perhaps make this ni ZGlobal.styles so we don't have to shove it into objects!!
                    win.colorRect.color   = ZGlobal.style._default
                    win.colorRect.opacity = ZGlobal.settings.backgroundOpacity
                }
                var obj = win === null ? ZGlobal.functions.getNewObject(Qt.resolvedUrl("ZLoader.qml"), null) : win.zl
                source = source.toString().slice(9) //the length of projects/

                obj.extraInfo = {root : rootSource, origSource : source}
                obj.imReady.connect(genName)


//                console.log("LOAD PAGE CALLED" , rootPath.toString() + "/" + source)
                obj.loadPage(rootPath.toString() + "/" + source, args)

                if(win === null) {
                    obj.iDied.connect(destructionCleanup)
                }

                return true

            }
        }

        function registerNewWindow(win){
            win.winIndex          = windows.length
            windows[win.winIndex] = win
            ZGlobal.functions.setObject('windows', windows)
            win.imClosing.connect(closeWindowCleanup)
        }
        function destructionCleanup(title, obj){
            om.removeFromList(obj)
        }
        function closeWindowCleanup(win){
            windows.splice(win.winIndex,1)

            //readjust indices!
            for(var i = 0; i < windows.length; i++){
                windows[i].winIndex = i
            }

            ZGlobal.functions.setObject('windows',windows)
        }

        property var genName : function(name, obj) {
//            console.log('appLoader.qml genName(', name, obj, ')' )
            //by this time the object will have an objectName! We just need to append a number to it in this
            //generic implementation of this function!
            if(obj.extraInfo.root)  //is not in a new window!!
            {
//                console.log(rootObject, 'genName function called', name, obj)

                //our loader waits to call this function if the item it is loading has a ready signal.
                //the item in question should change its title to the appropriate thing before it calls ready!
                if(obj.objectName.indexOf('.qml') !== -1)   //if the objectName doesn't have a .qml
                    obj.objectName += ++count


                if(om.map[obj.extraInfo.root].open.addItem(obj.objectName, obj))    //add this item if it doesnt exist!!
                {
                    //Now amke this obj the showItem
                    //console.log('now going to show', obj)
                    itemShower.showNewItem(obj)
                }
                else
                {
                    //lets see if we have some args on this new object!!
                    var existingLoader = om.map[obj.extraInfo.root].open.map[obj.objectName].main
//                    var existingItem   = existingLoader.item
////                    console.log(name, 'already exists as', existingItem, 'in', existingLoader)
//                    if(obj.loadObj){
//                        for(var i = 0; i < obj.loadObj.length; i++){
//                            if(existingItem.hasOwnProperty(obj.loadObj[i].name) && existingItem[obj.loadObj[i].name] !== obj.loadObj[i].value) {
//                                existingItem[obj.loadObj[i].name] = obj.loadObj[i].value
////                                console.log('copying over', obj.loadObj[i].name , obj.loadObj[i].value)
//                            }
//                        }
//                    }

                    if(obj){
                        obj.destroy()
                    }

                    itemShower.showNewItem(existingLoader) //show the already existing item
                }
            }
            else{   //in a new window
                if(obj.objectName.indexOf('.qml') !== -1)   //if the objectName doesn't have a .qml
                    obj.objectName += ++count

                if(obj.hasOwnProperty('__titleStr'))
                    obj.__titleStr = obj.objectName


//                obj.parent.titleBar.title = obj.objectName

            }

        }

        function analyzeMap(str){
            //lets break the string up, we know it has Projects/ at the start and .qml at the end (most of the time!!)
            var mainStr = str

            if(str.toLowerCase().indexOf('projects/') !== -1)                mainStr = mainStr.slice(9)
            if(str.toLowerCase().indexOf('.qml')      !== -1)                mainStr = mainStr.slice(0,-4)


            //lets also check if there's a question mark somewhere!
            mainStr = mainStr.split('?')
            mainStr[0] = mainStr[0].toLowerCase()

            //analyze if there's an '=' after ? . If there's nothing, we will just add uid= ourselves
            if(mainStr.length > 1 && mainStr[1].indexOf('=') === -1)
                mainStr[1] = 'uid=' +  mainStr[1]

            if(aliasMap[mainStr[0] ]){
                if(mainStr.length === 1)         return 'Projects/' + aliasMap[mainStr[0] ] + '.qml'
                else                             return 'Projects/' + aliasMap[mainStr[0] ] + '?' + mainStr[1] +  '.qml'
            }

            return str
        }
        function removeExtension(str){
            var index = str.indexOf('.qml')
            if(index != -1)
                str = str.substring(0,index)
            return str
        }
    }




}

