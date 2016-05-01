import QtQuick 2.4
import Zabaat.Misc.Global 1.0
import "../../"
import Zabaat.UI.Fonts 1.0

FocusScope {
    id : rootObject

    anchors.fill: null

//    width  : details.width
//    height : cellHeight * 2
    property var blankItem: null

    property alias fields                     : line.fields
    property alias fields_widths              : line.fields_widths
    property alias fields_displayFuncs        : line.fields_displayFuncs
    property alias fields_inverseDisplayFuncs : line.fields_inverseDisplayFuncs
    property var setValue : line.setValue
    property var reevaluateValues : line.reevaluateValues
    property var getDelegate : line.getDelegateItem
    property var reevaluateEnabled : line.reevaluateEnabled
    property var externalInitFunction : null

    property alias advanced                   : line.advanced
    property alias model                      : line.model

    property alias btn                 : saveButton
    property var   self                : this
    readonly property var blankModel   : line.blankModel
    readonly property var filledModel  : line.filledModel
    property string section  : ""
    property int    index    : -1


    signal close()
    signal save(var self)
    signal genericSignal(var changeObject)

//    RectangularGlow {
//        anchors.fill: line
//        glowRadius : 10
//        spread : 0.3
//        color : 'black'
//        cornerRadius: glowRadius
//    }
    GenericHeader {
        id : line
        width  : parent.width
        height : parent.height/2
        activeFocusOnTab: true
        color          : ZGlobal.style.text.color2
        fontColor      : ZGlobal.style.text.color1
        onGenericSignal: rootObject.genericSignal(changeObj)
        externalInitFunc: rootObject.externalInitFunction

        ZTracer { id : tracer ; color : "black" ;  borderWidth: 4 }
    }


    ZButton {
        id : closeButton
        anchors.right   : saveButton.left
        anchors.bottom  : parent.bottom
        anchors.rightMargin: 5
        width           : parent.height/2
        height          : parent.height/2
        text            : ""
        icon : FontAwesome.close

        onBtnClicked    : {model = null; close()}
        activeFocusOnTab: true
        defaultColor    : focus ? ZGlobal.style.danger : "darkRed"
    }

    ZButton {
        id : saveButton
        anchors.right   : parent.right
        anchors.bottom  : parent.bottom
        width           : parent.height
        height          : parent.height/2
        text            : ""
        icon            : FontAwesome.save
        onBtnClicked    : save(rootObject.self)
        activeFocusOnTab: true
        defaultColor    : focus ? ZGlobal.style.info : ZGlobal.style.accent
    }




    Keys.onEnterPressed : save(rootObject.self)
    Keys.onReturnPressed: save(rootObject.self)
    Keys.onEscapePressed: {
        model = null
        close()
    }
}

