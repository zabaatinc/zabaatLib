import QtQuick 2.5
import Zabaat.Material 1.0
FocusScope {
    id: rootObject
    objectName : ""
    signal imDying(var self);
    Component.onDestruction: imDying(rootObject);

    property var uniqueProperties : []      // ["msgbxoId" , "message"]
    property var uniqueSignals    : ({})    // ({ okClicked : ["text","id"], cancelClicked:[] })
    property var dataSection      : ({})	//## use this for stroing globally available javascript objects and functions
    property var propArr          : []      //## zEdit will use this to store and load information as readable format for us! Cause we might have assigned a value to
    property var eventArr         : []      //## zEdit will use this to store and load information as readable format for us! Cause we might have assigned a value to

    property string skin          : MaterialSettings.style.defaultSkin
    property string colors        : MaterialSettings.style.defaultColors
    property string font1         : MaterialSettings.font.font1
    property string font2         : MaterialSettings.font.font2
    property var style   : styleLoader && styleLoader.item ? styleLoader.item : null
    property bool   disableShowsGraphically : true

    focus : false
    property bool debug           : false
    function log(){
        if(debug)
            console.log.apply(this,arguments)
    }

//    onActiveFocusChanged: if(activeFocus && style)
//                                style.forceActiveFocus()



    //This loads the SKIN or the way the component will look. By default they should be in the folder :
    // <PROJECTDIR>/lib/Zabaat/Material/components/ui/skins/<skinName>/<objectName>.qml
    Loader {
        id       : styleLoader
        onLoaded : item.logic = rootObject
        anchors.fill: parent
        focus       : true
        onActiveFocusChanged: if(activeFocus && item)
                                  nextItemInFocusChain()

    }

    Loader {
        id       : editModeLoader
        z        : 9999999
        source   : MaterialSettings.editMode ? "ZEdit.qml" : ""
        onLoaded : {
            editModeLoader.item.theParent = rootObject
        }
        anchors.fill: parent
        clip : false
        focus : false
    }

    onObjectNameChanged: {  //TRY LOADING A SKIN
        if(objectName !== ""){
//            console.log("TRYING TO LOAD" , objectName)
            try {
                styleLoader.source = MaterialSettings.style.skinsPath + skin + "/" +  objectName + ".qml"
            }
            catch(e){
                console.warn("There is no " , skin , "at", MaterialSettings.style.skinsPath, "for" , objectName + ".qml")
                if(skin !== MaterialSettings.style.defaultSkin){
                    try {
                        styleLoader.source = MaterialSettings.style.skinsPath + MaterialSettings.style.defaultSkin + "/" +  objectName + ".qml"
                    }
                    catch(e){
                        console.warn("There is no " , MaterialSettings.style.defaultSkin , "at", MaterialSettings.style.skinsPath, "for" , objectName + ".qml")
                    }
                }
            }
        }
    }





}
