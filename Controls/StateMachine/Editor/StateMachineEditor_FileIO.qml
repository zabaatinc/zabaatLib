import QtQuick 2.4
import Zabaat.Material 1.0
import Zabaat.Utility.FileIO 1.0
import QtQuick.Dialogs 1.2
Item {
    id : rootObject
    anchors.fill: parent
    property string defaultFileToLoad : ""
    onDefaultFileToLoadChanged: lm.loadModel()
    property alias folder : fd.folder
    property alias editor : sme
    property alias fileUrl : fd.fileUrl
    Rectangle {
        width : parent.width
        height : parent.height * 0.05
        anchors.top: parent.top
        color      : Colors.info

        Row {
            width : parent.height * 2 + spacing
            height : parent.height
            spacing : 5
            anchors.right: parent.right
            anchors.margins: 5

            ZButton {
                //load button
                text : "Save"
                width : height
                height : parent.height
                state : "ghost-f3"
                onClicked : zfileio.save()
            }
            ZButton {
                //load button
                text : "Load"
                width : height
                height : parent.height
                state : "ghost-f3"
                onClicked : zfileio.load()
            }
        }
    }
    StateMachineEditor {
        id : sme
        width : parent.width
        height : parent.height * 0.95
        anchors.bottom: parent.bottom
    }
    ZFileOperations {
        id : zfileio
        property int saveCounter : 0

        function save(url, json){
            //if it is still undefined, we need the fd to show up!
            if(url === null || typeof url === 'undefined' || url === ""){
                fd.mode = "save"
                fd.open()
                return;
            }
            var arr = url.toString().split("/")
            var file = arr[arr.length-1]

            arr.splice(arr.length -1, 1)
            var folder = arr.join("/")

            folder = folder.replace("file:///", "")
            folder = folder.replace('qrc:///', "")

            if(json === null || typeof json === 'undefined' || json === ""){
                json = sme.logic.getJSON()
            }
            if(zfileio.writeFile(folder,file,json)){
                console.log("saves performed", ++saveCounter)
            }
        }
        function load(url){
            if(url === null || typeof url === 'undefined' || url === ""){
                fd.mode = "load"
                fd.open()
                return;
            }
            url = url.toString()
            url = url.replace("file://", "")
            url = url.replace('qrc://', "")
            if(url.indexOf("/") === 0)
                url = url.slice(1)

            var txt = zfileio.readFile(url)
            if(txt){
                try{
                    var obj = JSON.parse(txt)
                    lm.set(0,obj);
                }
                catch(e) {
                    console.log("Load failed", e)
                }
            }
        }
    }
    FileDialog {    //default way of saving lading
        id : fd
        property string mode : ""
        selectExisting: mode === 'save' ?  false : true
        nameFilters: [ "JSON (*.json)" ]
        onFileUrlChanged: {
            if(fileUrl.toString() !== ""){
                if(mode === "save")    zfileio.save(fileUrl)
                else                   zfileio.load(fileUrl)
            }
        }
    }
    ListModel {
        id : lm
        dynamicRoles: true
        property var stateMachineObject : ({
                                    id   : "someMongoId" ,
                                    name : "app",
                                    functions  : []  ,
                                    states     : [ { id : "0",
                                                      name : "homepage",
                                                      transitions  : [] ,   //implicit usage
                                                      functions    : []  ,
                                                      x : 100,
                                                      y : 100,
                                                      w : 192,
                                                      h : 64,
                                                      isDefault:true,
                                                    }
                                                 ]
                                 })


        function loadModel(){
            sme.model = null;
            lm.clear()
            if(defaultFileToLoad !== ""){
                defaultFileToLoad = defaultFileToLoad.replace("file://","")
                if(defaultFileToLoad.indexOf("/") === 0)
                    defaultFileToLoad = defaultFileToLoad.slice(1)

                var txt = zfileio.readFile(defaultFileToLoad)
                try {
                    var obj = JSON.parse(txt);
                    lm.append(obj);
                    sme.model = lm.get(0)
                }
                catch(e) {
                    console.error("Could not parse js", e, txt);
                    lm.append(stateMachineObject) ;
                    sme.model = lm.get(0)
                }
            }
            else {
                lm.append(stateMachineObject) ;
                sme.model = lm.get(0)
            }
        }

        Component.onCompleted: loadModel()
    }


}
