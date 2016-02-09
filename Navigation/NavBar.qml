import QtQuick 2.0
import Zabaat.UI.Wolf 1.0
import Zabaat.Misc.Global 1.0
import Qt.labs.folderlistmodel 2.1
import Zabaat.UI.Fonts 1.0

Item
{
    id : rootObject
    property var objectMap: []
    property int btnHeight : 40
    property var devButtons: []//['baatTestingFacility','testingGrounds','reportGenerator']  //TODO - move this for more generic functions
    property alias listPtr : lv
    signal selected(string name, var obj)

    property bool minimized : true
    property url rootPath   : Qt.resolvedUrl(".")
    property var iconMap : null

    property alias minMaxBtnWidth : minMaxBtn.width


    Rectangle{
        id: backBlock
        width:lv.width
        x:lv.x
        anchors.top:rootObject.top
        anchors.bottom: rootObject.bottom
        color: ZGlobal.style.accent
//        opacity : 0.7
    }
    ZButton  {
        id : minMaxBtn
        width                 : 32
        height                : rootObject.height//width * 4
        anchors.left          : lv.right
        anchors.verticalCenter: rootObject.verticalCenter
        text                  : ""
        showIcon              : true
        fontAwesomeIcon       : "\uf0c9"
        onBtnClicked          : minimized = !minimized
        defaultColor          : Qt.lighter(ZGlobal.style.accent,1.4)
    }

    ListView {
        id : lv
        objectName : "NavBarList"
        x : !minimized && count > 0 ? 0 : -lv.width  // - minMaxBtn.width/2
//        y : 0//rootObject.height/2 - lv.contentHeight/2
        width : rootObject.width
        height: rootObject.height
        Behavior on x{
            NumberAnimation {
                duration : 333
            }
        }

        property var requestAppPermissions : function(){

            if(ZGlobal.grabQMLsFromServer)
            {
               ZGlobal.client.controller.postReq('/user/getApps',{},function(msg)
               {
                   try
                   {
                       msg = msg.toString().split(',')
                       serverApps.clear()
                       for(var i = 0; i < msg.length; i++)
                            serverApps.append({filePath : '/Projects/' + msg[i] })
                   }catch(e) { ZGlobal.debugMsg(e.message)}
               })
            }
        }
        property Item modelContainer : Item {
            id : modelContainer
            function projName(filePath)
            {
                var p = filePath.split('/')
                return p[p.length-1]
            }

            FolderListModel
            {
                id : localApps
                showDirs    : true
                nameFilters : [""]
                folder      : rootPath
                //enabled : !rootObject.loadType
            }

            ListModel
            {
                id : serverApps
            }
        }

        model : ZGlobal.objects.loginState && ZGlobal.objects.loginState() ?  (ZGlobal.grabQMLsFromServer ? serverApps : localApps) : null
        onModelChanged : {
            if(ZGlobal.functions.isUndef(ZGlobal.objects.appPermissions))       ZGlobal.functions.addObject("appPermissions", model)
            else                                                                ZGlobal.functions.setObject("appPermissions", model)
        }

        delegate : ZButton {
            id: dele
            property bool imADelegate: true
            property int _index : index
            property string name : modelContainer.projName(filePath)
//            onNameChanged: if(name !== "") grammarify(name)

            height       : scale > 0 ? btnHeight  : 0
            text         : "     " + grammarify(name)
            horizontalAlignment        : Text.AlignLeft
            iconPtr.horizontalAlignment: Text.AlignHCenter
            iconPtr.scale: 1
            iconPtr.width: ZGlobal.style.text.normal.pointSize
            iconPtr.x    : iconPtr.paintedWidth/2

            icon : iconMap && ZGlobal.functions.isDef(iconMap[name]) ? iconMap[name] : FontAwesome.question

            scale        : !ZGlobal.settings.devMode && ZGlobal._.indexOf(devButtons,dele.name) !== -1 ? 0 : 1
            width        : scale > 0 ? lv.width : 0
            enabled      : scale > 0
            visible      : scale > 0
            onBtnClicked : clickFunc()
            function clickFunc(){
                if(enabled)
                    rootObject.selected(name, ZGlobal.objects.objectsModel.map[name].main)
            }

            Component.onCompleted: {
//                var obj = ZGlobal.functions.getNewObject(Qt.resolvedUrl("ZLoader.qml"), null)
//                obj.autoAssignObjectName = false
//                obj.objectName = text
//                obj.loadPage(Qt.resolvedUrl(localApps.folder + text +  "/"  + text + ".qml"))

//                ZGlobal.objects.objectsModel.addItem(text,obj)
            }
        }

        function getDelegateInstanceAt(index){
            for(var i = 0; i < lv.contentItem.children.length; i++)
            {
                var elem = lv.contentItem.children[i]
                if(elem.imADelegate && elem._index === index)
                    return elem
            }
            return null
        }


        Component.onCompleted: {
            if(ZGlobal.functions.isUndef(ZGlobal.objects.loginCallBacks))       ZGlobal.objects['loginCallBacks'] = [requestAppPermissions, loadDashTimer.start]
            else {
                ZGlobal.objects.loginCallBacks.push(requestAppPermissions)
                ZGlobal.objects.loginCallBacks.push(loadDashTimer.start)
            }

            if(ZGlobal.functions.isUndef(ZGlobal.objects.logoutCallBacks))       ZGlobal.objects['logoutCallBacks'] = [serverApps.clear]
            else                                                                ZGlobal.objects.logoutCallBacks.push(serverApps.clear)

        }
    }


    Keys.onReleased: {
        if(!minimized)
        {
            switch(event.key){
                case Qt.Key_Up     : decIndex()
                                     break;
                case Qt.Key_Down   : incIndex()
                                     break;
                case Qt.Key_Escape : minimized = true  ; break;
                case Qt.Key_Return : var elem = lv.getDelegateInstanceAt(lv.currentIndex);
                                     if(elem)
                                     {
                                         elem.clickFunc();
                                         minimized = true;
                                     }
                                     break;
            }
        }
//        event.accepted = true
    }

    Timer {
        id : loadDashTimer
        interval : 250
        running : false
        repeat : true
        onTriggered : {
            if(lv.model){
                addToObjectModel()


                loadDash()
                loadDashTimer.stop()
            }
        }
    }


    function incIndex(count){

        if(typeof count === 'undefined')
            count = 0

        if(count !== lv.count){ //the count is to prevent us from looping forever if everything is in devMODE!!!

            if(lv.currentIndex < lv.count - 1)
                lv.currentIndex++
            else
                lv.currentIndex = 0

            var elem = lv.getDelegateInstanceAt(lv.currentIndex)
            if(elem && !elem.enabled)
                incIndex(count + 1)
        }
    }
    function decIndex(count){

        if(typeof count === 'undefined')
            count = 0

        if(count !== lv.count){
            if(lv.currentIndex > 0)            lv.currentIndex--
            else                               lv.currentIndex = lv.count - 1

            var elem = lv.getDelegateInstanceAt(lv.currentIndex)
            if(elem && !elem.enabled)
                decIndex(count + 1)
        }
    }
    function addToObjectModel(){
        for(var i = 0; i < lv.model.count; i++){
            var item = ZGlobal.functions.getDelegateInstance(lv,i)
            var obj = ZGlobal.functions.getNewObject(Qt.resolvedUrl("ZLoader.qml"), null)
            obj.autoAssignObjectName = false
            obj.objectName = item.name
            obj.loadPage(Qt.resolvedUrl(localApps.folder + "/" + item.name +  "/"  + item.name + ".qml"))

            ZGlobal.objects.objectsModel.addItem(item.name,obj)
        }
    }
    function loadDash(){
        if(ZGlobal.objects.loadPageNew) {
//            console.log('loading dash')
            ZGlobal.functions.removeAllActionsThatReturnFalse(isAnFKey)
            ZGlobal.objects.loadPageNew('dash')
        }
    }
    function isAnFKey(str){
        if(str) {
            str = str.toLowerCase()
            return str.indexOf('alt') !== -1 || (str.length === 2 && str.charAt(0) === 'f' && Number(str.charAt(1)))
        }
        return false
    }
    function grammarify(str){
        //find index of all Cap words
        var arr = getWords(str)
//        console.log(arr)

        //special case "of", turn it to lowercase
        for(var a in arr){
            if(arr[a].toLowerCase() === 'of')
                arr[a] = arr[a].toLowerCase()
        }

        return arr.join(' ')
    }
    function getWords(str){
        var ind1  = -1
        var words = []

        for(var s = 0 ; s < str.length; s++){
            var c = str.charAt(s)
            if(c >= 'A' && c <= 'Z'){
                if(ind1 === -1)
                    ind1 = s
                else {
                    words.push(str.substring(ind1,s));
                    ind1 = s
                }
            }
            if(s === str.length - 1 && ind1 !== -1){
                words.push(str.substring(ind1,s+1))
            }
        }

        return words
    }


}




