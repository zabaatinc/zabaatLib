import QtQuick 2.5
import Zabaat.Material 1.0

/*!
   \brief this is the base component of Zabaat.Material. Inside it, is a Loader that loads the
    associated ZSkin ('based on objectName'). The whole concept of this library is to separate the logic from the gui
    of the a component. This is the logic part and has all the relevant data that the outside
    world will ever need to interact with!
   \inqmlmodule Zabaat.Material 1.0
    \code
     import Zabaat.Material 1.0
     ZObject {
         id : rootObject
         objectName: "ZText"
         property string text : ""
     }
    \endcode
*/
FocusScope {
    id: rootObject

    /*! This is <b>VERY IMPORTANT<b>. This skin will be loaded!!  */
    objectName : ""
    signal imDying(var self);
    Component.onDestruction: imDying(rootObject);


    /*! This is important for ZEdit; should we ever bring that back \hr  */
    property var uniqueProperties : []      // ["msgbxoId" , "message"]

    /*! This is important for ZEdit; should we ever bring that back \hr  */
    property var uniqueSignals    : ({})    // ({ okClicked : ["text","id"], cancelClicked:[] })

    /*! This is important for ZEdit; should we ever bring that back \hr  */
    property var dataSection      : ({})	//## use this for stroing globally available javascript objects and functions

    /*! ZEdit will use this to store and load information as readable format for us! Cause we might have assigned a value to \hr */
    property var propArr          : []

    /*! ZEdit will use this to store and load information as readable format for us! Cause we might have assigned a value to \hr */
    property var eventArr         : []

    /*! The default skin folder.  This will make it go look for <objectName>.qml in the <skin> folder in
        MaterialSettings.style.skinsPath.
        \b default: MaterialSettings.style.defaultSkin
        \hr
    */
    property string skin          : MaterialSettings.style.defaultSkin

    /*! The default color theme. This will make it go look for <colors>.qml in MaterialSettings.style.colorsPath.
        \b default: MaterialSettings.style.defaultColors \hr
    */
    property string colors        : MaterialSettings.style.defaultColors

    /*! The name of font1.
        \b default: MaterialSettings.font.font1
        \hr
    */
    property string font1         : MaterialSettings.font.font1

    /*! The name of font2.
        \b default: MaterialSettings.font.font2
        \hr
    */
    property string font2         : MaterialSettings.font.font2

    /*! The respective ZSkin, if it has loaded successfully \hr */
    property var style   : styleLoader && styleLoader.item ? styleLoader.item : null

    /*! Determines whether or not to append the "-disabled" to this ZObject if it is not enabled \hr */
    property bool   disableShowsGraphically : true

    focus : false

    /*! Determines whether to print log messages to the console! \hr */
    property bool debug           : false

    /*! Same as console.log but prints only when this component is in debug mode \hr */
    function log(){
        if(debug)
            console.log.apply(this,arguments)
    }



    /*! This loads the SKIN or the way the component will look. By default they should be in the folder :
        \b default: <PROJECTDIR>/lib/Zabaat/Material/components/ui/skins/<skinName>/<objectName>.qml
        \hr
    */
    Loader {
        id       : styleLoader
        objectName : "styleLoader"
        onLoaded : item.logic = rootObject
        anchors.fill: parent
        focus       : true

    }

    Loader {
        id       : editModeLoader
        objectName : "editModeLoader"
        z        : 9999999
        source   : MaterialSettings.editMode ? "ZEdit.qml" : ""
        onLoaded : {
            editModeLoader.item.theParent = rootObject
        }
        anchors.fill: parent
        clip : false
        focus : false
//        asynchronous: true
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
